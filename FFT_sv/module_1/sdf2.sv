`timescale 1ns / 1ps

module top_module2 #(
    parameter N = 512,
    parameter M = 512,
    parameter WIDTH = 12, // 변경: MATLAB Module 2의 bfly12 입력 (12bit)에 맞춰 조정
    parameter WIDTH_DO = 16 // 변경: MATLAB Module 2의 bfly22_tmp 출력 (16bit)에 맞춰 조정
)(
    input clk,
    input rstn,
    input fft_mode, // 이 신호는 현재 코드에서 사용되지 않음

    input di_en,
    input signed [WIDTH-1:0] di_re[0:15],
    input signed [WIDTH-1:0] di_im[0:15],
    input [5:0] di_index[0:15], // 각 병렬 데이터의 인덱스 (Twiddle Factor 주소 계산 등 활용)

    //output logic do_en, // 주석 처리된 출력, 필요한 경우 주석 해제 및 제어 로직 추가
    output signed [WIDTH_DO-1:0] do_re[0:15],
    output signed [WIDTH_DO-1:0] do_im[0:15]
);

//signal
logic [5:0] do_count;
logic bf1_in_en;
logic bf1_out_en;
logic fac8_0_sel; // 기존 fac8_0_sel, 아래 로직에서 확장
logic bf2_out_en;
logic sr2_in_sel;
logic sr2_out_sel;
logic [1:0] bf2_out_sel;
logic [1:0] fac8_1_sel;

logic bf3_out_en;
logic sr3_in_sel;
logic sr3_out_sel;
logic [1:0] bf3_out_sel;

logic bf1_sign_en;
logic bf2_sign_en;
logic bf3_sign_en;
logic do_count_en;

// ===========================================
// Bitwidth 조정된 내부 신호들
// ===========================================
// bf1_1 출력: (WIDTH+1) = 13bit
logic signed [WIDTH:0] bf1_add_re [0:15];
logic signed [WIDTH:0] bf1_add_im [0:15];
logic signed [WIDTH-1:0] bf1_dif_re [0:15];
logic signed [WIDTH-1:0] bf1_dif_im [0:15];

// sr1_out은 bf1_dif_re/im와 동일한 WIDTH
logic signed [WIDTH-1:0] sr1_out_re [0:15];
logic signed [WIDTH-1:0] sr1_out_im [0:15];

// bf1_sign_re/im 및 bf1_rot_re/im는 bf1_add_re/im의 비트폭 (13bit)으로 확장 (부호 확장)
logic signed [WIDTH:0] bf1_sign_re [0:15];
logic signed [WIDTH:0] bf1_sign_im [0:15];
logic signed [WIDTH:0] bf1_rot_re [0:15];
logic signed [WIDTH:0] bf1_rot_im [0:15];

// bf1_2 출력: (WIDTH+1) = 14bit (입력은 13bit)
logic signed [WIDTH+1:0] bf2_add_re [0:15]; // butterfly input width + 1
logic signed [WIDTH+1:0] bf2_add_im [0:15];
logic signed [WIDTH:0] bf2_dif_re [0:15]; // butterfly input width
logic signed [WIDTH:0] bf2_dif_im [0:15];

// sr2_in/out/tmp는 bf2_dif_re/im의 비트폭 (13bit)으로
logic signed [WIDTH:0] sr2_0_in_re [0:15];
logic signed [WIDTH:0] sr2_0_in_im [0:15];
logic signed [WIDTH:0] sr2_1_in_re [0:15];
logic signed [WIDTH:0] sr2_1_in_im [0:15];
logic signed [WIDTH:0] sr2_0_out_re [0:15];
logic signed [WIDTH:0] sr2_0_out_im [0:15];
logic signed [WIDTH:0] sr2_1_out_re [0:15];
logic signed [WIDTH:0] sr2_1_out_im [0:15];
logic signed [WIDTH:0] sr2_out_re [0:15];
logic signed [WIDTH:0] sr2_out_im [0:15];

// bf2_out_re/im는 bf2_add_re/im의 비트폭 (14bit)으로
logic signed [WIDTH+1:0] bf2_out_re [0:15];
logic signed [WIDTH+1:0] bf2_out_im [0:15];

// bf2_sign_re/im는 bf2_out_re/im의 비트폭 (14bit)으로
logic signed [WIDTH+1:0] bf2_sign_re [0:15];
logic signed [WIDTH+1:0] bf2_sign_im [0:15];

// bf2_rot_re/im는 (14bit 입력 + 9bit factor = 23bit)
logic signed [WIDTH+1+TW_WIDTH-1:0] bf2_rot_re [0:15]; // (14 + 9 - 1) = 22bit (최대)
logic signed [WIDTH+1+TW_WIDTH-1:0] bf2_rot_im [0:15];

// bf2_rod_re/im는 14bit (Rounding Bit 기준: 비트 위치 8 아래 버림, 22bit -> [21:8])
logic signed [WIDTH_DO-2:0] bf2_rod_re [0:15]; // 14bit
logic signed [WIDTH_DO-2:0] bf2_rod_im [0:15];

// bf1_3 출력: (14bit 입력 + 1) = 15bit
logic signed [WIDTH_DO-1:0] bf3_add_re [0:15]; // WIDTH_DO-1 (15bit)
logic signed [WIDTH_DO-2:0] bf3_dif_re [0:15]; // WIDTH_DO-2 (14bit)
logic signed [WIDTH_DO-1:0] bf3_add_im [0:15];
logic signed [WIDTH_DO-2:0] bf3_dif_im [0:15];

// sr3_in/out/tmp는 bf3_dif_re/im의 비트폭 (14bit)으로
logic signed [WIDTH_DO-2:0] sr3_0_in_re [0:15];
logic signed [WIDTH_DO-2:0] sr3_0_in_im [0:15];
logic signed [WIDTH_DO-2:0] sr3_1_in_re [0:15];
logic signed [WIDTH_DO-2:0] sr3_1_in_im [0:15];
logic signed [WIDTH_DO-2:0] sr3_0_out_re [0:15];
logic signed [WIDTH_DO-2:0] sr3_0_out_im [0:15];
logic signed [WIDTH_DO-2:0] sr3_1_out_re [0:15];
logic signed [WIDTH_DO-2:0] sr3_1_out_im [0:15];
logic signed [WIDTH_DO-2:0] sr3_out_re [0:15];
logic signed [WIDTH_DO-2:0] sr3_out_im [0:15];

// bf3_out_re/im는 bf3_add_re/im의 비트폭 (15bit)으로
logic signed [WIDTH_DO-1:0] bf3_out_re [0:15];
logic signed [WIDTH_DO-1:0] bf3_out_im [0:15];

// bf3_sign_re/im는 WIDTH_DO (16bit)로
logic signed [WIDTH_DO-1:0] bf3_sign_re [0:15];
logic signed [WIDTH_DO-1:0] bf3_sign_im [0:15];

// 임시 Twiddle Factor 비트폭 (complex_multiplier_02와 동일한 9 사용)
localparam TW_WIDTH = 9;


always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        do_count <= 6'd0;
        do_count_en <= 1'b0;
    end else begin
        // di_en이 들어오면 카운터 활성화
        if (di_en)
            do_count_en <= 1'b1;

        if (do_count_en) begin
            do_count <= do_count + 1;
            // 64개 사이클 완료 후 멈춤 (하나의 512포인트 FFT 블록 처리 완료)
            if (do_count == 6'd63)
                do_count_en <= 1'b0;
        end
    end
end

always_comb begin
    bf1_in_en  = 1'b0;
    bf1_out_en = 1'b0;
    bf1_sign_en = 1'b0;
    fac8_0_sel = 1'b0; // 이 신호는 이제 bf1_rot 로직 내부에서 더 세분화됨
    bf2_out_en = 1'b0;
    bf2_sign_en = 1'b0;
    sr2_in_sel = 1'b0;
    sr2_out_sel = 1'b0;
    bf2_out_sel = 2'b00;
    fac8_1_sel = 2'b00; // 1비트에서 2비트로 변경

    bf3_out_en = 1'b0;
    bf3_sign_en = 1'b0;
    sr3_in_sel = 1'b0;
    sr3_out_sel = 1'b0;
    bf3_out_sel = 2'b00;

    // do_count에 따른 enable/select 신호 조정
    // 이 타이밍은 파이프라인 지연에 따라 달라지므로, 기존 구조를 바탕으로 조정합니다.
    // MATLAB Module 2의 논리적 단계를 sdf1의 3개 버터플라이 단계에 매핑합니다.

    // bf1_1 (Stage 1) - bfly20 (Module 2, Step 2_0)
    // di_en이 들어온 후 데이터가 bf1_1에 유효하게 들어가는 기간
    if ((do_count >= 6'd1) && (do_count <= 6'd32)) // 32 chunks of 16 parallel data
        bf1_in_en = 1'b1;
    else bf1_in_en = 1'b0;

    // bf1_1 출력 유효 기간 (sr1 지연 16 후)
    if ((do_count >= 6'd1 + 16) && (do_count <= 6'd32 + 16)) // 17 ~ 48
        bf1_out_en = 1'b1;
    else bf1_out_en = 1'b0;

    // bf1_2 (Stage 2) - bfly21 (Module 2, Step 2_1)
    // bf1_out_en 이후 bf1_2 출력이 유효해지는 기간 (sr2 지연 8 후)
    if ((do_count >= 6'd17 + 8) && (do_count <= 6'd48 + 8)) // 25 ~ 56
        bf2_out_en = 1'b1;
    else bf2_out_en = 1'b0;

    // sr2_in_sel, sr2_out_sel (Module 2, Step 2_1의 중간 재정렬)
    // 이 구간은 bf2_dif_re/im가 sr2에 들어가고 나오는 기간과 연결
    // MATLAB bfly21_tmp에서 stride 2 버터플라이 후 트위들 적용
    if ((do_count >= 6'd25 + 8) && (do_count <= 6'd56)) begin // 33 ~ 56
        sr2_in_sel = 1'b1;
        sr2_out_sel = 1'b1;
    end
    else begin
        sr2_in_sel = 1'b0;
        sr2_out_sel = 1'b0;
    end

    // bf2_out_sel (bf2_add_re/im 또는 sr2_out_re/im 선택)
    // MATLAB Module 2의 bfly21에서 복잡한 인덱싱을 반영
    // 여기서는 기존 sdf1의 bf2_out_sel 로직을 바탕으로 시프트 레지스터 출력 선택
    // sr2_0_out_re/im 사용 시점
    if ((do_count >= 6'd33) && (do_count <= 6'd40)) // 이전 시점의 데이터
        bf2_out_sel = 2'd1;
    // sr2_1_out_re/im 사용 시점
    else if ((do_count >= 6'd49) && (do_count <= 6'd56)) // 더 이전 시점의 데이터
        bf2_out_sel = 2'd2;
    else bf2_out_sel = 2'b00; // bf2_add_re/im (현재 버터플라이 출력)

    // fac8_1_sel (bf2_rot에서 적용)
    // MATLAB fac8_1(nn) (nn: 1~8)에 맞춰 8가지 종류의 트위들 팩터 곱셈/회전을 시퀀싱
    // sdf1에서는 4가지 (0, 1, 2, 3)가 구현되어 있음.
    // 2'd0: no rotation (x256)
    // 2'd1: *(-j*256)
    // 2'd2: *(181-j*181)
    // 2'd3: *(-181-j*181)
    // 이 구간은 bf2_out_en 기간과 겹쳐야 함.
    // 기존 do_count 범위를 기반으로 조정 (실제 타이밍은 정밀 분석 필요)
    if ((do_count >= 6'd37) && (do_count <= 6'd40)) // fac8_1_sel type 1 (e.g., -j)
        fac8_1_sel = 2'd1;
    else if ((do_count >= 6'd45) && (do_count <= 6'd48)) // fac8_1_sel type 2 (e.g., 181-j*181)
        fac8_1_sel = 2'd2;
    else if ((do_count >= 6'd53) && (do_count <= 6'd56)) // fac8_1_sel type 3 (e.g., -181-j*181)
        fac8_1_sel = 2'd3;
    else fac8_1_sel = 2'd0; // 기본 (x256)

    // bf3_out_en (Stage 3) - bfly22 (Module 2, Step 2_2)
    // bf2_out_en 이후 bf1_3 출력이 유효해지는 기간 (sr3 지연 4 후)
    if ((do_count >= 6'd29 + 4) && (do_count <= 6'd60 + 4)) // 33 ~ 64, 실제 do_count <= 63이므로 33~63
        bf3_out_en = 1'b1;
    else bf3_out_en = 1'b0;

    // sr3_in_sel, sr3_out_sel (Module 2, Step 2_2의 중간 재정렬)
    if (((do_count >= 6'd33) && (do_count <= 6'd40))
                || ((do_count >= 6'd49) && (do_count <= 6'd56)) ) begin
        sr3_in_sel = 1'b1;
        sr3_out_sel = 1'b1;
    end
    else begin
        sr3_in_sel = 1'b0;
        sr3_out_sel = 1'b0;
    end

    // bf3_out_sel (bf3_add_re/im 또는 sr3_out_re/im 선택)
    // sr3_0_out_re/im 사용 시점
    if (((do_count >= 6'd33) && (do_count <= 6'd36))
                || ((do_count >= 6'd49) && (do_count <= 6'd52)) )
        bf3_out_sel = 2'd1;
    // sr3_1_out_re/im 사용 시점
    else if (((do_count >= 6'd41) && (do_count <= 6'd44))
                || ((do_count >= 6'd57) && (do_count <= 6'd60)) )
        bf3_out_sel = 2'd2;
    else bf3_out_sel = 2'b00; // bf3_add_re/im (현재 버터플라이 출력)

    // bf1_sign_en (bf1_add_re/im의 부호 변경)
    // MATLAB bfly20에서 특정 부분에 sign change가 있을 수 있음.
    // 기존 로직 유지 (타이밍은 변경된 파이프라인에 맞춰야 함)
    if ((do_count >= 6'd33) && (do_count <= 6'd48))
        bf1_sign_en = 1'b1;
    else bf1_sign_en = 1'b0;

    // bf2_sign_en (bf2_out_re/im의 부호 변경)
    // MATLAB bfly21에서 특정 부분에 sign change가 있을 수 있음.
    if (((do_count >= 6'd33) && (do_count <= 6'd40))
                || ((do_count >= 6'd49) && (do_count <= 6'd56)) )
        bf2_sign_en = 1'b1;
    else bf2_sign_en = 1'b0;

    // bf3_sign_en (bf3_out_re/im의 부호 변경)
    // MATLAB bfly22에서 특정 부분에 sign change가 있을 수 있음.
    if (((do_count >= 6'd33) && (do_count <= 6'd36))
                || ((do_count >= 6'd41) && (do_count <= 6'd44))
                || ((do_count >= 6'd49) && (do_count <= 6'd52))
                || ((do_count >= 6'd57) && (do_count <= 6'd60)))
        bf3_sign_en = 1'b1;
    else bf3_sign_en = 1'b0;

end

// step.0 (bf1_1) - MATLAB Module 2의 bfly20에 해당
// bf1_1 butterfly는 12bit 입력, 13bit 덧셈/뺄셈 출력
butterfly #(.WIDTH(WIDTH)) bf1_1( // WIDTH = 12
    .in_en(bf1_in_en),
    .out_en(bf1_out_en),
    .x0_re(di_re),
    .x0_im(di_im),
    .x1_re(sr1_out_re),
    .x1_im(sr1_out_im),
    .y0_re(bf1_add_re), // 13bit
    .y0_im(bf1_add_im), // 13bit
    .y1_re(bf1_dif_re), // 12bit
    .y1_im(bf1_dif_im)  // 12bit
);

shift_reg #(
    .WIDTH(WIDTH), .DELAY_LENGTH(16)) sr1( // WIDTH = 12
    .clk(clk),
    .rstn(rstn),
    .data_in_real(bf1_dif_re),
    .data_in_imag(bf1_dif_im),
    .data_out_real(sr1_out_re),
    .data_out_imag(sr1_out_im)
);

// bf1_add_re/im의 부호 변경 (bf1_sign_en)
always_comb begin
    for (int i = 0; i < 16; i++) begin
        if (bf1_sign_en) begin
            bf1_sign_re[i] = -bf1_add_re[i];
            bf1_sign_im[i] = -bf1_add_im[i];
        end else begin
            bf1_sign_re[i] = bf1_add_re[i];
            bf1_sign_im[i] = bf1_add_im[i];
        end
    end
end

// fac8_0 적용 로직 변경: MATLAB Module 2의 bfly20에서 fac8_0(ceil(nn/2)) 구현
// nn은 1~8 (8개 간격), 즉 16개 병렬 경로에서 0~7, 8~15를 그룹으로 보고 제어해야 함
always_comb begin
    for (int i = 0; i < 16; i++) begin
        // fac8_0(ceil(nn/2)) 의 nn은 1~8 (즉, 병렬 경로 내의 8개 묶음 인덱스)
        // di_index[2:0]가 0~7을 나타낸다고 가정
        case (di_index[2:0]) // (i % 8)에 해당한다고 가정
            3'd0, 3'd1: begin // ceil(1/2)=1, ceil(2/2)=1 -> fac8_0(1) = 1 (identity)
                bf1_rot_re[i] = bf1_sign_re[i];
                bf1_rot_im[i] = bf1_sign_im[i];
            end
            3'd2, 3'd3: begin // ceil(3/2)=2, ceil(4/2)=2 -> fac8_0(2) = 1 (identity)
                bf1_rot_re[i] = bf1_sign_re[i];
                bf1_rot_im[i] = bf1_sign_im[i];
            end
            3'd4, 3'd5: begin // ceil(5/2)=3, ceil(6/2)=3 -> fac8_0(3) = 1 (identity)
                bf1_rot_re[i] = bf1_sign_re[i];
                bf1_rot_im[i] = bf1_sign_im[i];
            end
            3'd6, 3'd7: begin // ceil(7/2)=4, ceil(8/2)=4 -> fac8_0(4) = -j
                bf1_rot_re[i] = bf1_sign_im[i];  // Re <- Im
                bf1_rot_im[i] = -bf1_sign_re[i]; // Im <- -Re
            end
            default: begin // 안전을 위한 기본값 (identity)
                bf1_rot_re[i] = bf1_sign_re[i];
                bf1_rot_im[i] = bf1_sign_im[i];
            end
        endcase
    end
end

// step.1 (bf1_2) - MATLAB Module 2의 bfly21에 해당
// bf1_2 butterfly는 13bit 입력, 14bit 덧셈/뺄셈 출력
butterfly #(.WIDTH(WIDTH+1)) bf1_2( // WIDTH+1 = 13
    .in_en(bf1_out_en),
    .out_en(bf2_out_en),
    .x0_re(bf1_rot_re), // 13bit
    .x0_im(bf1_rot_im), // 13bit
    .x1_re(sr2_out_re), // 13bit
    .x1_im(sr2_out_im), // 13bit
    .y0_re(bf2_add_re), // 14bit
    .y0_im(bf2_add_im), // 14bit
    .y1_re(bf2_dif_re), // 13bit
    .y1_im(bf2_dif_im)  // 13bit
);

// sr2_in_sel에 따른 sr2_0_in/sr2_1_in 선택
always_comb begin
    if (sr2_in_sel == 1'b0) begin // 현재 bf2_dif_re/im를 sr2_0으로
        sr2_0_in_re = bf2_dif_re;
        sr2_0_in_im = bf2_dif_im;
        for (int i = 0; i < 16; i++) begin
            sr2_1_in_re[i] = '0;
            sr2_1_in_im[i] = '0;
        end
    end else begin // 현재 bf2_dif_re/im를 sr2_1으로
        for (int i = 0; i < 16; i++) begin
            sr2_0_in_re[i] = '0;
            sr2_0_in_im[i] = '0;
        end
        sr2_1_in_re = bf2_dif_re;
        sr2_1_in_im = bf2_dif_im;
    end
end

// sr2_out_sel에 따른 sr2_0_out/sr2_1_out 선택
always_comb begin
    if (sr2_out_sel == 1'b0) begin // sr2_0_out 사용
        sr2_out_re = sr2_0_out_re;
        sr2_out_im = sr2_0_out_im;
    end else begin // sr2_1_out 사용
        sr2_out_re = sr2_1_out_re;
        sr2_out_im = sr2_1_out_im;
    end
end

shift_reg #(
    .WIDTH(WIDTH+1), .DELAY_LENGTH(8)) sr2_0( // WIDTH+1 = 13
    .clk(clk),
    .rstn(rstn),
    .data_in_real(sr2_0_in_re),
    .data_in_imag(sr2_0_in_im),
    .data_out_real(sr2_0_out_re),
    .data_out_imag(sr2_0_out_im)
);

shift_reg #(
    .WIDTH(WIDTH+1), .DELAY_LENGTH(8)) sr2_1( // WIDTH+1 = 13
    .clk(clk),
    .rstn(rstn),
    .data_in_real(sr2_1_in_re),
    .data_in_imag(sr2_1_in_im),
    .data_out_real(sr2_1_out_re),
    .data_out_imag(sr2_1_out_im)
);

// bf2_out_sel에 따른 선택 (bf2_add_re/im 또는 시프트 레지스터 출력)
always_comb begin
    case (bf2_out_sel)
        2'd0: begin // 현재 버터플라이 덧셈 결과
            bf2_out_re = bf2_add_re;
            bf2_out_im = bf2_add_im;
        end
        2'd1: begin // sr2_0_out_re/im (13bit)를 14bit로 부호 확장
            for (int i = 0; i < 16; i++) begin
                bf2_out_re[i] = {sr2_0_out_re[i][WIDTH], sr2_0_out_re[i]}; // {sr2_0_out_re[i][12], sr2_0_out_re[i]}
                bf2_out_im[i] = {sr2_0_out_im[i][WIDTH], sr2_0_out_im[i]}; // {sr2_0_out_im[i][12], sr2_0_out_im[i]}
            end
        end
        2'd2: begin // sr2_1_out_re/im (13bit)를 14bit로 부호 확장
            for (int i = 0; i < 16; i++) begin
                bf2_out_re[i] = {sr2_1_out_re[i][WIDTH], sr2_1_out_re[i]}; // {sr2_1_out_re[i][12], sr2_1_out_re[i]}
                bf2_out_im[i] = {sr2_1_out_im[i][WIDTH], sr2_1_out_im[i]}; // {sr2_1_out_im[i][12], sr2_1_out_im[i]}
            end
        end
        default: begin // 기본값: 현재 버터플라이 덧셈 결과
            bf2_out_re = bf2_add_re;
            bf2_out_im = bf2_add_im;
        end
    endcase
end

// **포화(Saturation) 로직 추가**: MATLAB Module 2의 bfly21_tmp에서 sat(..., 14)를 반영
always_comb begin
    for (int i = 0; i < 16; i++) begin
        // 포화 범위 [-(2^(13)), 2^(13)-1] (14bit signed)
        // 입력은 bf2_out_re/im (14bit)
        if (bf2_out_re[i] > (14'd8191)) // 2^13 - 1
            bf2_sign_re[i] = 14'd8191;
        else if (bf2_out_re[i] < (-14'd8192)) // -2^13
            bf2_sign_re[i] = -14'd8192;
        else
            bf2_sign_re[i] = bf2_out_re[i];

        if (bf2_out_im[i] > (14'd8191))
            bf2_sign_im[i] = 14'd8191;
        else if (bf2_out_im[i] < (-14'd8192))
            bf2_sign_im[i] = -14'd8192;
        else
            bf2_sign_im[i] = bf2_out_im[i];

        // bf2_sign_en에 따른 최종 부호 변경 (포화 후 적용)
        if (bf2_sign_en) begin
            bf2_sign_re[i] = -bf2_sign_re[i];
            bf2_sign_im[i] = -bf2_sign_im[i];
        end
    end
end


// fac8_1 적용 로직: bf2_rot에서 Twiddle Factor 곱셈 (bf2_sign_re/im는 14bit)
// MATLAB fac8_1은 256이 곱해져 있음 (8bit left shift 효과)
always_comb begin
    for (int i = 0; i < 16; i++) begin
        case (fac8_1_sel)
            2'd0: begin // fac8_1(1,2,3,5,7)에 해당 (x256)
                bf2_rot_re[i] = bf2_sign_re[i] * (1'b1 << TW_WIDTH); // 14bit * (2^9) = 14+9 = 23bit
                bf2_rot_im[i] = bf2_sign_im[i] * (1'b1 << TW_WIDTH);
            end
            2'd1: begin // fac8_1(4)에 해당 (-j*256)
                bf2_rot_re[i] = bf2_sign_im[i] * (1'b1 << TW_WIDTH);
                bf2_rot_im[i] = -bf2_sign_re[i] * (1'b1 << TW_WIDTH);
            end
            2'd2: begin // fac8_1(6)에 해당 (181-j*181)
                bf2_rot_re[i] = 9'd181 * bf2_sign_re[i] - 9'd181 * bf2_sign_im[i];
                bf2_rot_im[i] = 9'd181 * bf2_sign_im[i] + 9'd181 * bf2_sign_re[i];
            end
            2'd3: begin // fac8_1(8)에 해당 (-181-j*181)
                bf2_rot_re[i] = -9'sd181 * bf2_sign_re[i] + 9'd181 * bf2_sign_im[i];
                bf2_rot_im[i] = -9'sd181 * bf2_sign_re[i] - 9'd181 * bf2_sign_im[i];
            end
            default: begin // 기본값: no rotation (x256)
                bf2_rot_re[i] = bf2_sign_re[i] * (1'b1 << TW_WIDTH);
                bf2_rot_im[i] = bf2_sign_im[i] * (1'b1 << TW_WIDTH);
            end
        endcase
    end
end

// 라운딩 및 비트 자르기 (bf2_rod_re/im는 14bit)
// MATLAB round(temp_bfly21/256) 에 맞춰 비트 [21:8]을 선택
always_comb begin
    for (int i = 0; i < 16; i++) begin
        automatic logic signed [WIDTH+1+TW_WIDTH-1:0] re_tmp, im_tmp; // 22bit

        // Rounding: round(X/256) = (X + 256/2) / 256 = (X + 128) >> 8
        re_tmp = bf2_rot_re[i] + (1'b1 << (TW_WIDTH-1)); // 128 (for 8-bit shift)
        im_tmp = bf2_rot_im[i] + (1'b1 << (TW_WIDTH-1));

        bf2_rod_re[i] = re_tmp[WIDTH+1+TW_WIDTH-1-1 : TW_WIDTH-1]; // [21:8] = 14bit
        bf2_rod_im[i] = im_tmp[WIDTH+1+TW_WIDTH-1-1 : TW_WIDTH-1];
    end
end


// step.2 (bf1_3) - MATLAB Module 2의 bfly22에 해당
// bf1_3 butterfly는 14bit 입력, 15bit 덧셈/뺄셈 출력 (bfly21은 15bit)
butterfly #(.WIDTH(WIDTH_DO-2)) bf1_3( // WIDTH_DO-2 = 14
    .in_en(bf2_out_en),
    .out_en(bf3_out_en),
    .x0_re(bf2_rod_re), // 14bit
    .x0_im(bf2_rod_im), // 14bit
    .x1_re(sr3_out_re), // 14bit
    .x1_im(sr3_out_im), // 14bit
    .y0_re(bf3_add_re), // 15bit
    .y0_im(bf3_add_im), // 15bit
    .y1_re(bf3_dif_re), // 14bit
    .y1_im(bf3_dif_im)  // 14bit
);

// sr3_in_sel에 따른 sr3_0_in/sr3_1_in 선택
always_comb begin
    if (sr3_in_sel == 1'b0) begin // 현재 bf3_dif_re/im를 sr3_0으로
        sr3_0_in_re = bf3_dif_re;
        sr3_0_in_im = bf3_dif_im;
        for (int i = 0; i < 16; i++) begin
            sr3_1_in_re[i] = '0;
            sr3_1_in_im[i] = '0;
        end
    end else begin // 현재 bf3_dif_re/im를 sr3_1으로
        for (int i = 0; i < 16; i++) begin
            sr3_0_in_re[i] = '0;
            sr3_0_in_im[i] = '0;
        end
        sr3_1_in_re = bf3_dif_re;
        sr3_1_in_im = bf3_dif_im;
    end
end

// sr3_out_sel에 따른 sr3_0_out/sr3_1_out 선택
always_comb begin
    if (sr3_out_sel == 1'b0) begin // sr3_0_out 사용
        sr3_out_re = sr3_0_out_re;
        sr3_out_im = sr3_0_out_im;
    end else begin // sr3_1_out 사용
        sr3_out_re = sr3_1_out_re;
        sr3_out_im = sr3_1_out_im;
    }
end

shift_reg #(
    .WIDTH(WIDTH_DO-2), .DELAY_LENGTH(4)) ( // WIDTH_DO-2 = 14
    .clk(clk),
    .rstn(rstn),
    .data_in_real(sr3_0_in_re),
    .data_in_imag(sr3_0_in_im),
    .data_out_real(sr3_0_out_re),
    .data_out_imag(sr3_0_out_im)
);

shift_reg #(
    .WIDTH(WIDTH_DO-2), .DELAY_LENGTH(4)) ( // WIDTH_DO-2 = 14
    .clk(clk),
    .rstn(rstn),
    .data_in_real(sr3_1_in_re),
    .data_in_imag(sr3_1_in_im),
    .data_out_real(sr3_1_out_re),
    .data_out_imag(sr3_1_out_im)
);

// bf3_out_sel에 따른 선택 (bf3_add_re/im 또는 시프트 레지스터 출력)
always_comb begin
    case (bf3_out_sel)
        2'd0: begin // 현재 버터플라이 덧셈 결과
            bf3_out_re = bf3_add_re;
            bf3_out_im = bf3_add_im;
        end
        2'd1: begin // sr3_0_out_re/im (14bit)를 15bit로 부호 확장
            for (int i = 0; i < 16; i++) begin
                bf3_out_re[i] = {sr3_0_out_re[i][WIDTH_DO-3], sr3_0_out_re[i]}; // {sr3_0_out_re[i][13], sr3_0_out_re[i]}
                bf3_out_im[i] = {sr3_0_out_im[i][WIDTH_DO-3], sr3_0_out_im[i]}; // {sr3_0_out_im[i][13], sr3_0_out_im[i]}
            end
        end
        2'd2: begin // sr3_1_out_re/im (14bit)를 15bit로 부호 확장
            for (int i = 0; i < 16; i++) begin
                bf3_out_re[i] = {sr3_1_out_re[i][WIDTH_DO-3], sr3_1_out_re[i]}; // {sr3_1_out_re[i][13], sr3_1_out_re[i]}
                bf3_out_im[i] = {sr3_1_out_im[i][WIDTH_DO-3], sr3_1_out_im[i]}; // {sr3_1_out_im[i][13], sr3_1_im[i]}
            end
        end
        default: begin // 기본값: 현재 버터플라이 덧셈 결과
            bf3_out_re = bf3_add_re;
            bf3_out_im = bf3_add_im;
        end
    endcase
end

// bf3_out_re/im의 부호 변경 (bf3_sign_en) 및 최종 출력 (16bit)
always_comb begin
    for (int i = 0; i < 16; i++) begin
        // 15bit bf3_out_re/im를 16bit bf3_sign_re/im로 부호 확장
        logic signed [WIDTH_DO-1:0] temp_re = {bf3_out_re[i][WIDTH_DO-2], bf3_out_re[i]};
        logic signed [WIDTH_DO-1:0] temp_im = {bf3_out_im[i][WIDTH_DO-2], bf3_out_im[i]};

        if (bf3_sign_en) begin
            bf3_sign_re[i] = -temp_re;
            bf3_sign_im[i] = -temp_im;
        end else begin
            bf3_sign_re[i] = temp_re;
            bf3_sign_im[i] = temp_im;
        end
    end
end

assign do_re = bf3_sign_re;
assign do_im = bf3_sign_im;

endmodule