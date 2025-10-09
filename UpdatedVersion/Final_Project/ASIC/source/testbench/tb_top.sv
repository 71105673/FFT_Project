`timescale 1ns/1ps

module tb_top ();

    logic clk, rst, valid;
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

    logic signed [8:0] din_re [0:15];
    logic signed [8:0] din_im [0:15];

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

    logic signed [12:0] dout_re [0:15];
    logic signed [12:0] dout_im [0:15];



    // 내부 변수
    integer fd_re, fd_im;
    string line_re, line_im;
    integer val_re, val_im;
    integer i, j;


    step0_0 dut_00(
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

    step0_1 dut_01(
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

    step0_2 dut_02(
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
    ) dut_03 (
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

    step1_0 dut_10(
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

    step1_1 dut_11(
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

    step1_2 dut_12(
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

    ) dut_13(
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

    step2_0 dut_20(
        .clk(clk),
        .rst(rst),
        .valid(m2_valid),
        
        .din_re(m1_out_re),
        .din_im(m1_out_im),

        .bfly20_re(bfly20_re),
        .bfly20_im(bfly20_im),
        .step20_mul_enable(step21_cnt_valid)
    );

    step2_1 dut_21 (
        .clk(clk),
        .rst(rst),
        .valid(step21_cnt_valid),
        
        .bfly20_re(bfly20_re),
        .bfly20_im(bfly20_im),
        
        .bfly21_re(bfly21_re),
        .bfly21_im(bfly21_im),
        .step21_mul_enable(step22_cnt_valid)
    );

    step2_2 dut_22 (
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

    index_reorder dut_23 (
        .clk(clk),
        .rst(rst),
        .bitget_valid(bitget_valid),

        .bfly22_re(bfly22_re),
        .bfly22_im(bfly22_im),

        .dout_re(dout_re),
        .dout_im(dout_im)
    );




    // Clock generation (500MHz => 2ns period)
    always #1 clk = ~clk;

    always @(negedge clk) begin
        if (valid) begin
            for (i = 0; i < 16; i++) begin
                if (!$feof(fd_re)) begin
                    void'($fgets(line_re, fd_re));
                    void'($sscanf(line_re, "%d", val_re));
                    din_re[i] = val_re;
                end else din_re[i] = 0;

                if (!$feof(fd_im)) begin
                    void'($fgets(line_im, fd_im));
                    void'($sscanf(line_im, "%d", val_im));
                    din_im[i] = val_im;
                end else din_im[i] = 0;
            end
        end
    end

    initial begin
        clk = 0;
        rst = 1;
        valid = 0;
        for (i = 0; i < 16; i++) begin
            din_re[i] = 0;
            din_im[i] = 0;
        end

        // 파일 열기
        fd_re = $fopen("cos_i_dat.txt", "r");
        fd_im = $fopen("cos_q_dat.txt", "r");
        if (fd_re == 0 || fd_im == 0) $fatal("파일 열기 실패.");

        // 초기화 및 reset
        #5 rst = 0;
        #5 rst = 1;
        valid = 1;
        repeat (32) @(negedge clk);
        valid = 0;
    

        // 연산 마무리 대기
        #500;

        $display("Simulation finished.");
        $finish;
    end

endmodule
