`timescale 1ns / 1ps


module top_module(

    input clk_p,
    input clk_n,
    input rst
);
    logic sys_rst;
    logic clk_100mhz;
    logic locked;
    logic probe_out0;

    logic signed [8:0] din_re_reg [0:15];
    logic signed [8:0] din_im_reg [0:15];
    logic valid_reg; 

    logic signed [12:0] dout_re [0:15];
    logic signed [12:0] dout_im [0:15];
    logic complete_sig;
    

    assign sys_rst = (rst & locked) | ~probe_out0;

    clk_wiz_0 CLK_GEN_100
    (
        .clk_in1_p(clk_p),
        .clk_in1_n(clk_n),
        .resetn(sys_rst),

        .clk_out1(clk_100mhz),
        .locked(locked)
    );

    cos_gen COS_GEN (
        .clk(clk_100mhz),
        .rst(sys_rst),
        .valid(valid_reg),
        .din_re(din_re_reg),
        .din_im(din_im_reg)
    );

    fft_top FFT_TOP(
        .clk(clk_100mhz),
        .rst(sys_rst),
        .valid(valid_reg),

        .din_re(din_re_reg),
        .din_im(din_im_reg),

        .dout_re(dout_re),
        .dout_im(dout_im),
        .complete_sig(complete_sig)
    );

    vio_fft VIO_FFT (
        .clk(clk_100mhz),
        // dout_re
        .probe_in0(dout_re[0]),
        .probe_in1(dout_re[1]),
        .probe_in2(dout_re[2]),
        .probe_in3(dout_re[3]),
        .probe_in4(dout_re[4]),
        .probe_in5(dout_re[5]),
        .probe_in6(dout_re[6]),
        .probe_in7(dout_re[7]),
        .probe_in8(dout_re[8]),
        .probe_in9(dout_re[9]),
        .probe_in10(dout_re[10]),
        .probe_in11(dout_re[11]),
        .probe_in12(dout_re[12]),
        .probe_in13(dout_re[13]),
        .probe_in14(dout_re[14]),
        .probe_in15(dout_re[15]),
        // dout_im
        .probe_in16(dout_im[0]),
        .probe_in17(dout_im[1]),
        .probe_in18(dout_im[2]),
        .probe_in19(dout_im[3]),
        .probe_in20(dout_im[4]),
        .probe_in21(dout_im[5]),
        .probe_in22(dout_im[6]),
        .probe_in23(dout_im[7]),
        .probe_in24(dout_im[8]),
        .probe_in25(dout_im[9]),
        .probe_in26(dout_im[10]),
        .probe_in27(dout_im[11]),
        .probe_in28(dout_im[12]),
        .probe_in29(dout_im[13]),
        .probe_in30(dout_im[14]),
        .probe_in31(dout_im[15]),
        // complete_sig
        .probe_in32(complete_sig),

        .probe_out0(probe_out0)
    );

endmodule
