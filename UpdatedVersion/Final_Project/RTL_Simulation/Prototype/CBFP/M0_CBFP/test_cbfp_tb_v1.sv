`timescale 1ns/1ps

module test_cbfp_tb;
    parameter cnt_size      =  5;
    parameter array_size    = 16;
    parameter din_size      = 23;
    parameter dout_size     = 11;
    parameter buffer_depth  = 64;
    parameter array_num     = 4;
    parameter total_inputs  = 512;

    logic clk, rstn, valid_in;
    logic signed [din_size-1:0] din_re_p [0:array_size-1];
    logic signed [din_size-1:0] din_re_n [0:array_size-1];


    //logic signed [dout_size-1:0] dout_re_p [0:array_size-1];
    //logic signed [dout_size-1:0] dout_re_n [0:array_size-1];

    logic signed [dout_size-1:0] dout_out_re [0:array_size-1];
    logic signed [dout_size-1:0] dout_out_im [0:array_size-1];



    logic [cnt_size-1:0] zero_cnt_p_re [0:array_num-1];
    logic [cnt_size-1:0] zero_cnt_n_re [0:array_num-1];

    logic [cnt_size-1:0] zero_cnt_p_im [0:array_num-1];
    logic [cnt_size-1:0] zero_cnt_n_im [0:array_num-1];

    integer file, r,y,  i, j;
    integer data_array [0:total_inputs-1], data_array0 [0:total_inputs-1];
    string line;

    // DUT 연결
    test_cbfp #(
        .cnt_size(cnt_size),
        .array_size(array_size),
        .din_size(din_size),
        .dout_size(dout_size),
        .buffer_depth(buffer_depth)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .din_re_p(din_re_p),
        .din_re_n(din_re_n),
        .din_im_p(din_re_n),
        .din_im_n(din_re_p),

        .dout_re(dout_out_re),
        .dout_im(dout_out_im)
    );

    // Clock generation (500MHz)
    always #1 clk = ~clk;

    initial begin
        $display("Start Simulation");

        clk = 0;
        rstn = 0;
        valid_in = 0;

        // 입력 초기화
        for (i = 0; i < array_size; i++) begin
            din_re_p[i] = 0;
            din_re_n[i] = 0;

        end

        // ===== 텍스트 파일 열기 =====
        file = $fopen("cbfp_in (2).txt", "r");
        if (file == 0) begin
            $display("Failed to open input file.");
            $finish;
        end

        // ===== 데이터 읽기 (최대 128개) =====
        for (i = 0; i < total_inputs; i++) begin
            r = $fscanf(file, "%d\n", data_array[i]);
        end
        $fclose(file);

        // ===== 텍스트 파일 열기 =====
        file = $fopen("pre_bfly02_fixed_real.txt", "r");
        if (file == 0) begin
            $display("Failed to open input file.");
            $finish;
        end

        // ===== 데이터 읽기 (최대 128개) =====
        for (i = 0; i < total_inputs; i++) begin
            r = $fscanf(file, "%d\n", data_array0[i]);
        end
        $fclose(file);

        // ===== Reset =====
        #20;
        rstn = 1;
        #10;

        // ===== Phase 2: 다음 64개 입력 (4클럭 동안 16개씩) =====
        for (i = 256; i < 320; i += 16) begin
            valid_in = 1;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = data_array[i + j];
                din_re_n[j] = data_array0[i + j];
            end
            #2;
        end

        // ===== Phase 3: 입력 없음 (4클럭 동안 모두 0) =====
        for (i = 0; i < 4; i++) begin
            valid_in = 0;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = 0;
                din_re_n[j] = 0;
            end
            #2;
        end

        // ===== Phase 3: 다음 64개 입력 (4클럭 동안 16개씩) =====
        for (i = 320; i < 384; i += 16) begin
            valid_in = 1;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = data_array[i + j];
                din_re_n[j] = data_array0[i + j];
            end
            #2;
        end

        // ===== Phase 3: 입력 없음 (4클럭 동안 모두 0) =====
        for (i = 0; i < 4; i++) begin
            valid_in = 0;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = 0;
                din_re_n[j] = 0;
            end
            #2;
        end

        // ===== Phase 3: 다음 64개 입력 (4클럭 동안 16개씩) =====
        for (i = 384; i < 448; i += 16) begin
            valid_in = 1;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = data_array[i + j];
                din_re_n[j] = data_array0[i + j];
            end
            #2;
        end

                // ===== Phase 3: 입력 없음 (4클럭 동안 모두 0) =====
        for (i = 0; i < 4; i++) begin
            valid_in = 0;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = 0;
                din_re_n[j] = 0;
            end
            #2;
        end

        // ===== Phase 3: 다음 64개 입력 (4클럭 동안 16개씩) =====
        for (i = 448; i < 512; i += 16) begin
            valid_in = 1;
            for (j = 0; j < 16; j++) begin
                din_re_p[j] = data_array[i + j];
                din_re_n[j] = data_array0[i + j];
            end
            #2;
        end

        valid_in = 0;
        #8;
        valid_in = 1;
        #8;

        valid_in = 0;
        #8;
        valid_in = 1;
        #8;

        valid_in = 0;
        #8;
        valid_in = 1;
        #8;


        // 입력 종료
        valid_in = 0;

        // ===== 추가 시뮬레이션 시간 확보 =====
        #20;

        $display("Simulation End");
        $finish;
    end
endmodule
