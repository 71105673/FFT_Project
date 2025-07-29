`timescale 1ns / 1ps

module delay_buf #(
    parameter WIDTH = 9
)(
    input  logic clk,
    input  logic rstn,
    input  logic signed [WIDTH-1:0] din_re [0:15],
    input  logic signed [WIDTH-1:0] din_im [0:15],
    output logic signed [WIDTH-1:0] dout_re [0:15],
    output logic signed [WIDTH-1:0] dout_im [0:15]
);

    logic signed [WIDTH-1:0] buf_re [0:15];
    logic signed [WIDTH-1:0] buf_im [0:15];

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                buf_re[i] <= '0;
                buf_im[i] <= '0;
                dout_re[i] <= '0;
                dout_im[i] <= '0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                buf_re[i] <= din_re[i];
                buf_im[i] <= din_im[i];
                dout_re[i] <= buf_re[i];  // 한 클럭 뒤에 출력
                dout_im[i] <= buf_im[i];
            end
        end
    end
endmodule