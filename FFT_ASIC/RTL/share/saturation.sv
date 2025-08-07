`timescale 1ns/1ps

module saturation #(
    parameter LENGTH = 13, // 출력 비트 폭 (예: 13 -> 13비트 출력)
    parameter NUM_PARALLEL_PATHS = 16
) (
    input logic signed [LENGTH:0] bfly02_tmp_real_in [0:NUM_PARALLEL_PATHS-1], // 입력은 LENGTH + 1 비트
    input logic signed [LENGTH:0] bfly02_tmp_imag_in [0:NUM_PARALLEL_PATHS-1],
    output logic signed [LENGTH-1:0] bfly02_tmp_real_saturated [0:NUM_PARALLEL_PATHS-1], // 출력은 LENGTH 비트
    output logic signed [LENGTH-1:0] bfly02_tmp_imag_saturated [0:NUM_PARALLEL_PATHS-1]
);

    // LENGTH 파라미터를 기반으로 포화 기준 값 계산
    localparam SAT_MAX = (1 << (LENGTH - 1)) - 1; // 2^(LENGTH-1) - 1 (예: LENGTH=13 -> 4095)
    localparam SAT_MIN = -(1 << (LENGTH - 1));   // -2^(LENGTH-1) (예: LENGTH=13 -> -4096)
    // 입력 값과 비교할 임계값 (포화되지 않는 최대/최소)
    localparam THRESH_POS = (1 << (LENGTH - 1)); // 2^(LENGTH-1) (예: LENGTH=13 -> 4096)
    localparam THRESH_NEG = -(1 << (LENGTH - 1)); // -2^(LENGTH-1) (예: LENGTH=13 -> -4096)

    genvar i;
    generate
        for (i = 0; i < NUM_PARALLEL_PATHS; i++) begin : parallel_path
            // === Real Part Saturation ===
            always_comb begin
                if (bfly02_tmp_real_in[i] >= THRESH_POS) begin
                    bfly02_tmp_real_saturated[i] = SAT_MAX;
                end else if (bfly02_tmp_real_in[i] <= THRESH_NEG) begin
                    bfly02_tmp_real_saturated[i] = SAT_MIN;
                end else begin
                    bfly02_tmp_real_saturated[i] = bfly02_tmp_real_in[i];
                end
            end

            // === Imaginary Part Saturation ===
            always_comb begin
                if (bfly02_tmp_imag_in[i] >= THRESH_POS) begin
                    bfly02_tmp_imag_saturated[i] = SAT_MAX;
                end else if (bfly02_tmp_imag_in[i] <= THRESH_NEG) begin
                    bfly02_tmp_imag_saturated[i] = SAT_MIN;
                end else begin
                    bfly02_tmp_imag_saturated[i] = bfly02_tmp_imag_in[i];
                end
            end
        end
    endgenerate
endmodule

