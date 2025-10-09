`timescale 1ns/1ps

module step1 #(
    parameter int FIX = 10,
    parameter int NUM = 8,
    parameter int N =256
) (
    input  logic clk,
    input  logic rst,
    input  logic valid, // 추가: 카운터 valid 신호 입력

    // step0에서 들어오는 (+), (-)
    input  logic signed [FIX-1:0] p_bfly00_re   [0:15],
    input  logic signed [FIX-1:0] n_bfly00_re  [0:15],
    input  logic signed [FIX-1:0] p_bfly00_im   [0:15],
    input  logic signed [FIX-1:0] n_bfly00_im  [0:15],

    // 결과 출력
    output logic signed [FIX+2:0] p_bfly01_re [0:15],
    output logic signed [FIX+2:0] n_bfly01_re [0:15],
    output logic signed [FIX+2:0] p_bfly01_im [0:15],
    output logic signed [FIX+2:0] n_bfly01_im [0:15]

);
// fixed-point <2.8> 계수 (256 == 1.0)
    logic signed [9:0] fac8_1_r [0:7] = '{ 256,  256,  256,    0,  256,  181,  256, -181 };
    logic signed [9:0] fac8_1_i [0:7] = '{   0,    0,    0, -256,    0, -181,    0, -181 };

    logic signed [FIX-1:0] upper_shiftreg_in_re [0:15];
    logic signed [FIX-1:0] lower_shiftreg_out_re [0:15];
    logic signed [FIX-1:0] upper_shiftreg_out_re [0:15];
    logic signed [FIX-1:0] upper_shiftreg_in_im [0:15];
    logic signed [FIX-1:0] lower_shiftreg_out_im [0:15];
    logic signed [FIX-1:0] upper_shiftreg_out_im [0:15];

    logic signed [FIX:0] p_bfly01_re_sum [0:15];
    logic signed [FIX:0] n_bfly01_re_sub [0:15];
    logic signed [FIX:0] p_bfly01_im_sum [0:15];
    logic signed [FIX:0] n_bfly01_im_sub [0:15];

    logic [1:0] phase;
    logic [$clog2(NUM)-1:0] cnt;
    

    // phase 설정
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 0;
            phase <= 0;
        end else if (valid) begin
            if (cnt == NUM-1) begin
                cnt <= 0;
                phase <= phase + 1'b1;
	end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end


    // 위쪽 shift reg 밀고빼기 re
    localparam int UP_DEPTH_re = N / 32;

    logic signed [FIX-1:0] up_shift_mem_re [0:UP_DEPTH_re-1][0:15];


    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (int i = 0; i < UP_DEPTH_re; i++)
                up_shift_mem_re[i] <= '{default:'0};
        end else if (phase == 2'd2) begin
            for (int i = UP_DEPTH_re-1; i > 0; i--)
                up_shift_mem_re[i] <= up_shift_mem_re[i-1];
            up_shift_mem_re[0] <= lower_shiftreg_out_re;
        end else begin
            for (int i = UP_DEPTH_re-1; i > 0; i--)
                up_shift_mem_re[i] <= up_shift_mem_re[i-1];
            up_shift_mem_re[0] <= p_bfly00_re;
        end
    end


    assign upper_shiftreg_out_re = up_shift_mem_re[UP_DEPTH_re-1];



    // 아래쪽 shift reg 밀고빼기 re
    localparam int LOW_DEPTH_re = N / 16;

    logic signed [FIX-1:0] low_shift_mem_re [0:LOW_DEPTH_re-1][0:15];
    integer j;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (j = 0; j < LOW_DEPTH_re; j++)
                low_shift_mem_re[j] <= '{default:'0};
        end else begin
            for (j = LOW_DEPTH_re-1; j > 0; j--)
                low_shift_mem_re[j] <= low_shift_mem_re[j-1];
            low_shift_mem_re[0] <= n_bfly00_re; 
        end
    end


    assign lower_shiftreg_out_re = low_shift_mem_re[LOW_DEPTH_re-1];

    
    // 위쪽 shift reg 밀고빼기 im
    localparam int UP_DEPTH_im = N / 32;

    logic signed [FIX-1:0] up_shift_mem_im [0:UP_DEPTH_im-1][0:15];
    integer i_im;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i_im = 0; i_im < UP_DEPTH_im; i_im++)
                up_shift_mem_im[i_im] <= '{default:'0};
        end else if (phase == 2'd2) begin
            for (i_im = UP_DEPTH_im-1; i_im > 0; i_im--)
                up_shift_mem_im[i_im] <= up_shift_mem_im[i_im-1];
            up_shift_mem_im[0] <= lower_shiftreg_out_im;
        end else begin
            for (i_im = UP_DEPTH_im-1; i_im > 0; i_im--)
                up_shift_mem_im[i_im] <= up_shift_mem_im[i_im-1];
            up_shift_mem_im[0] <= p_bfly00_im;
        end
    end


    assign upper_shiftreg_out_im = up_shift_mem_im[UP_DEPTH_im-1];



    // 아래쪽 shift reg 밀고빼기 im
    localparam int LOW_DEPTH_im = N / 16;

    logic signed [FIX-1:0] low_shift_mem_im [0:LOW_DEPTH_im-1][0:15];
    integer j_im;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (j_im = 0; j_im < LOW_DEPTH_im; j_im++)
                low_shift_mem_im[j_im] <= '{default:'0};
        end else begin
            for (j_im = LOW_DEPTH_im-1; j_im > 0; j_im--)
                low_shift_mem_im[j_im] <= low_shift_mem_im[j_im-1];
            low_shift_mem_im[0] <= n_bfly00_im; 
        end
    end


    assign lower_shiftreg_out_im = low_shift_mem_im[LOW_DEPTH_im-1];
    


    // 연산 enable: phase==1 또는 phase==3일 때 연산
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (int i = 0; i < 16; i++) begin
                p_bfly01_re_sum[i] <= '0;
                n_bfly01_re_sub[i] <= '0;
                p_bfly01_im_sum[i] <= '0;
                n_bfly01_im_sub[i] <= '0;
            end
        end else if (phase == 2'd1) begin
            for (int i = 0; i < 16; i++) begin
                p_bfly01_re_sum[i] <= upper_shiftreg_out_re[i] + p_bfly00_re[i];
                n_bfly01_re_sub[i] <= upper_shiftreg_out_re[i] - p_bfly00_re[i];
                p_bfly01_im_sum[i] <= upper_shiftreg_out_im[i] + p_bfly00_im[i];
                n_bfly01_im_sub[i] <= upper_shiftreg_out_im[i] - p_bfly00_im[i];
            end
        end else if (phase == 2'd3) begin // phase==3
            for (int i = 0; i < 16; i++) begin
                p_bfly01_re_sum[i] <= upper_shiftreg_out_re[i] + lower_shiftreg_out_re[i];
                n_bfly01_re_sub[i] <= upper_shiftreg_out_re[i] - lower_shiftreg_out_re[i];
                p_bfly01_im_sum[i] <= upper_shiftreg_out_im[i] + lower_shiftreg_out_im[i];
                n_bfly01_im_sub[i] <= upper_shiftreg_out_im[i] - lower_shiftreg_out_im[i];
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                p_bfly01_re_sum[i] <= '0;
                n_bfly01_re_sub[i] <= '0;
                p_bfly01_im_sum[i] <= '0;
                n_bfly01_im_sub[i] <= '0;
            end
        end
    end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
        for (int i = 0; i<16 ;i = i+1 ) begin
            p_bfly01_re[i] <= 0;
            n_bfly01_re[i] <= 0; 
            p_bfly01_im[i] <= 0;
            n_bfly01_im[i] <= 0; 
        end
   end
   else begin
    for (int i = 0; i < 16; i = i + 1) begin
            // 복소수 곱: (re + j im) * (W_re + j W_im)
            logic signed [FIX+9:0] pre_p_re, pre_n_re, pre_p_im, pre_n_im;

            // 복소수 곱셈
            pre_p_re = p_bfly01_re_sum[i] * fac8_1_r[phase] - p_bfly01_im_sum[i] * fac8_1_i[phase];
            pre_n_re = p_bfly01_re_sum[i] * fac8_1_i[phase] + p_bfly01_im_sum[i] * fac8_1_r[phase];
            pre_p_im = n_bfly01_re_sub[i] * fac8_1_r[phase+2] - n_bfly01_im_sub[i] * fac8_1_i[phase+2];
            pre_n_im = n_bfly01_re_sub[i] * fac8_1_i[phase+2] + n_bfly01_im_sub[i] * fac8_1_r[phase+2];

            // 라운딩 및 256으로 나누기
            p_bfly01_re[i] <= (pre_p_re + 128) >>> 8;
            n_bfly01_re[i] <= (pre_n_re + 128) >>> 8;
            p_bfly01_im[i] <= (pre_p_im + 128) >>> 8;
            n_bfly01_im[i] <= (pre_n_im + 128) >>> 8;
    end
    end
end


endmodule



