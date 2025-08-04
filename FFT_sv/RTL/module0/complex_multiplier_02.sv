`timescale 1ns / 1ps

module complex_multiplier_02 #(
    parameter NUM_PARALLEL_PATHS = 16,
    parameter DATA_IN_WIDTH = 13, // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [12:0])
    parameter TW_WIDTH = 9        // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
) (
    input clk,
    // 입력 데이터 비트 폭을 DATA_IN_WIDTH로 명시
    input signed [DATA_IN_WIDTH-1:0] bfly02_tmp_real_saturated [0:NUM_PARALLEL_PATHS-1],
    input signed [DATA_IN_WIDTH-1:0] bfly02_tmp_imag_saturated [0:NUM_PARALLEL_PATHS-1],

    // Twiddle Factor 비트 폭을 TW_WIDTH로 명시
    input signed [TW_WIDTH-1:0] tw_re [0:NUM_PARALLEL_PATHS-1],
    input signed [TW_WIDTH-1:0] tw_im [0:NUM_PARALLEL_PATHS-1],

    // 출력 데이터 비트 폭을 계산된 RESULT_WIDTH로 명시
    output signed [DATA_IN_WIDTH + TW_WIDTH - 1 + 1 : 0] pre_bfly02_re [0:NUM_PARALLEL_PATHS-1],
    output signed [DATA_IN_WIDTH + TW_WIDTH - 1 + 1 : 0] pre_bfly02_im [0:NUM_PARALLEL_PATHS-1]
);

    // 내부 계산을 위한 파라미터 정의 (가독성 향상)
    localparam PRODUCT_WIDTH = DATA_IN_WIDTH + TW_WIDTH; // 13 + 9 = 22
    localparam FINAL_RESULT_WIDTH = PRODUCT_WIDTH + 1;   // 22 + 1 = 23 (23비트, [22:0])

    // === Complex Multiplication with Pipelining ===
    genvar i;
    generate
        for (i = 0; i < NUM_PARALLEL_PATHS; i++) begin : parallel_path

            // 곱셈 결과 저장 레지스터 (Stage 1)
            logic signed [PRODUCT_WIDTH-1:0] ac_term_reg; // A*C
            logic signed [PRODUCT_WIDTH-1:0] bd_term_reg; // B*D
            logic signed [PRODUCT_WIDTH-1:0] ad_term_reg; // A*D
            logic signed [PRODUCT_WIDTH-1:0] bc_term_reg; // B*C

            // 덧셈/뺄셈 결과 저장 레지스터 (Stage 2)
            // FINAL_RESULT_WIDTH는 덧셈 시 발생할 수 있는 1비트 증가를 고려
            logic signed [FINAL_RESULT_WIDTH-1:0] pre_bfly02_re_reg_final;
            logic signed [FINAL_RESULT_WIDTH-1:0] pre_bfly02_im_reg_final;

            // Stage 1: 곱셈 연산 후 레지스터 저장
            always_ff @(posedge clk) begin
                ac_term_reg <= bfly02_tmp_real_saturated[i] * tw_re[i];
                bd_term_reg <= bfly02_tmp_imag_saturated[i] * tw_im[i];
                ad_term_reg <= bfly02_tmp_real_saturated[i] * tw_im[i];
                bc_term_reg <= bfly02_tmp_imag_saturated[i] * tw_re[i];
            end

            // Stage 2: 레지스터에 저장된 곱셈 결과를 사용하여 덧셈/뺄셈 후 최종 레지스터 저장
            always @(posedge clk) begin
                pre_bfly02_re_reg_final <= ac_term_reg - bd_term_reg;
                pre_bfly02_im_reg_final <= ad_term_reg + bc_term_reg;
            end

            // 최종 출력 포트에 연결
            assign pre_bfly02_re[i] = pre_bfly02_re_reg_final;
            assign pre_bfly02_im[i] = pre_bfly02_im_reg_final;

        end // for (i)
    endgenerate // generate

endmodule