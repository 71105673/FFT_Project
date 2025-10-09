`timescale 1ns/1ps

module tb_top ();

    logic clk, rst, valid;
    logic step01_cnt_valid;
    logic step02_cnt_valid;
    logic cbfp_valid;
    logic m1_valid;
    logic signed [8:0] din_re [0:15];
    logic signed [8:0] din_im [0:15];

    logic signed [9:0] bfly00_re_p [0:15];
    logic signed [9:0] bfly00_re_n [0:15];
    logic signed [9:0] bfly00_im_p [0:15];
    logic signed [9:0] bfly00_im_n [0:15];

    logic signed [12:0] bfly01_re_p [0:15];
    logic signed [12:0] bfly01_re_n [0:15];
    logic signed [12:0] bfly01_im_p [0:15];
    logic signed [12:0] bfly01_im_n [0:15];

    logic signed [22:0] bfly02_re_p [0:15];
    logic signed [22:0] bfly02_re_n [0:15];
    logic signed [22:0] bfly02_im_p [0:15];
    logic signed [22:0] bfly02_im_n [0:15];

    logic signed [10:0] dout_mux_re [0:15];
    logic signed [10:0] dout_mux_im [0:15];

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
        .cbfp_valid(cbfp_valid)
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
        .valid_in(cbfp_valid),

        .din_re_p(bfly02_re_p),
        .din_re_n(bfly02_re_n),
        .din_im_p(bfly02_im_p),
        .din_im_n(bfly02_im_n),

        .dout_mux_re(dout_mux_re),
        .dout_mux_im(dout_mux_im),
        .valid_out(m1_valid)
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
