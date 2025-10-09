`timescale 1ns/1ps

module step0_shift_reg #(
    parameter int N   = 256,  // 총 입력 수 (16의 배수)
    parameter int FIX = 10    // 고정소수점 비트 수
) (
    input clk,
    input rst,
    input valid,
    input  logic signed [FIX-1:0] bfly_re [0:15],     // FIX비트 × 16개 입력
    output logic signed [FIX-1:0] sr_out  [0:15]      // FIX비트 × 16개 출력
);

    localparam int DEPTH = N / 16;

    logic signed [FIX-1:0] shift_din [0:DEPTH-1][0:15];

    integer i, j;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < DEPTH; i++) begin
                for (j = 0; j < 16; j++) begin
                    shift_din[i][j] <= '0;
                end
            end
        end else begin
            for (i = DEPTH-1; i > 0; i--) begin
                shift_din[i] <= shift_din[i - 1];
            end
            if (valid) begin
                shift_din[0] <= bfly_re;
            end
        end
    end

    assign sr_out = shift_din[DEPTH-1];

endmodule


module shift_reg #(
    parameter int N   = 256,  // 총 입력 수 (16의 배수)
    parameter int FIX = 10    // 고정소수점 비트 수
) (
    input  logic clk,
    input  logic rst,
    input  logic signed [FIX-1:0] bfly_re [0:15],     // FIX비트 × 16개 입력
    output logic signed [FIX-1:0] sr_out  [0:15]      // FIX비트 × 16개 출력
);

    localparam int DEPTH = N / 16;

    logic signed [FIX-1:0] shift_din [0:DEPTH-1][0:15];

    integer i, j;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < DEPTH; i++) begin
                for (j = 0; j < 16; j++) begin
                    shift_din[i][j] <= '0;
                end
            end
        end else begin
            for (i = DEPTH-1; i > 0; i--) begin
                shift_din[i] <= shift_din[i - 1];
                shift_din[0] <= bfly_re;
            end
            
        end
    end

    assign sr_out = shift_din[DEPTH-1];

endmodule

