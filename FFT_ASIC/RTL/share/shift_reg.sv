`timescale 1ns / 1ps

module shift_reg #(
    parameter WIDTH = 9,
    parameter DELAY_LENGTH = 16
)(
    input clk,
    input rstn,

    input signed [WIDTH-1:0] data_in_real [15:0],
    input signed [WIDTH-1:0] data_in_imag [15:0],

    output logic signed [WIDTH-1:0] data_out_real [15:0],
    output logic signed [WIDTH-1:0] data_out_imag [15:0]
);

    reg signed [WIDTH-1:0] shift_din_real [DELAY_LENGTH-1:0][15:0];
    reg signed [WIDTH-1:0] shift_din_imag [DELAY_LENGTH-1:0][15:0];

    integer i, j;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < DELAY_LENGTH; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    shift_din_real[i][j] <= 0;
                    shift_din_imag[i][j] <= 0;
                end
            end
            for (j = 0; j < 16; j = j + 1) begin
                data_out_real[j] <= 0;
                data_out_imag[j] <= 0;
            end
        end else begin
            // 출력 시점 한 클럭 빨리: DELAY_LENGTH-2 사용
            data_out_real <= shift_din_real[DELAY_LENGTH-2];
            data_out_imag <= shift_din_imag[DELAY_LENGTH-2];

            for (i = DELAY_LENGTH-1; i > 0; i = i - 1) begin
                shift_din_real[i] <= shift_din_real[i-1];
                shift_din_imag[i] <= shift_din_imag[i-1];
            end

            shift_din_real[0] <= data_in_real;
            shift_din_imag[0] <= data_in_imag;
        end
    end

endmodule

