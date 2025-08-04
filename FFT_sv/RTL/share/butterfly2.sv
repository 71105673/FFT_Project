`timescale 1ns / 1ps

module butterfly2 #(
    parameter WIDTH = 16
)(
    input logic in_en,
    input logic out_en,

    input  signed [WIDTH-1:0] x0_re [0:15],
    input  signed [WIDTH-1:0] x0_im [0:15],
    input  signed [WIDTH-1:0] x1_re [0:15],
    input  signed [WIDTH-1:0] x1_im [0:15],
    output logic signed [WIDTH:0] y0_re [0:15],
    output logic signed [WIDTH:0] y0_im [0:15],
    output logic signed [WIDTH:0] y1_re [0:15],
    output logic signed [WIDTH:0] y1_im [0:15]
);

    logic signed [WIDTH-1:0] x0_re_mux [0:15];
    logic signed [WIDTH-1:0] x0_im_mux [0:15];

    logic signed [WIDTH:0] add_re [0:15];
    logic signed [WIDTH:0] add_im [0:15];
    logic signed [WIDTH:0] sub_re [0:15];
    logic signed [WIDTH:0] sub_im [0:15];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_all
            // in_en이 0이면 x0 입력을 0으로 처리
            assign x0_re_mux[i] = in_en ? x0_re[i] : '0;
            assign x0_im_mux[i] = in_en ? x0_im[i] : '0;

            assign add_re[i] = x0_re_mux[i] + x1_re[i];
            assign add_im[i] = x0_im_mux[i] + x1_im[i];
            assign sub_re[i] = x0_re_mux[i] - x1_re[i];
            assign sub_im[i] = x0_im_mux[i] - x1_im[i];

            // out_en이 0이면 y0만 0으로 출력
            assign y0_re[i] = out_en ? add_re[i] : '0;
            assign y0_im[i] = out_en ? add_im[i] : '0;

            // y1은 항상 출력
            assign y1_re[i] = sub_re[i];
            assign y1_im[i] = sub_im[i];
        end
    endgenerate

endmodule

