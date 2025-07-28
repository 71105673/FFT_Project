`timescale 1ns / 1ps

module top_module_02 #(
    parameter NUM_PARALLEL_PATHS = 16,
    parameter DATA_IN_WIDTH = 13, // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [12:0])
    parameter TW_WIDTH = 9 ,      // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
    parameter TW_TABLE_DEPTH = 512
) (
    input logic clk,
    input logic rst_n,
    input logic enable_fft, // FFT 시작/진행을 제어하는 이네이블 신호

    input logic signed [DATA_IN_WIDTH:0] bfly02_tmp_real_in [NUM_PARALLEL_PATHS-1:0], 
    input logic signed [DATA_IN_WIDTH:0] bfly02_tmp_imag_in [NUM_PARALLEL_PATHS-1:0],

    output logic signed [DATA_IN_WIDTH + TW_WIDTH - 1 + 1 : 0] pre_bfly02_re [NUM_PARALLEL_PATHS-1:0],
    output logic signed [DATA_IN_WIDTH + TW_WIDTH - 1 + 1 : 0] pre_bfly02_im [NUM_PARALLEL_PATHS-1:0]
);

    // === 내부 와이어 선언 ===
    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_real_saturated [NUM_PARALLEL_PATHS-1:0];
    logic signed [DATA_IN_WIDTH-1:0] bfly02_tmp_imag_saturated [NUM_PARALLEL_PATHS-1:0];

    logic signed [TW_WIDTH-1:0] tw_re_out [NUM_PARALLEL_PATHS-1:0]; // twiddle_512의 출력
    logic signed [TW_WIDTH-1:0] tw_im_out [NUM_PARALLEL_PATHS-1:0]; // twiddle_512의 출력

    // Twiddle Factor 주소 와이어 선언
    // $clog2(TW_TABLE_DEPTH)는 addr 비트 폭을 계산 (예: $clog2(512) = 9)
    logic [$clog2(TW_TABLE_DEPTH)-1:0] tw_addr [NUM_PARALLEL_PATHS-1:0];


    // === Twiddle Factor 주소 생성 로직 (MATLAB 코드의 kk, nn, K3 매핑) ===

    // MATLAB K3 배열을 Verilog 상수로 선언
    // K3 = [0, 4, 2, 6, 1, 5, 3, 7]; (인덱스는 0부터 시작하도록 조정)
    localparam [3:0] K3_VALS [0:7] = {4'd0, 4'd4, 4'd2, 4'd6, 4'd1, 4'd5, 4'd3, 4'd7}; // K3(1) -> K3_VALS[0], K3(8) -> K3_VALS[7]

    // === 컨트롤러 레지스터 ===
    // 'kk' 루프를 위한 카운터 (0 ~ 7, 총 8단계)
    reg [2:0] kk_counter; // $clog2(8) = 3 bits
    // 'nn' 루프를 위한 카운터 (0 ~ 63, 총 64단계. 16개씩 처리하므로 4단계 필요)
    reg [2:0] nn_block_counter; // 64 / 16 = 4단계 -> $clog2(4) = 2 bits (0~3)

    // 전체 FFT 연산의 완료 신호
    reg fft_done_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            kk_counter <= 3'd0;
            nn_block_counter <= 3'd0;
            fft_done_reg <= 1'b0;
        end else if (enable_fft) begin // enable_fft 신호가 1일 때만 진행
            fft_done_reg <= 1'b0; // 연산 시작 시 초기화

            // nn_block_counter 업데이트 (0 -> 1 -> 2 -> 3 -> 0 ... )
            if (nn_block_counter == (64/NUM_PARALLEL_PATHS - 1)) begin // 64/16 - 1 = 3
                nn_block_counter <= 3'd0;
                // kk_counter 업데이트 (0 -> 1 -> ... -> 7 -> 0 ...)
                if (kk_counter == (8 - 1)) begin // 7
                    kk_counter <= 3'd0;
                    fft_done_reg <= 1'b1; // 모든 스테이지/블록 완료
                end else begin
                    kk_counter <= kk_counter + 3'd1;
                end
            end else begin
                nn_block_counter <= nn_block_counter + 3'd1;
            end
        end
    end

    // fft_done 출력
    assign fft_done = fft_done_reg;

    // === Twiddle Factor 주소 계산 (조합 로직) ===
    // MATLAB: idx = (kk-1)*64 + nn;
    // (kk-1) -> kk_counter
    // (nn-1) -> (nn_block_counter * NUM_PARALLEL_PATHS) + i_parallel (where i_parallel is 0 to 15)
    // K3(kk) -> K3_VALS[kk_counter]

    genvar i_parallel;
    generate
        for (i_parallel = 0; i_parallel < NUM_PARALLEL_PATHS; i_parallel++) begin : gen_tw_addr_calc
            // 현재 병렬 경로에 해당하는 'nn' 값을 계산 (0-based)
            localparam NN_OFFSET_PER_PATH = i_parallel; // 각 병렬 경로의 상대적인 nn 오프셋

            // MATLAB 코드의 nn 값을 하드웨어에 맞게 0-base로 변환
            // nn_loop_val = (nn_block_counter * NUM_PARALLEL_PATHS) + NN_OFFSET_PER_PATH; // 0~63
            // MATLAB nn은 1-base이므로, nn_loop_val_1base = nn_loop_val + 1

            // Twiddle Factor 인덱스 계산 (MATLAB: (nn-1)*(K3(kk))/512)
            // K3_val: 현재 kk_counter에 해당하는 K3 값
            logic [3:0] K3_val;
            assign K3_val = K3_VALS[kk_counter];

            // twiddle_idx_base: (nn-1) 부분
            logic [5:0] nn_base_idx_0based; // 0~63
            assign nn_base_idx_0based = (nn_block_counter * NUM_PARALLEL_PATHS) + NN_OFFSET_PER_PATH;

            // 최종 addr 계산 (MATLAB 식을 Verilog에 맞게 변환)
            // (nn-1) * K3(kk) / 512
            // 분모 512는 주소 계산 후의 스케일링으로 보임.
            // tw_addr는 0~511 값을 가져야 하므로, 최종 결과가 이 범위 안에 들어와야 함.
            // MATLAB: flo_twf_m0((kk-1)*64+nn) = exp(-j*2*pi*(nn-1)*(K3(kk))/512);
            // 실제 Twiddle ROM 주소는 (kk-1)*64+nn 에 해당함.
            // 아니면 (nn-1)*(K3(kk))/512 가 ROM 인덱스에 들어감. (이 경우가 더 합리적)

            // MATLAB 코드의 주석: "flo_twf_m0((kk-1)*64+nn)" 이 인덱스.
            // 그리고 "twf_m0((kk-1)*64+nn)" 에 값이 저장됨.
            // => twiddle_512 모듈의 addr에 직접 들어가는 값은 (kk-1)*64 + (nn-1) 형태가 되어야 함.
            // (nn-1)은 0부터 63까지
            // (kk-1)은 0부터 7까지
            assign tw_addr[i_parallel] = (kk_counter * 64) + nn_base_idx_0based;
            // 예시: kk_counter=0, nn_block_counter=0, i_parallel=0 => tw_addr[0] = 0*64 + 0 = 0
            // 예시: kk_counter=0, nn_block_counter=0, i_parallel=15 => tw_addr[15] = 0*64 + 15 = 15
            // 예시: kk_counter=0, nn_block_counter=1, i_parallel=0 => tw_addr[0] = 0*64 + 16 = 16
            // ...
            // 예시: kk_counter=7, nn_block_counter=3, i_parallel=15 => tw_addr[15] = 7*64 + (3*16+15) = 448 + 63 = 511
        end
    endgenerate



    // ============= 모듈 인스턴스화 및 연결 ==============
    saturation #(
    .LENGTH(13),             // LENGTH 파라미터를 13으로 설정
    .NUM_PARALLEL_PATHS(16)  // NUM_PARALLEL_PATHS 파라미터를 16으로 설정
    ) SATURATION_13(
        .bfly02_tmp_real_in(bfly02_tmp_real_in),
        .bfly02_tmp_imag_in(bfly02_tmp_imag_in),
        .bfly02_tmp_real_saturated(bfly02_tmp_real_saturated),
        .bfly02_tmp_imag_saturated(bfly02_tmp_imag_saturated)
    );

    twiddle_512 #(
    .WIDTH(9),          // Twiddle Factor 데이터 비트 폭 (예: [WIDTH-1:0] = [8:0])
    .TW_TABLE_DEPTH(512), // 고유한 Twiddle Factor의 총 개수 (ROM 깊이)
    .TW_FF(1),          // 출력 레지스터 사용 여부 (1: 사용, 0: 미사용)
    .NUM_PARALLEL_PATHS(16)
    ) TWIDDLE_512(
        .clk(clk),  
        .addr(tw_addr), 
        .tw_re(tw_re_out),
        .tw_im(tw_im_out)
    );

    complex_multiplier_02 #(
    .NUM_PARALLEL_PATHS(16),
    .DATA_IN_WIDTH(13), // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [12:0])
    .TW_WIDTH(9)        // Twiddle Factor의 비트 폭 (예: 9이면 [8:0]).) 
    ) C_MULTIPLIER_02( 
        .clk(clk),
        // 입력 데이터 비트 폭을 DATA_IN_WIDTH로 명시
        .bfly02_tmp_real_saturated(bfly02_tmp_real_saturated), 
        .bfly02_tmp_imag_saturated(bfly02_tmp_imag_saturated), 

        // Twiddle Factor 비트 폭을 TW_WIDTH로 명시
        .tw_re(tw_re_out),
        .tw_im(tw_im_out), 

        // 출력 데이터 비트 로 명시
        .pre_bfly02_re(pre_bfly02_re),
        .pre_bfly02_im(pre_bfly02_im)
    );

endmodule