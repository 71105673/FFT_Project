`timescale 1ns / 1ps

module delaybuffer_re #(
    parameter DEPTH = 256,
    parameter WIDTH = 10
)(
    input rstn,
    input clk,
    input  [WIDTH-1:0] di_re[0:15],
    output [WIDTH-1:0] do_re[0:15]
);

reg [WIDTH-1:0] buf_re[0:DEPTH-1];
integer n;

always @(posedge clk or negedge rstn) begin : shift_logic
    if (~rstn) begin
        for (n = 0; n < DEPTH; n = n + 1)
            buf_re[n] <= 0;
    end else begin
        for (n = DEPTH/16 - 1; n > 0; n = n - 1)
            buf_re[n*16 +: 16] <= buf_re[(n-1)*16 +: 16];
        buf_re[0+:16] <= di_re;
    end
end

assign do_re = buf_re[DEPTH-16 +: 16];

endmodule
