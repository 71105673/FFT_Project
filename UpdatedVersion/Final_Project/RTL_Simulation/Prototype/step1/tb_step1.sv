

`timescale 1ns/1ps

module tb_step1;

    parameter FIX = 10;
    parameter NUM = 8;
    parameter CLK_PERIOD = 10;
    parameter N = 256;

    logic clk = 0, rst = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // 입력 신호
    logic signed [FIX-1:0] p_bfly00_re   [0:15];
    logic signed [FIX-1:0] n_bfly00_re   [0:15];
    logic signed [FIX-1:0] p_bfly00_im   [0:15];
    logic signed [FIX-1:0] n_bfly00_im   [0:15];

    // 출력 신호
    logic signed [FIX+2:0] p_bfly01_re [0:15];
    logic signed [FIX+2:0] n_bfly01_re [0:15];
    logic signed [FIX+2:0] p_bfly01_im [0:15];
    logic signed [FIX+2:0] n_bfly01_im [0:15];

    // valid 신호
    logic valid;
    integer v_cnt;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            valid <= 1'b0;
            v_cnt <= 0;
        end else if (v_cnt < 40) begin
            valid <= 1'b1;
            v_cnt <= v_cnt + 1;
        end else begin
            valid <= 1'b0;
        end
    end

    // DUT 인스턴스
    step1 #(.FIX(FIX), .NUM(NUM), .N(N)) dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .p_bfly00_re(p_bfly00_re),
        .n_bfly00_re(n_bfly00_re),
        .p_bfly00_im(p_bfly00_im),
        .n_bfly00_im(n_bfly00_im),
        .p_bfly01_re(p_bfly01_re),
        .n_bfly01_re(n_bfly01_re),
        .p_bfly01_im(p_bfly01_im),
        .n_bfly01_im(n_bfly01_im)
    );

    // 입력값 생성
    integer k;
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (k = 0; k < 16; k++) begin
                p_bfly00_re[k] <= 0;
                n_bfly00_re[k] <= 0;
                p_bfly00_im[k] <= 0;
                n_bfly00_im[k] <= 0;
            end
        end else begin
            for (k = 0; k < 16; k++) begin
                p_bfly00_re[k] <= $random % 128;
                n_bfly00_re[k] <= $random % 128;
                p_bfly00_im[k] <= $random % 128;
                n_bfly00_im[k] <= $random % 128;
            end
        end
    end

    // 시뮬레이션 초기화
    initial begin
        $display("=== step1 tb start ===");
        rst = 0;
        #(CLK_PERIOD*3);
        rst = 1;
        #(CLK_PERIOD*120);
        $finish;
    end

    // 모니터링 (출력 인덱스 0, 15 예시)
    always_ff @(posedge clk) begin
        if (rst) begin
            $display("clk=%0d, valid=%0d | p_re[0]=%0d, n_re[0]=%0d | p_im[0]=%0d, n_im[0]=%0d | p_re[15]=%0d, n_re[15]=%0d | p_im[15]=%0d, n_im[15]=%0d",
                $time/CLK_PERIOD, valid,
                p_bfly01_re[0], n_bfly01_re[0],
                p_bfly01_im[0], n_bfly01_im[0],
                p_bfly01_re[15], n_bfly01_re[15],
                p_bfly01_im[15], n_bfly01_im[15]);
        end
    end

endmodule

