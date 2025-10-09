`timescale 1ns/1ps

module tb_fft_0 ();

    logic clk;
    logic rst;
    logic valid;

    logic signed [8:0] din_re_arr [0:15];
    logic signed [8:0] din_im_arr [0:15];

    logic signed [12:0] dout_re_arr [0:15];
    logic signed [12:0] dout_im_arr [0:15];

    logic signed [0:143] din_re;
    logic signed [0:143] din_im;

    logic [0:207] dout_re;  // output from FFT
    logic [0:207] dout_im;

    integer fd_re, fd_im;
    string line_re, line_im;
    integer val_re, val_im;
    integer i;

    // DUT 인스턴스
    fft dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .din_re(din_re),
        .din_im(din_im),
        .dout_re(dout_re),
        .dout_im(dout_im)
    );

    // Clock generation
    always #1 clk = ~clk;

    // 입력 파일에서 읽고 -> 벡터로 packing
    always @(negedge clk) begin
        if (valid) begin
            for (i = 0; i < 16; i++) begin
                if (!$feof(fd_re)) begin
                    void'($fgets(line_re, fd_re));
                    void'($sscanf(line_re, "%d", val_re));
                    din_re_arr[i] = val_re;
                end else din_re_arr[i] = 0;

                if (!$feof(fd_im)) begin
                    void'($fgets(line_im, fd_im));
                    void'($sscanf(line_im, "%d", val_im));
                    din_im_arr[i] = val_im;
                end else din_im_arr[i] = 0;
            end

            // packing (LSB에 din[0], MSB에 din[15])
            din_re = '0;
            din_im = '0;
            for (i = 0; i < 16; i++) begin
                din_re[i*9 +: 9] = din_re_arr[i];
                din_im[i*9 +: 9] = din_im_arr[i];
            end
        end
    end

    always @(*) begin
    for (i = 0; i < 16; i++) begin
        dout_re_arr[i] = dout_re[i*13 +: 13];
        dout_im_arr[i] = dout_im[i*13 +: 13];
    end
end

    initial begin
        clk = 0;
        rst = 1;
        valid = 0;
        din_re = '0;
        din_im = '0;

        fd_re = $fopen("cos_i_dat.txt", "r");
        fd_im = $fopen("cos_q_dat.txt", "r");
        if (fd_re == 0 || fd_im == 0) $fatal("파일 열기 실패.");

        #5 rst = 0;
        #5 rst = 1;

        valid = 1;
        repeat (32) @(negedge clk);
        valid = 0;

        #500;
        $display("Simulation finished.");
        $finish;
    end

endmodule

