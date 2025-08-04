`timescale 1ns / 1ps

module top_module_12_cbfp #(
    parameter NUM_PARALLEL_PATHS = 16,
    parameter OWIDTH = 12, // CBFP에서 12로 변경됨
    parameter BLOCK_SIZE = 512,
    parameter DATA_IN_WIDTH = 15,
    parameter TW_WIDTH = 9,
    parameter TW_TABLE_DEPTH = 64
) (
    input clk,
    input rst_n,
    input enable_fft,

    input signed [DATA_IN_WIDTH:0] bfly12_tmp_real_in [0:NUM_PARALLEL_PATHS-1], 
    input signed [DATA_IN_WIDTH:0] bfly12_tmp_imag_in [0:NUM_PARALLEL_PATHS-1],

    output signed [OWIDTH-1:0] do_re [0:NUM_PARALLEL_PATHS-1],
    output signed [OWIDTH-1:0] do_im [0:NUM_PARALLEL_PATHS-1],
    output do_en,
    output [4:0] do_index [0:NUM_PARALLEL_PATHS-1]
);

    logic signed [DATA_IN_WIDTH:0] bfly12_tmp_real_buf [0:NUM_PARALLEL_PATHS-1];
    logic signed [DATA_IN_WIDTH:0] bfly12_tmp_imag_buf [0:NUM_PARALLEL_PATHS-1];

    logic fft_done; 

    logic signed [DATA_IN_WIDTH + TW_WIDTH : 0] pre_bfly12_re [0:NUM_PARALLEL_PATHS-1]; 
    logic signed [DATA_IN_WIDTH + TW_WIDTH : 0] pre_bfly12_im [0:NUM_PARALLEL_PATHS-1];

    logic signed [DATA_IN_WIDTH-1:0] bfly12_tmp_real_saturated [0:NUM_PARALLEL_PATHS-1];
    logic signed [DATA_IN_WIDTH-1:0] bfly12_tmp_imag_saturated [0:NUM_PARALLEL_PATHS-1];

    localparam ADDR_WIDTH = $clog2(TW_TABLE_DEPTH); 
    logic [ADDR_WIDTH-1:0] tw_addr [0:NUM_PARALLEL_PATHS-1];
    logic signed [TW_WIDTH-1:0] tw_re_out [0:NUM_PARALLEL_PATHS-1];
    logic signed [TW_WIDTH-1:0] tw_im_out [0:NUM_PARALLEL_PATHS-1];

    // CBFP 변경사항 반영: 32클럭으로 변경
    localparam NUM_CHUNKS = 32; // 512개 데이터를 16개씩 32번 처리 (2블록씩)
    logic [$clog2(NUM_CHUNKS)-1:0] chunk_idx;
    logic fft_start_reg;
    logic fft_done_reg;

    logic enable_fft_d1; 
    assign fft_done = fft_done_reg; 

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            chunk_idx     <= 0; 
            fft_start_reg <= 0;
            fft_done_reg  <= 0; 
            enable_fft_d1 <= 0; 
        end else begin
            enable_fft_d1 <= enable_fft; 
            if (enable_fft && !enable_fft_d1) begin
                chunk_idx     <= 0; 
                fft_done_reg  <= 0; 
                fft_start_reg <= 1; 
            end
            else if (enable_fft && !fft_done_reg) begin
                if (chunk_idx == NUM_CHUNKS - 1) begin
                    chunk_idx     <= 0; 
                    fft_done_reg  <= 1; 
                    fft_start_reg <= 0; 
                end else begin
                    chunk_idx <= chunk_idx + 1; 
                    fft_done_reg <= 0; 
                    fft_start_reg <= 1;
                end
            end
            else if (!enable_fft && fft_done_reg) begin
                fft_done_reg  <= 0; 
                fft_start_reg <= 0;
            end
            else begin
                fft_start_reg <= fft_start_reg; 
                fft_done_reg <= fft_done_reg; 
            end
        end
    end

    // saturation #(
    // .LENGTH(DATA_IN_WIDTH),
    // .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS)
    // ) SATURATION_15(
    //     .bfly02_tmp_real_in(bfly12_tmp_real_in),
    //     .bfly02_tmp_imag_in(bfly12_tmp_imag_in),
    //     .bfly02_tmp_real_saturated(bfly12_tmp_real_saturated),
    //     .bfly02_tmp_imag_saturated(bfly12_tmp_imag_saturated)
    // );

    // 타이밍 맞추기 위한 버퍼 (twiddle이랑)
    delaybuffer_cbfp #(.DEPTH(32), .WIDTH(16)) SAT_BUF_1CLK (
        .rstn (rst_n),
        .clk  (clk),
        .di_re(bfly12_tmp_real_in),
        .di_im(bfly12_tmp_imag_in),
        .do_re(bfly12_tmp_real_buf),
        .do_im(bfly12_tmp_imag_buf)
    );

    always_comb begin
        for (int k = 0; k < NUM_PARALLEL_PATHS; k++) begin
            tw_addr[k] = (chunk_idx * NUM_PARALLEL_PATHS + k) % 64;
        end
    end

    genvar t;
    for (t=0 ;t<16;t++) begin
        twiddle_64 #(
            .WIDTH(TW_WIDTH),
            .TW_TABLE_DEPTH(TW_TABLE_DEPTH),
            .TW_FF(1),
            .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS)
        ) TWIDDLE_64(
            .clk(clk),  
            .addr(tw_addr[t]), 
            .tw_re(tw_re_out[t]),
            .tw_im(tw_im_out[t])
        );
    end

    complex_multiplier_12 #(
    .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS),
    .DATA_IN_WIDTH(16),
    .TW_WIDTH(9)
    ) C_MULTIPLIER_12( 
        .clk(clk),
        
        .bfly12_tmp_real_saturated(bfly12_tmp_real_buf), 
        .bfly12_tmp_imag_saturated(bfly12_tmp_imag_buf), 

        .tw_re(tw_re_out),
        .tw_im(tw_im_out), 

        .pre_bfly12_re(pre_bfly12_re),
        .pre_bfly12_im(pre_bfly12_im)
    );

    cbfp1 #(
        .WIDTH(25),
        .OWIDTH(12) 
    ) CBFP_1(
        .clk(clk),
        .rstn(rst_n),

        .di_re(pre_bfly12_re),
        .di_im(pre_bfly12_im),
        .di_en(fft_start_reg),

        .do_re(do_re),
        .do_im(do_im),
        .do_en(do_en),
        .do_index(do_index)
    );

endmodule
