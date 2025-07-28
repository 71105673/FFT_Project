`timescale 1ns / 1ps

module top_module_02_cbfp_tb;

    // ============= Parameters for top_module_02 (Must match the DUT) ==============
    parameter NUM_PARALLEL_PATHS = 16;
    parameter OWIDTH = 11; // top_module_02에 OWIDTH 파라미터 추가됨
    parameter BLOCK_SIZE = 512; // 총 데이터 블록 크기 (512 포인트 FFT로 변경)
    parameter DATA_IN_WIDTH = 13; // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [12:0])
    parameter TW_WIDTH = 9 ; // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
    parameter TW_TABLE_DEPTH = 512; // Twiddle Factor ROM 깊이

    // ============= Testbench Specific Local Parameters ==============
    localparam NUM_CHUNKS = BLOCK_SIZE / NUM_PARALLEL_PATHS; // 512 / 16 = 32
    localparam TOTAL_DATA_POINTS = BLOCK_SIZE; // 총 데이터 포인트 수 (BLOCK_SIZE와 동일)

    // ============= Testbench Signals (Inputs to DUT) ==============
    logic clk;
    logic rst_n;
    logic enable_fft;

    // DUT 입력과 동일한 비트 폭으로 선언
    logic signed [DATA_IN_WIDTH:0] bfly02_tmp_real_in [0:NUM_PARALLEL_PATHS-1];
    logic signed [DATA_IN_WIDTH:0] bfly02_tmp_imag_in [0:NUM_PARALLEL_PATHS-1];

    // ============= Testbench Signals (Outputs from DUT) ==============
    // top_module_02의 최종 출력 포트에 맞춰 선언
    logic signed [OWIDTH-1:0] do_re [0:NUM_PARALLEL_PATHS-1];
    logic signed [OWIDTH-1:0] do_im [0:NUM_PARALLEL_PATHS-1];
    logic do_en;
    logic [4:0] do_index [0:NUM_PARALLEL_PATHS-1];
    
    // logic fft_done; // 이 선언은 DUT의 외부 포트가 아니므로 제거합니다.

    // ============= Internal Testbench Data Storage (하드코딩된 데이터 저장용) ==============
    // FFT 전체 블록의 데이터를 저장할 배열 (실수부와 허수부)
    // TOTAL_DATA_POINTS (512) 크기로 선언
    logic signed [DATA_IN_WIDTH:0] test_data_real[0:TOTAL_DATA_POINTS-1];
    logic signed [DATA_IN_WIDTH:0] test_data_imag[0:TOTAL_DATA_POINTS-1];

    // ============= DUT Instance ==============
    top_module_02_cbfp #(
        .NUM_PARALLEL_PATHS(NUM_PARALLEL_PATHS),
        .OWIDTH(OWIDTH), // OWIDTH 파라미터 전달
        .BLOCK_SIZE(BLOCK_SIZE),
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .TW_WIDTH(TW_WIDTH),
        .TW_TABLE_DEPTH(TW_TABLE_DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable_fft(enable_fft),
        .bfly02_tmp_real_in(bfly02_tmp_real_in),
        .bfly02_tmp_imag_in(bfly02_tmp_imag_in),
        // top_module_02의 최종 출력 포트 연결
        .do_re(do_re),
        .do_im(do_im),
        .do_en(do_en),
        .do_index(do_index)
        // .fft_done(fft_done) // <--- 이 연결 라인을 제거했습니다.
    );

    // ============= Clock Generation ==============
    localparam CLK_PERIOD = 10ns; // 100 MHz clock
    always begin
        clk = 0;
        #(CLK_PERIOD / 2);
        clk = 1;
        #(CLK_PERIOD / 2);
    end

    // ============= Test Sequence ==============
    initial begin
        integer data_idx_for_array_init; // test_data 배열 초기화용 인덱스
        integer data_idx; // DUT에 데이터 할당용 인덱스
        integer current_addr_display; // 로그 출력을 위한 가상 주소 (사용자 예시 'addr'에 대응)

        // --- 0. 하드코딩된 입력 데이터 초기화 ---
        // test_data_real과 test_data_imag 배열에 직접 값을 할당합니다.
        // 여기에 원하는 모든 BLOCK_SIZE (512)개의 데이터 포인트를 채워 넣을 수 있습니다.
        // 모든 test_data_real과 test_data_imag를 0으로 초기화
        for (data_idx_for_array_init = 0; data_idx_for_array_init < 255; data_idx_for_array_init++) begin
            test_data_real[data_idx_for_array_init] = 0;
            test_data_imag[data_idx_for_array_init] = 0;
        end

        // 255번 인덱스부터 사용자 예시 값 할당 (사용자 예시의 'addr' 255부터 시작)
        // test_data_real[배열 인덱스] = 값;
        // test_data_imag[배열 인덱스] = 값;
        // 'addr' 값은 단순히 인덱스와 관련하여 로그 출력을 위한 것이며, 실제 메모리 주소는 아닙니다.
        test_data_real[256] = 254; test_data_imag[256] = 0; 
        test_data_real[257] = 257; test_data_imag[257] = 3;
        test_data_real[258] = 255; test_data_imag[258] = 7;
        test_data_real[259] = 257; test_data_imag[259] = 8;
        test_data_real[260] = 255; test_data_imag[260] = 12;
        test_data_real[261] = 255; test_data_imag[261] = 16;
        test_data_real[262] = 255; test_data_imag[262] = 18;
        test_data_real[263] = 255; test_data_imag[263] = 21;
        test_data_real[264] = 255; test_data_imag[264] = 23;
        test_data_real[265] = 255; test_data_imag[265] = 28;
        test_data_real[266] = 254; test_data_imag[266] = 32;
        test_data_real[267] = 253; test_data_imag[267] = 35;
        test_data_real[268] = 252; test_data_imag[268] = 36;
        test_data_real[269] = 252; test_data_imag[269] = 41;
        test_data_real[270] = 252; test_data_imag[270] = 43; 
        test_data_real[271] = 252; test_data_imag[271] = 48;

        // 두 번째 청크 시작 (사용자 예시의 'addr' 272부터 시작)
        test_data_real[272] = 252;  test_data_imag[272] = 48;
        test_data_real[273] = 252;  test_data_imag[273] = 53;
        test_data_real[274] = 248;  test_data_imag[274] = 56;
        test_data_real[275] = 248;  test_data_imag[275] = 58;
        test_data_real[276] = 248;  test_data_imag[276] = 63;
        test_data_real[277] = 247;  test_data_imag[277] = 65;
        test_data_real[278] = 248;  test_data_imag[278] = 68;
        test_data_real[279] = 245;  test_data_imag[279] = 71;
        test_data_real[280] = 244;  test_data_imag[280] = 75;
        test_data_real[281] = 244;  test_data_imag[281] = 78;
        test_data_real[282] = 244;  test_data_imag[282] = 80;
        test_data_real[283] = 244;  test_data_imag[283] = 84;
        test_data_real[284] = 240;  test_data_imag[284] = 88;
        test_data_real[285] = 240;  test_data_imag[285] = 88;
        test_data_real[286] = 240;  test_data_imag[286] = 93; 
        test_data_real[287] = 237;  test_data_imag[287] = 96;

        // 세 번째 청크 시작 (사용자 예시의 'addr' 288부터 시작)
        test_data_real[288] = 235;  test_data_imag[288] = 97;
        test_data_real[289] = 235;  test_data_imag[289] = 99;
        test_data_real[290] = 235;  test_data_imag[290] = 104;
        test_data_real[291] = 232;  test_data_imag[291] = 108;
        test_data_real[292] = 232;  test_data_imag[292] = 108;
        test_data_real[293] = 232;  test_data_imag[293] = 113;
        test_data_real[294] = 229;  test_data_imag[294] = 116;
        test_data_real[295] = 227;  test_data_imag[295] = 117;
        test_data_real[296] = 225;  test_data_imag[296] = 119;
        test_data_real[297] = 224;  test_data_imag[297] = 123;
        test_data_real[298] = 224;  test_data_imag[298] = 128;
        test_data_real[299] = 220;  test_data_imag[299] = 129;
        test_data_real[300] = 220;  test_data_imag[300] = 131;
        test_data_real[301] = 217;  test_data_imag[301] = 134;
        test_data_real[302] = 215;  test_data_imag[302] = 136; 
        test_data_real[303] = 215;  test_data_imag[303] = 141;

        // 네 번째 청크 시작 (사용자 예시의 'addr' 304부터 시작)
        test_data_real[304] = 212;  test_data_imag[304] = 144;
        test_data_real[305] = 212;  test_data_imag[305] = 144;
        test_data_real[306] = 209;  test_data_imag[306] = 148;
        test_data_real[307] = 207;  test_data_imag[307] = 149;
        test_data_real[308] = 204;  test_data_imag[308] = 152;
        test_data_real[319] = 204;  test_data_imag[319] = 154;
        test_data_real[310] = 202;  test_data_imag[310] = 157;
        test_data_real[311] = 200;  test_data_imag[311] = 161;
        test_data_real[312] = 197;  test_data_imag[312] = 164;
        test_data_real[313] = 196;  test_data_imag[313] = 168;
        test_data_real[314] = 194;  test_data_imag[314] = 167;
        test_data_real[315] = 192;  test_data_imag[315] = 169;
        test_data_real[316] = 189;  test_data_imag[316] = 172;
        test_data_real[317] = 187;  test_data_imag[317] = 176;
        test_data_real[318] = 185;  test_data_imag[318] = 176; 
        test_data_real[319] = 0;    test_data_imag[319] = 0; 

      // 나머지 데이터는 간단히 순차적으로 증가하도록 채웁니다.
        // TOTAL_DATA_POINTS (512)까지 채워야 합니다.
        for (data_idx_for_array_init = 320; data_idx_for_array_init < TOTAL_DATA_POINTS; data_idx_for_array_init++) begin
            test_data_real[data_idx_for_array_init] = 0;
            test_data_imag[data_idx_for_array_init] = 0;
        end
        
        // --- 1. DUT 초기화 및 리셋 ---
        rst_n = 0; // 리셋 인가
        enable_fft = 0;
        for (int i = 0; i < NUM_PARALLEL_PATHS; i++) begin
            bfly02_tmp_real_in[i] = 0; // 입력 초기화
            bfly02_tmp_imag_in[i] = 0; // 입력 초기화
        end

        @(posedge clk); // 클럭 엣지 대기
        rst_n = 1; // 리셋 해제
        $display("[%0t] Reset released.", $time);
        // 안정화를 위해 몇 사이클 대기
        repeat (5) @(posedge clk);
        // --- 2. FFT 시작 및 16개씩 데이터 청크 제공 ---
        $display("[%0t] Starting FFT test scenario with hardcoded inputs.", $time);
        enable_fft = 1; // FFT 활성화
        $display("[%0t] enable_fft asserted.", $time);

        data_idx = 0; // 전체 데이터 인덱스 초기화 (test_data 배열의 인덱스)
        current_addr_display = 0; // 로그 출력용 가상 주소 (0부터 시작)

        for (int chunk = 0; chunk < NUM_CHUNKS; chunk++) begin
            @(posedge clk); // 각 청크마다 클럭 엣지 대기 (데이터를 다음 클럭 사이클에 인가)
            $display("[%0t] --- Applying Chunk %0d Data (Effective Addresses %0d to %0d) ---", 
                      $time, chunk, current_addr_display, current_addr_display + NUM_PARALLEL_PATHS -1);
            // 병렬 경로별로 16개의 값을 할당 (test_data_real/imag 배열에서 가져옴)
            for (int i = 0; i < NUM_PARALLEL_PATHS; i++) begin
                if (data_idx < TOTAL_DATA_POINTS) begin // TW_TABLE_DEPTH 대신 TOTAL_DATA_POINTS 사용
                    bfly02_tmp_real_in[i] = test_data_real[data_idx];
                    bfly02_tmp_imag_in[i] = test_data_imag[data_idx];
                end else begin
                    // 모든 데이터가 소진되면 0으로 채움
                    bfly02_tmp_real_in[i] = 0;
                    bfly02_tmp_imag_in[i] = 0;
                end
                
                $display("[%0t] Input Real[%0d]=%0d, Imag[%0d]=%0d (Global Index: %0d)", 
                          $time, i, bfly02_tmp_real_in[i], i, bfly02_tmp_imag_in[i], data_idx);
                data_idx++; // 다음 데이터 인덱스로 이동
            end
            current_addr_display += NUM_PARALLEL_PATHS; // 다음 청크의 시작 주소 업데이트
        end

        // FFT 완료 및 cbfp 최종 출력 enable 신호 대기
        @(posedge clk); // 마지막 청크 입력 후 한 클럭 더 대기
        $display("[%0t] Waiting for final output enable (dut.do_en)...", $time);
        // dut.do_en이 0이면 계속 대기
        while (dut.do_en == 0) begin 
            @(posedge clk);
            // 만약 너무 오래 기다린다면 (무한 루프 방지)
            if ($time > 5000) begin 
                $error("Error: Timeout waiting for dut.do_en.");
                $finish;
            end
        end
        $display("[%0t] dut.do_en asserted. Final output is ready.", $time);
        enable_fft = 0; // 완료 후 enable_fft 비활성화
        $display("[%0t] enable_fft deasserted.", $time);
        // --- 3. 테스트 종료 ---
        $display("[%0t] Testbench finished.", $time);
        #100; // 잠시 대기
        $finish; // 시뮬레이션 종료
    end

endmodule