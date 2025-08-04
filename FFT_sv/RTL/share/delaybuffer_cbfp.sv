`timescale 1ns / 1ps

module delaybuffer_cbfp #(
    parameter DEPTH = 256,
    parameter WIDTH = 10
)(
    input rstn,
    input clk,
    input signed [WIDTH-1:0] di_re[0:15],
    input signed [WIDTH-1:0] di_im[0:15],
    output logic signed [WIDTH-1:0] do_re[0:15],
    output logic signed [WIDTH-1:0] do_im[0:15]
);

  reg signed [WIDTH-1:0] buf_re[0:DEPTH-1];
  reg signed [WIDTH-1:0] buf_im[0:DEPTH-1];

  // Shift Register
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (int i = 0; i < DEPTH; i++) begin
        buf_re[i] <= '0;
        buf_im[i] <= '0;
      end
    end else begin
      for (int i = DEPTH-1; i >= 16; i--) begin
        buf_re[i] <= buf_re[i-16];
        buf_im[i] <= buf_im[i-16];
      end
      for (int i = 0; i < 16; i++) begin
        buf_re[i] <= di_re[i];
        buf_im[i] <= di_im[i];
      end
    end
  end

  // Output tap
  always_comb begin
    for (int i = 0; i < 16; i++) begin
      do_re[i] = buf_re[DEPTH-16+i];
      do_im[i] = buf_im[DEPTH-16+i];
    end
  end

endmodule
