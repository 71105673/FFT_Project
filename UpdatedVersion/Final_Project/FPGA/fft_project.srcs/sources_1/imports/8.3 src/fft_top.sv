`timescale 1ns/1ps

module fft_top (
    input clk,
    input rst,
    input valid,

    input logic signed [8:0] din_re [0:15],
    input logic signed [8:0] din_im [0:15],

    output logic signed [12:0] dout_re [0:15],
    output logic signed [12:0] dout_im [0:15],
    output logic complete_sig
);

    logic step01_cnt_valid;
    logic step02_cnt_valid;
    logic cbfp0_valid;
    logic m1_valid;
    logic step11_cnt_valid;
    logic step12_cnt_valid;
    logic cbfp1_valid;
    logic m2_valid;
    logic f_out;
    logic step21_cnt_valid;
    logic step22_cnt_valid;
    logic cbfp_min_var_en;
    logic bitget_valid;

    logic signed [9:0] bfly00_re_p [0:15];
    logic signed [9:0] bfly00_re_n [0:15];
    logic signed [9:0] bfly00_im_p [0:15];
    logic signed [9:0] bfly00_im_n [0:15];

    logic signed [11:0] bfly01_re_p [0:15];
    logic signed [11:0] bfly01_re_n [0:15];
    logic signed [11:0] bfly01_im_p [0:15];
    logic signed [11:0] bfly01_im_n [0:15];

    logic signed [22:0] bfly02_re_p [0:15];
    logic signed [22:0] bfly02_re_n [0:15];
    logic signed [22:0] bfly02_im_p [0:15];
    logic signed [22:0] bfly02_im_n [0:15];


    logic [4:0] min_val0 [0:7];
    logic signed [10:0] dout_mux_re [0:15];
    logic signed [10:0] dout_mux_im [0:15];

    logic signed [11:0] bfly10_re_p [0:15];
    logic signed [11:0] bfly10_re_n [0:15];
    logic signed [11:0] bfly10_im_p [0:15];
    logic signed [11:0] bfly10_im_n [0:15];

    logic signed [13:0] bfly11_re_p [0:15];
    logic signed [13:0] bfly11_re_n [0:15];
    logic signed [13:0] bfly11_im_p [0:15];
    logic signed [13:0] bfly11_im_n [0:15];

    logic signed [24:0] bfly12_re [0:15];
    logic signed [24:0] bfly12_im [0:15];

    logic [4:0] min_val1 [0:1];
    logic signed [11:0] m1_out_re [0:15];
    logic signed [11:0] m1_out_im [0:15];

    logic signed [12:0] bfly20_re [0:15];
    logic signed [12:0] bfly20_im [0:15];

    logic signed [14:0] bfly21_re [0:15];
    logic signed [14:0] bfly21_im [0:15];

    logic unsigned [5:0] cbfp_min_var [0:1];

    logic signed [12:0] bfly22_re [0:15];
    logic signed [12:0] bfly22_im [0:15];

    step0_0 M0_0(
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .din_re(din_re),
        .din_im(din_im),
        .bfly00_re_p(bfly00_re_p),
        .bfly00_re_n(bfly00_re_n),
        .bfly00_im_p(bfly00_im_p),
        .bfly00_im_n(bfly00_im_n),
        .bfly00_mul_enable(step01_cnt_valid)
    );

    step0_1 M0_1(
        .clk(clk),
        .rst(rst),
        .valid(step01_cnt_valid),
        .bfly00_re_p(bfly00_re_p),
        .bfly00_re_n(bfly00_re_n),
        .bfly00_im_p(bfly00_im_p),
        .bfly00_im_n(bfly00_im_n),
        .bfly01_re_p(bfly01_re_p), // output <7.6>
        .bfly01_re_n(bfly01_re_n),
        .bfly01_im_p(bfly01_im_p),
        .bfly01_im_n(bfly01_im_n),
        .step1_mul_en(step02_cnt_valid)
    );

    step0_2 M0_2(
        .clk(clk),
        .rst(rst),
        .valid(step02_cnt_valid),
        .bfly01_re_p(bfly01_re_p),
        .bfly01_re_n(bfly01_re_n),
        .bfly01_im_p(bfly01_im_p),
        .bfly01_im_n(bfly01_im_n),
        .bfly02_re_p(bfly02_re_p), // output <7.6>
        .bfly02_re_n(bfly02_re_n),
        .bfly02_im_p(bfly02_im_p),
        .bfly02_im_n(bfly02_im_n),
        .cbfp_valid(cbfp0_valid)
    );

    module0_cbfp #(
        .cnt_size(5),
        .array_size(16),
        .array_num(4),
        .din_size(23),
        .dout_size(11),
        .buffer_depth(64)
    ) M0_CBFP (
        .clk(clk),
        .rstn(rst),
        .valid_in(cbfp0_valid),

        .din_re_p(bfly02_re_p),
        .din_re_n(bfly02_re_n),
        .din_im_p(bfly02_im_p),
        .din_im_n(bfly02_im_n),

        .dout_mux_re(dout_mux_re),
        .dout_mux_im(dout_mux_im),
        .valid_out(m1_valid),
        .min_val0(min_val0),
        .f_out(f_out)
    );

    step1_0 M1_0(
        .clk(clk),
        .rst(rst),
        .valid(m1_valid),
        .din_re(dout_mux_re),
        .din_im(dout_mux_im),
        .bfly10_re_p(bfly10_re_p),
        .bfly10_re_n(bfly10_re_n),
        .bfly10_im_p(bfly10_im_p),
        .bfly10_im_n(bfly10_im_n),
        .bfly10_mul_enable(step11_cnt_valid)
    );

    step1_1 M1_1(
        .clk(clk),
        .rst(rst),
        .valid(step11_cnt_valid), // Shift Register 128 valid signal
        .bfly10_re_p(bfly10_re_p), // input <4.6>
        .bfly10_re_n(bfly10_re_n),
        .bfly10_im_p(bfly10_im_p),
        .bfly10_im_n(bfly10_im_n),

        .bfly11_re_p(bfly11_re_p), // output <7.6>
        .bfly11_re_n(bfly11_re_n),
        .bfly11_im_p(bfly11_im_p),
        .bfly11_im_n(bfly11_im_n),
        .step1_mul_en(step12_cnt_valid)
    );

    step1_2 M1_2(
        .clk(clk),
        .rst(rst),
        .valid(step12_cnt_valid),
        .bfly11_re_p(bfly11_re_p), // input <9.7>
        .bfly11_re_n(bfly11_re_n),
        .bfly11_im_p(bfly11_im_p),
        .bfly11_im_n(bfly11_im_n),

        .bfly12_re(bfly12_re),
        .bfly12_im(bfly12_im),
        .cbfp_valid(cbfp1_valid)
    );

    module1_cbfp #(
        .cnt_size(5),
        .array_size(16),
        .array_num(4),
        .din_size(25),
        .dout_size(12),
        .buffer_depth(64)

    ) M1_CBFP (
        .clk(clk),
        .rstn(rst),
        .valid_in(cbfp1_valid),

        .din_re(bfly12_re),    //real {pp, pn} -> {np, nn}
        .din_im(bfly12_im),    //img  {pp, pn} -> {np, nn}

        .dout_re(m1_out_re),  //real {pp, pn} -> {np, nn}
        .dout_im(m1_out_im),  //img  {pp, pn} -> {np, nn}

        .valid_out(m2_valid),
        .min_val1(min_val1)
        //output logic [4:0] min_val2 [0:511]
    );

    index_sum dut_idx(
        .clk(clk),
        .rst(rst),
        .valid(m2_valid),
        .tx_start(cbfp_min_var_en),

        .cbfp0_index(min_val0),
        .cbfp1_index(min_val1),

        .cbfp_min_var(cbfp_min_var)
    );

    step2_0 M2_0(
        .clk(clk),
        .rst(rst),
        .valid(m2_valid),
        
        .din_re(m1_out_re),
        .din_im(m1_out_im),

        .bfly20_re(bfly20_re),
        .bfly20_im(bfly20_im),
        .step20_mul_enable(step21_cnt_valid)
    );

    step2_1 M2_1 (
        .clk(clk),
        .rst(rst),
        .valid(step21_cnt_valid),
        
        .bfly20_re(bfly20_re),
        .bfly20_im(bfly20_im),
        
        .bfly21_re(bfly21_re),
        .bfly21_im(bfly21_im),
        .step21_mul_enable(step22_cnt_valid)
    );

    step2_2 M2_2 (
        .clk(clk),
        .rst(rst),
        .valid(step22_cnt_valid),
        
        .cbfp_min_var(cbfp_min_var),
        .bfly21_re(bfly21_re),
        .bfly21_im(bfly21_im),

        .bfly22_re(bfly22_re),
        .bfly22_im(bfly22_im),
        .step22_add_sub_enable(cbfp_min_var_en),
        .step22_arrangement(bitget_valid)
    );

    index_reorder REORDER (
        .clk(clk),
        .rst(rst),
        .bitget_valid(bitget_valid),

        .bfly22_re(bfly22_re),
        .bfly22_im(bfly22_im),

        .dout_re(dout_re),
        .dout_im(dout_im),
        .complete_sig(complete_sig)
    );

    
endmodule