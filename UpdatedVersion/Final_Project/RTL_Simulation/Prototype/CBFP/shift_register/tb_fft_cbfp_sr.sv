`timescale 1ns/1ps

module tb_cbfp_sr_64;

    // 파라미터 정의
    parameter array_size   = 16;
    parameter din_size     = 23;
    parameter buffer_depth = 64;

    // 테스트 신호 선언
    logic clk;
    logic rstn;
    logic valid_in;
    logic signed [din_size-1:0] din  [0:array_size-1];
    logic signed [din_size-1:0] dout [0:array_size-1];
    logic valid_out;

    // DUT 인스턴스화
    cbfp_sr #(
        .array_size(array_size),
        .din_size(din_size),
        .buffer_depth(buffer_depth)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din(din),
        .dout(dout),
        .valid_out(valid_out)
    );

    // 클럭 생성
    always #2 clk = ~clk;  // 500MHz

    // 초기화 및 테스트
    initial begin
        $display("Start Simulation");
        clk = 0;
        rstn = 0;
        valid_in = 0;

        // 초기 입력값
        for (int i = 0; i < array_size; i++) begin
            din[i] = 0;
        end

        // 리셋
        #20;
        rstn = 1;
        #10;

        // ===== Phase 1: 입력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(posedge clk);
            valid_in = 1;

            // 16개 입력 데이터 생성
            for (int i = 0; i < array_size; i++) begin
                din[i] = clk_phase * 100* (-1)^i + i;  // 예: 0~15, 100~115, ...
            end
        end

        // ===== Phase 2: 출력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(posedge clk);
            valid_in = 0;
            // 출력은 자동으로 발생. 출력 유효 시 표시
            if (valid_out) begin
                $display("Output clk_phase = %0d", clk_phase);
                for (int i = 0; i < array_size; i++) begin
                    $display("  dout[%0d] = %0d", i, dout[i]);
                end
            end
        end

                // ===== Phase 1: 입력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(negedge clk);
            valid_in = 1;

            // 16개 입력 데이터 생성
            for (int i = 0; i < array_size; i++) begin
                din[i] = 0;
            end
        end

                // ===== Phase 2: 출력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(negedge clk);
            valid_in = 0;
            // 출력은 자동으로 발생. 출력 유효 시 표시
            if (valid_out) begin
                $display("Output clk_phase = %0d", clk_phase);
                for (int i = 0; i < array_size; i++) begin
                    $display("  dout[%0d] = %0d", i, dout[i]);
                end
            end
        end

        // ===== Phase 1: 입력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(negedge clk);
            valid_in = 1;

            // 16개 입력 데이터 생성
            for (int i = 0; i < array_size; i++) begin
                din[i] = clk_phase * 50* (-1)^i + i;  // 예: 0~15, 100~115, ...
            end
        end

        // ===== Phase 2: 출력 4클럭 =====
        for (int clk_phase = 0; clk_phase < 4; clk_phase++) begin
            @(negedge clk);
            valid_in = 0;
            // 출력은 자동으로 발생. 출력 유효 시 표시
            if (valid_out) begin
                $display("Output clk_phase = %0d", clk_phase);
                for (int i = 0; i < array_size; i++) begin
                    $display("  dout[%0d] = %0d", i, dout[i]);
                end
            end
        end
        #4;

        // ===== 끝 =====
        @(posedge clk);
        valid_in = 0;
        $display("Simulation done");
        $finish;
    end

endmodule
