`timescale 1ns/1ps

module tb_top ();

    logic clk, rst, valid;

    logic signed [8:0] din_re_reg [0:15];
    logic signed [8:0] din_im_reg [0:15];
    logic valid_reg; 

    logic signed [8:0] din_re [0:15];
    logic signed [8:0] din_im [0:15];

    logic signed [12:0] dout_re [0:15];
    logic signed [12:0] dout_im [0:15];
    logic complete_sig;

    cos_gen DUT0(
        .clk(clk),
        .rst(rst),
        .valid(valid_reg),
        .din_re(din_re_reg),
        .din_im(din_im_reg)
    );

    fft_top DUT1(
        .clk(clk),
        .rst(rst),
        .valid(valid_reg),

        .din_re(din_re_reg),
        .din_im(din_im_reg),

        .dout_re(dout_re),
        .dout_im(dout_im),
        .complete_sig(complete_sig)
    );

    // negedge clk에서 버퍼에 저장
    always_ff @(negedge clk) begin
        for (int i = 0; i < 16; i++) begin
            din_re[i] <= din_re_reg[i];
            din_im[i] <= din_im_reg[i];
        end
        valid <= valid_reg;
    end

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #10 rst = 0;
        #10 rst = 1;

        // 시뮬레이션 시간 충분히 기다리기
        #5000;

        $display("Simulation finished.");
        $finish;
    end
endmodule


