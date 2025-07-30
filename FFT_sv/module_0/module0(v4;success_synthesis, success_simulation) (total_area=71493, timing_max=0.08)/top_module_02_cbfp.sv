
`timescale 1ns / 1ps

module top_module_02_cbfp #(
    parameter NUM_PARALLEL_PATHS = 16,
    parameter OWIDTH = 11,
    parameter BLOCK_SIZE = 512, // 총 데이터 블록 크기 (512 포인트 FFT로 변경)
    parameter DATA_IN_WIDTH = 13, // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [12:0])
    parameter TW_WIDTH = 9 ,      // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
    parameter TW_TABLE_DEPTH = 512 // Twiddle Factor ROM 깊이
) (
    input clk,
    input rst_n,
    input di_en_saturation, // FFT 시작/진행을 제어하는 enable 신호

    input signed [DATA_IN_WIDTH:0] bfly02_tmp_real_in [0:NUM_PARALLEL_PATHS-1], 
    input signed [DATA_IN_WIDTH:0] bfly02_tmp_imag_in [0:NUM_PARALLEL_PATHS-1],

    output signed [OWIDTH-1:0] do_re [0:NUM_PARALLEL_PATHS-1], // NUM_PARALLEL_PATHS 사용
    output signed [OWIDTH-1:0] do_im [0:NUM_PARALLEL_PATHS-1], // NUM_PARALLEL_PATHS 사용
    output do_en,
    output [4:0] do_index [0:NUM_PARALLEL_PATHS-1] // NUM_PARALLEL_PATHS 사용
);
    // 신호
    // 구문 오류 수정: 콤마(,) -> 세미콜론(;)
    // 곱셈 결과는 입력 비트폭 + Twiddle Factor 비트폭이므로, 13+9=22. Signed이므로 [21:0] 22비트.
    // cbfp의 WIDTH가 23인 것을 감안하여 [DATA_IN_WIDTH + TW_WIDTH : 0] = [13+9 : 0] = [22:0] (23비트)으로 선언
    logic signed [DATA_IN_WIDTH + TW_WIDTH : 0] pre_bfly02_re [0:NUM_PARALLEL_PATHS-1]; 
    logic signed [DATA_IN_WIDTH + TW_WIDTH : 0] pre_bfly02_im [0:NUM_PARALLEL_PATHS-1];

    logic fft_done; 

    // ============= 내부 신호 선언 ==============
    // saturation 모듈 출력을 위한 와이어 배열 (DATA_IN_WIDTH가 13이면 [12:0] (13비트)으로 변경)
    // 원래 DATA_IN_WIDTH를 13으로 넘기므로, -1은 필요 없음. 13비트 폭이면 [12:0]
    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_real_saturated [0:NUM_PARALLEL_PATHS-1];
    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_imag_saturated [0:NUM_PARALLEL_PATHS-1];

    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_real_saturated_buf [0:NUM_PARALLEL_PATHS-1];
    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_imag_saturated_buf [0:NUM_PARALLEL_PATHS-1];

    // Twiddle Factor 주소 및 데이터 출력을 위한 와이어 배열
    localparam ADDR_WIDTH = $clog2(TW_TABLE_DEPTH); 
    logic [ADDR_WIDTH-1:0] tw_addr [0:NUM_PARALLEL_PATHS-1];
    logic signed [TW_WIDTH-1:0] tw_re_out [0:NUM_PARALLEL_PATHS-1];
    logic signed [TW_WIDTH-1:0] tw_im_out [0:NUM_PARALLEL_PATHS-1];

    // FFT 진행 제어를 위한 카운터 및 상태 변수
    localparam NUM_CHUNKS = BLOCK_SIZE / NUM_PARALLEL_PATHS; // 512 / 16 = 32로 변경
    logic [$clog2(NUM_CHUNKS)-1:0] chunk_idx; // 현재 처리 중인 16개 데이터 묶음의 인덱스 (0에서 31까지)
    logic di_en; // di_en_saturation의 레지스터 버전 (안정성)
    
    // FFT 완료 신호
    logic done_chunk; // 내부 fft_done 레지스터

    // ============= FFT 제어 로직 및 주소 생성 ==============
    // di_en_saturation의 이전 값 (FFT 시작 엣지 검출용)
    logic di_en_saturation_d1; 
    assign fft_done = done_chunk; 

    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            chunk_idx     <= 0; 
            di_en <= 0;      // 0으로 리셋 [cite: 16]
            done_chunk  <= 0; 
            di_en_saturation_d1 <= 0; 
        end else begin
            // di_en_saturation_d1은 di_en_saturation를 한 클럭 지연시킨 값
            di_en_saturation_d1 <= di_en_saturation; 
            // FFT 시작 조건: di_en_saturation가 0->1로 전이될 때 (현재 1이고 이전 클럭에서 0이었다면)
            if (di_en_saturation && !di_en_saturation_d1) begin // 이것이 상승 에지 검출입니다. [cite: 20]
                chunk_idx     <= 0; 
                done_chunk  <= 0; 
                di_en <= 1; 
            end
            // FFT 진행 중: di_en_saturation가 1이고, fft_done이 아직 1이 아닐 때
            else if (di_en_saturation && !done_chunk) begin
                if (chunk_idx == NUM_CHUNKS - 1) begin // 마지막 청크까지 처리 완료
                    chunk_idx     <= 0; 
                    done_chunk  <= 1; 
                    di_en <= 0; 
                end else begin
                    chunk_idx <= chunk_idx + 1; 
                    done_chunk <= 0; 
                    di_en <= 1; // 계속 진행 중임을 나타냄 
                end
            end
            // FFT 완료 후 di_en_saturation가 0이 되면 리셋
            else if (!di_en_saturation && done_chunk) begin
                done_chunk  <= 0; 
                di_en <= 0; // 리셋 
            end
            // di_en_saturation가 0이고 done_chunk가 0인 경우, 또는 done_chunk가 1인 상태에서 di_en_saturation가 1로 유지되는 경우
            // 다른 조건에 해당하지 않으면 값 유지
            else begin
                di_en <= di_en; 
                done_chunk <= done_chunk; 
            end
        end
    end


    // ============= 모듈 인스턴스화 및 연결 ==============
    saturation #(
    .LENGTH(DATA_IN_WIDTH),    // LENGTH 파라미터를 13으로 설정 (DATA_IN_WIDTH 사용)
    .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS) // NUM_PARALLEL_PATHS 파라미터 사용
    ) SATURATION_13(
        .bfly02_tmp_real_in(bfly02_tmp_real_in),
        .bfly02_tmp_imag_in(bfly02_tmp_imag_in),
        .bfly02_tmp_real_saturated(bfly02_tmp_real_saturated),
        .bfly02_tmp_imag_saturated(bfly02_tmp_imag_saturated)
    );

    delaybuffer_cbfp #(.DEPTH(32), .WIDTH(13)) SAT_BUF_1CLK (
        .rstn (rst_n),
        .clk  (clk),
        .di_re(bfly02_tmp_real_saturated),
        .di_im(bfly02_tmp_imag_saturated),
        .do_re(bfly02_tmp_real_saturated_buf),
        .do_im(bfly02_tmp_imag_saturated_buf)
    );


    // logic [4:0] tw_counter;
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if(~rst_n) begin // Active-low reset (rst_n)
    //         tw_counter <= 5'd0; // 0으로 리셋
    //     end else begin
    //         if (tw_counter == 5'd31) begin
    //             tw_counter <= 5'd0; 
    //         end else begin
    //             tw_counter <= tw_counter + 5'd1; 
    //         end
    //     end
    // end

        
    // Twiddle Factor 주소 생성 (조합 로직)
    always_comb begin
        for (int k = 0; k < NUM_PARALLEL_PATHS; k++) begin
            tw_addr[k] = (chunk_idx * NUM_PARALLEL_PATHS) + k;
        end
    end

    genvar t;
    for (t=0 ;t<16;t++) begin
        twiddle_512 #(
            .WIDTH(TW_WIDTH),       // Twiddle Factor 데이터 비트 폭 (예: [WIDTH-1:0] = [8:0])
            .TW_TABLE_DEPTH(TW_TABLE_DEPTH), // 고유한 Twiddle Factor의 총 개수 (ROM 깊이)
            .TW_FF(1),             // 출력 레지스터 사용 여부 (1: 사용, 0: 미사용)
            .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS) // 추가된 파라미터 전달
        ) TWIDDLE_512(
            .clk(clk),  
            .addr(tw_addr[t]), 
            .tw_re(tw_re_out[t]),
            .tw_im(tw_im_out[t])
        );
    end

    complex_multiplier_02 #(
    .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS),
    .DATA_IN_WIDTH(DATA_IN_WIDTH), // 버터플라이 연산 결과의 비트 폭 
    .TW_WIDTH(TW_WIDTH)      // Twiddle Factor의 비트 폭 
    ) C_MULTIPLIER_02( 
        .clk(clk),
        // 입력 데이터 비트 폭을 DATA_IN_WIDTH로 명시
        .bfly02_tmp_real_saturated(bfly02_tmp_real_saturated_buf), 
        .bfly02_tmp_imag_saturated(bfly02_tmp_imag_saturated_buf), 

        // Twiddle Factor 비트 폭을 TW_WIDTH로 명시
        .tw_re(tw_re_out),
        .tw_im(tw_im_out), 

        // 출력 데이터 비트 로 명시
        .pre_bfly02_re(pre_bfly02_re),
        .pre_bfly02_im(pre_bfly02_im)
    );
    
    logic di_en_bf1, di_en_bf2, di_en_bf3;
    logic [4:0] di_count;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        di_en_bf1 <= 1'b0;
        di_en_bf2 <= 1'b0;
        di_en_bf3 <= 1'b0;
    end else begin
        di_en_bf1 <= di_en;        // 첫 번째 클럭 지연
        di_en_bf2 <= di_en_bf1;    // 두 번째 클럭 지연
        di_en_bf3 <= di_en_bf2;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        di_count <= 'h0;
    end else begin
        di_count <= di_en_bf3 ? (di_count + 1'b1) : 'h0;
    end
end
    cbfp #(
    .WIDTH(DATA_IN_WIDTH + TW_WIDTH + 1), // pre_bfly02_re/im의 실제 폭과 일치하도록 (23비트)
    .OWIDTH(OWIDTH)
    ) CBFP_0(
    .clk(clk),
    .rstn(rst_n),

    .di_re(pre_bfly02_re),
    .di_im(pre_bfly02_im),
    .di_en(di_en_bf3), // FFT 완료 시점에 CBFP를 enable

    .do_re(do_re),
    .do_im(do_im),
    .do_en(do_en),
    .do_index(do_index)
    );

endmodule