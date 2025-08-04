`timescale 1ns/1ps

module sdf1 #(
    parameter N = 512,
    parameter M = 512,
    parameter WIDTH = 9,
    parameter WIDTH_DO = 11
) (
    input clk,
    input rstn,
    input fft_mode,

    input di_en,
    input signed [WIDTH-1:0] di_re[0:15],
    input signed [WIDTH-1:0] di_im[0:15],

    output [4:0] do_index[0:15],
    output logic do_en,
    output signed [WIDTH_DO-1:0] do_re[0:15],
    output signed [WIDTH_DO-1:0] do_im[0:15]
);

    //signal
    logic [6:0] do_count;
    logic bf1_in_en;
    logic bf1_out_en;
    logic fac8_0_sel;

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
    logic rod1_sign_en;
    logic cbfp_en;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            do_count <= 6'd0;
            do_count_en <= 1'b0;
        end else begin
            if (di_en) do_count_en <= 1'b1;

            if (do_count_en) begin
                do_count <= do_count + 1;
                if (do_count == 7'd70)
                    do_count_en <= 1'b0;  // 64개 완료 후 멈춤
            end
        end
    end

    always_comb begin
        bf1_in_en = 1'b0;
        bf1_out_en = 1'b0;
        bf1_sign_en = 1'b0;
        fac8_0_sel = 1'b0;
        bf2_out_en = 1'b0;
        bf2_sign_en = 1'b0;
        sr2_in_sel = 1'b0;
        sr2_out_sel = 1'b0;
        bf2_out_sel = 2'b00;
        fac8_1_sel = 1'b0;

        bf3_out_en = 1'b0;
        bf3_sign_en = 1'b0;
        sr3_in_sel = 1'b0;
        sr3_out_sel = 1'b0;
        bf3_out_sel = 2'b00;
        rod1_sign_en = 1'b0;
        cbfp_en = 1'b0;

        // 1~32 -> bf1_in_en
        if ((do_count >= 6'd1) && (do_count <= 6'd32)) bf1_in_en = 1'b1;
        else bf1_in_en = 1'b0;

        // 17~48 -> bf1_out_en
        if ((do_count >= 6'd17) && (do_count <= 6'd48)) bf1_out_en = 1'b1;
        else bf1_out_en = 1'b0;

        // 41~48 -> fac8_0_en
        if ((do_count >= 6'd41) && (do_count <= 6'd48)) fac8_0_sel = 1'b1;
        else fac8_0_sel = 1'b0;

        // 25~56 -> bf2_out_en
        if ((do_count >= 6'd25) && (do_count <= 6'd56)) bf2_out_en = 1'b1;
        else bf2_out_en = 1'b0;

        // 33~48 -> sr2_in_sel sr2_out_sel
        if ((do_count >= 6'd33) && (do_count <= 6'd48)) begin
            sr2_in_sel  = 1'b1;
            sr2_out_sel = 1'b1;
        end else begin
            sr2_in_sel  = 1'b0;
            sr2_out_sel = 1'b0;
        end


        // 33~40 -> bf2_out_sel 1
        if ((do_count >= 6'd33) && (do_count <= 6'd40)) bf2_out_sel = 2'd1;
        // 49~56 -> bf2_out_sel 2
        else if ((do_count >= 6'd49) && (do_count <= 6'd56)) bf2_out_sel = 2'd2;
        else bf2_out_sel = 2'b00;

        // fac8_1_sel 1
        if ((do_count >= 6'd37) && (do_count <= 6'd40)) fac8_1_sel = 2'd1;
        // fac8_1_sel 2
        else if ((do_count >= 6'd45) && (do_count <= 6'd48)) fac8_1_sel = 2'd2;
        // fac8_1_sel 3
        else if ((do_count >= 6'd53) && (do_count <= 6'd56)) fac8_1_sel = 2'd3;
        else fac8_1_sel = 1'b0;

        // 29~60 -> bf3_out_en
        if ((do_count >= 6'd29) && (do_count <= 6'd60)) bf3_out_en = 1'b1;
        else bf3_out_en = 1'b0;

        // 33~40 49~56 -> sr3_in_sel sr3_out_sel
        if (((do_count >= 6'd33) && (do_count <= 6'd40))
            || ((do_count >= 6'd49) && (do_count <= 6'd56)) ) begin
            sr3_in_sel  = 1'b1;
            sr3_out_sel = 1'b1;
        end else begin
            sr3_in_sel  = 1'b0;
            sr3_out_sel = 1'b0;
        end

        // 33~36 49~52 -> bf3_out_sel 1
        if (((do_count >= 6'd33) && (do_count <= 6'd36))
            || ((do_count >= 6'd49) && (do_count <= 6'd52)) )
            bf3_out_sel = 2'd1;
        // 49~56 -> bf3_out_sel 2
        else if (((do_count >= 6'd41) && (do_count <= 6'd44))
            || ((do_count >= 6'd57) && (do_count <= 6'd60)) )
            bf3_out_sel = 2'd2;
        else bf3_out_sel = 2'b00;

        if ((do_count >= 6'd33) && (do_count <= 6'd48)) bf1_sign_en = 1'b1;
        else bf1_sign_en = 1'b0;

        if (((do_count >= 6'd33) && (do_count <= 6'd40))
            || ((do_count >= 6'd49) && (do_count <= 6'd56)) )
            bf2_sign_en = 1'b1;
        else bf2_sign_en = 1'b0;


        if (((do_count >= 6'd33) && (do_count <= 6'd36))
            || ((do_count >= 6'd41) && (do_count <= 6'd44))
            || ((do_count >= 6'd49) && (do_count <= 6'd52))
            || ((do_count >= 6'd57) && (do_count <= 6'd60)))
            bf3_sign_en = 1'b1;
        else bf3_sign_en = 1'b0;

        if (((do_count >= 6'd25) && (do_count <= 6'd28))
            || ((do_count >= 6'd33) && (do_count <= 6'd36))
            || ((do_count >= 6'd41) && (do_count <= 6'd44))
            || ((do_count >= 6'd49) && (do_count <= 6'd52)))
            rod1_sign_en = 1'b1;
        else rod1_sign_en = 1'b0;

        if ((do_count >= 6'd29) && (do_count <= 7'd69)) cbfp_en = 1'b1;
        else cbfp_en = 1'b0;

    end

    // step.0
    logic signed [WIDTH-1:0] sr1_out_re [0:15];
    logic signed [WIDTH-1:0] sr1_out_im [0:15];
    logic signed [  WIDTH:0] bf1_add_re [0:15];
    logic signed [  WIDTH:0] bf1_add_im [0:15];
    logic signed [WIDTH-1:0] bf1_sign_re[0:15];
    logic signed [WIDTH-1:0] bf1_sign_im[0:15];
    logic signed [WIDTH-1:0] bf1_dif_re [0:15];
    logic signed [WIDTH-1:0] bf1_dif_im [0:15];
    logic signed [  WIDTH:0] bf1_rot_re [0:15];
    logic signed [  WIDTH:0] bf1_rot_im [0:15];
    logic signed [WIDTH-1:0] di_buf_re  [0:15];
    logic signed [WIDTH-1:0] di_buf_im  [0:15];

    delay_buf #(
         .WIDTH(9)
    ) buf1 (
        .clk(clk),
        .rstn(rstn),
        .din_re(di_re),
        .din_im(di_im),
        .dout_re(di_buf_re),
        .dout_im(di_buf_im)
    );
    butterfly #(
        .WIDTH(9)
    ) bf1_1 (
        .in_en (bf1_in_en),
        .out_en(bf1_out_en),
        .x0_re (di_buf_re),
        .x0_im (di_buf_im),
        .x1_re (sr1_out_re),
        .x1_im (sr1_out_im),
        .y0_re (bf1_add_re),
        .y0_im (bf1_add_im),
        .y1_re (bf1_dif_re),
        .y1_im (bf1_dif_im)
    );

    shift_reg #(
        .WIDTH(9),
        .DELAY_LENGTH(16)
    ) sr1 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(bf1_dif_re),
        .data_in_imag(bf1_dif_im),
        .data_out_real(sr1_out_re),
        .data_out_imag(sr1_out_im)
    );

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
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            if (fac8_0_sel) begin
                bf1_rot_re[i] = bf1_sign_im[i];  // Re ← Im
                bf1_rot_im[i] = -bf1_sign_re[i];  // Im ← -Re
            end else begin
                bf1_rot_re[i] = bf1_sign_re[i];
                bf1_rot_im[i] = bf1_sign_im[i];
            end
        end
    end

    // step.1
    logic signed [9:0] sr2_0_in_re[0:15];
    logic signed [9:0] sr2_0_in_im[0:15];
    logic signed [9:0] sr2_1_in_re[0:15];
    logic signed [9:0] sr2_1_in_im[0:15];
    logic signed [9:0] sr2_0_out_re[0:15];
    logic signed [9:0] sr2_0_out_im[0:15];
    logic signed [9:0] sr2_1_out_re[0:15];
    logic signed [9:0] sr2_1_out_im[0:15];
    logic signed [9:0] sr2_out_re[0:15];
    logic signed [9:0] sr2_out_im[0:15];
    logic signed [10:0] bf2_add_re[0:15];
    logic signed [10:0] bf2_add_im[0:15];
    logic signed [9:0] bf2_dif_re[0:15];
    logic signed [9:0] bf2_dif_im[0:15];
    logic signed [10:0] bf2_out_re[0:15];
    logic signed [10:0] bf2_out_im[0:15];
    logic signed [10:0] bf2_sign_re[0:15];
    logic signed [10:0] bf2_sign_im[0:15];
    logic signed [20:0] bf2_rot_re[0:15];
    logic signed [20:0] bf2_rot_im[0:15];
    logic signed [12:0] bf2_rod_re[0:15];
    logic signed [12:0] bf2_rod_im[0:15];
    logic signed [20:0] bf2_rot_sign_re[0:15];
    logic signed [20:0] bf2_rot_sign_im[0:15];


    butterfly #(
        .WIDTH(10)
    ) bf1_2 (
        .in_en (bf1_out_en),
        .out_en(bf2_out_en),
        .x0_re (bf1_rot_re),
        .x0_im (bf1_rot_im),
        .x1_re (sr2_out_re),
        .x1_im (sr2_out_im),
        .y0_re (bf2_add_re),
        .y0_im (bf2_add_im),
        .y1_re (bf2_dif_re),
        .y1_im (bf2_dif_im)
    );

    always_comb begin
        if (sr2_in_sel == 1'b0) begin
            sr2_0_in_re = bf2_dif_re;
            sr2_0_in_im = bf2_dif_im;
            for (int i = 0; i < 16; i++) begin
                sr2_1_in_re[i] = '0;
                sr2_1_in_im[i] = '0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                sr2_0_in_re[i] = '0;
                sr2_0_in_im[i] = '0;
            end
            sr2_1_in_re = bf2_dif_re;
            sr2_1_in_im = bf2_dif_im;
        end
    end


    always_comb begin
        if (sr2_out_sel == 1'b0) begin
            sr2_out_re = sr2_0_out_re;
            sr2_out_im = sr2_0_out_im;
        end else begin
            sr2_out_re = sr2_1_out_re;
            sr2_out_im = sr2_1_out_im;
        end
    end


    shift_reg #(
        .WIDTH(10),
        .DELAY_LENGTH(8)
    ) sr2_0 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr2_0_in_re),
        .data_in_imag(sr2_0_in_im),
        .data_out_real(sr2_0_out_re),
        .data_out_imag(sr2_0_out_im)
    );

    shift_reg #(
        .WIDTH(10),
        .DELAY_LENGTH(8)
    ) sr2_1 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr2_1_in_re),
        .data_in_imag(sr2_1_in_im),
        .data_out_real(sr2_1_out_re),
        .data_out_imag(sr2_1_out_im)
    );

    always_comb begin
        case (bf2_out_sel)
            2'd0: begin
                bf2_out_re = bf2_add_re;
                bf2_out_im = bf2_add_im;
            end
            2'd1: begin
                for (int i = 0; i < 16; i++) begin
                    bf2_out_re[i] = {sr2_0_out_re[i][9], sr2_0_out_re[i]};
                    bf2_out_im[i] = {sr2_0_out_im[i][9], sr2_0_out_im[i]};
                end
            end
            2'd2: begin
                for (int i = 0; i < 16; i++) begin
                    bf2_out_re[i] = {sr2_1_out_re[i][9], sr2_1_out_re[i]};
                    bf2_out_im[i] = {sr2_1_out_im[i][9], sr2_1_out_im[i]};
                end
            end
            default: begin
                bf2_out_re = bf2_add_re;
                bf2_out_im = bf2_add_im;
            end
        endcase
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            if (bf2_sign_en) begin
                bf2_sign_re[i] = -bf2_out_re[i];
                bf2_sign_im[i] = -bf2_out_im[i];
            end else begin
                bf2_sign_re[i] = bf2_out_re[i];
                bf2_sign_im[i] = bf2_out_im[i];
            end
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            case (fac8_1_sel)
                2'd0: begin
                    bf2_rot_re[i] = bf2_sign_re[i] * 10'sd256;
                    bf2_rot_im[i] = bf2_sign_im[i] * 10'sd256;
                end
                2'd1: begin
                    bf2_rot_re[i] = bf2_sign_im[i] * 10'sd256;
                    bf2_rot_im[i] = -bf2_sign_re[i] * 10'sd256;
                end
                2'd2: begin
                    bf2_rot_re[i] = 9'sd181 * bf2_sign_re[i] + 9'sd181 * bf2_sign_im[i];
                    bf2_rot_im[i] = 9'sd181 * bf2_sign_im[i] - 9'sd181 * bf2_sign_re[i];
                end
                2'd3: begin
                    bf2_rot_re[i] = -9'sd181 * bf2_sign_re[i] + 9'sd181 * bf2_sign_im[i];
                    bf2_rot_im[i] = -9'sd181 * bf2_sign_re[i] - 9'sd181 * bf2_sign_im[i];
                end
                default: begin
                    bf2_rot_re[i] = bf2_sign_re[i] * 10'sd256;
                    bf2_rot_im[i] = bf2_sign_im[i] * 10'sd256;
                end
            endcase
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            if (rod1_sign_en) begin
                bf2_rot_sign_re[i] = bf2_rot_re[i];
                bf2_rot_sign_im[i] = bf2_rot_im[i];
            end else begin
                bf2_rot_sign_re[i] = bf2_rot_re[i];
                bf2_rot_sign_im[i] = bf2_rot_im[i];
            end
        end
    end

    always_comb begin
        // Rounding Bit 기준: 비트 위치 7 아래 버림
        for (int i = 0; i < 16; i++) begin
            automatic logic signed [20:0] re_tmp, im_tmp;

            re_tmp = bf2_rot_sign_re[i] + 13'd128;
            im_tmp = bf2_rot_sign_im[i] + 13'd128;

            bf2_rod_re[i] = re_tmp[20:8];
            bf2_rod_im[i] = im_tmp[20:8];
        end
    end



    // step.2

    logic signed [12:0] sr3_0_in_re [0:15];
    logic signed [12:0] sr3_0_in_im [0:15];
    logic signed [12:0] sr3_1_in_re [0:15];
    logic signed [12:0] sr3_1_in_im [0:15];
    logic signed [12:0] sr3_0_out_re[0:15];
    logic signed [12:0] sr3_0_out_im[0:15];
    logic signed [12:0] sr3_1_out_re[0:15];
    logic signed [12:0] sr3_1_out_im[0:15];
    logic signed [12:0] sr3_out_re  [0:15];
    logic signed [12:0] sr3_out_im  [0:15];
    logic signed [13:0] bf3_add_re  [0:15];
    logic signed [13:0] bf3_add_im  [0:15];
    logic signed [12:0] bf3_dif_re  [0:15];
    logic signed [12:0] bf3_dif_im  [0:15];
    logic signed [13:0] bf3_out_re  [0:15];
    logic signed [13:0] bf3_out_im  [0:15];
    logic signed [13:0] bf3_sign_re [0:15];
    logic signed [13:0] bf3_sign_im [0:15];

    butterfly #(
        .WIDTH(13)
    ) bf1_3 (
        .in_en (bf2_out_en),
        .out_en(bf3_out_en),
        .x0_re (bf2_rod_re),
        .x0_im (bf2_rod_im),
        .x1_re (sr3_out_re),
        .x1_im (sr3_out_im),
        .y0_re (bf3_add_re),
        .y0_im (bf3_add_im),
        .y1_re (bf3_dif_re),
        .y1_im (bf3_dif_im)
    );

    always_comb begin
        if (sr3_in_sel == 1'b0) begin
            sr3_0_in_re = bf3_dif_re;
            sr3_0_in_im = bf3_dif_im;
            for (int i = 0; i < 16; i++) begin
                sr3_1_in_re[i] = '0;
                sr3_1_in_im[i] = '0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                sr3_0_in_re[i] = '0;
                sr3_0_in_im[i] = '0;
            end
            sr3_1_in_re = bf3_dif_re;
            sr3_1_in_im = bf3_dif_im;
        end
    end

    always_comb begin
        if (sr3_out_sel == 1'b0) begin
            sr3_out_re = sr3_0_out_re;
            sr3_out_im = sr3_0_out_im;
        end else begin
            sr3_out_re = sr3_1_out_re;
            sr3_out_im = sr3_1_out_im;
        end
    end

    shift_reg #(
        .WIDTH(13),
        .DELAY_LENGTH(4)
    ) sr3_0 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr3_0_in_re),
        .data_in_imag(sr3_0_in_im),
        .data_out_real(sr3_0_out_re),
        .data_out_imag(sr3_0_out_im)
    );

    shift_reg #(
        .WIDTH(13),
        .DELAY_LENGTH(4)
    ) sr3_1 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr3_1_in_re),
        .data_in_imag(sr3_1_in_im),
        .data_out_real(sr3_1_out_re),
        .data_out_imag(sr3_1_out_im)
    );

    always_comb begin
        case (bf3_out_sel)
            2'd0: begin
                bf3_out_re = bf3_add_re;
                bf3_out_im = bf3_add_im;
            end
            2'd1: begin
                for (int i = 0; i < 16; i++) begin
                    bf3_out_re[i] = {sr3_0_out_re[i][12], sr3_0_out_re[i]};
                    bf3_out_im[i] = {sr3_0_out_im[i][12], sr3_0_out_im[i]};
                end
            end
            2'd2: begin
                for (int i = 0; i < 16; i++) begin
                    bf3_out_re[i] = {sr3_1_out_re[i][12], sr3_1_out_re[i]};
                    bf3_out_im[i] = {sr3_1_out_im[i][12], sr3_1_out_im[i]};
                end
            end
            default: begin
                bf3_out_re = bf3_add_re;
                bf3_out_im = bf3_add_im;
            end
        endcase
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            if (bf3_sign_en) begin
                bf3_sign_re[i] = -bf3_out_re[i];
                bf3_sign_im[i] = -bf3_out_im[i];
            end else begin
                bf3_sign_re[i] = bf3_out_re[i];
                bf3_sign_im[i] = bf3_out_im[i];
            end
        end
    end

top_module_02_cbfp #(
    .NUM_PARALLEL_PATHS(16),
    .OWIDTH(11),
    .BLOCK_SIZE(512), // 총 데이터 블록 크기 (512 포인트 FFT로 변경)
    .DATA_IN_WIDTH(13), // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [14:0])
    .TW_WIDTH(9),      // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
    .TW_TABLE_DEPTH(512) // Twiddle Factor ROM 깊이
) cbfp1 (
    .clk(clk),
    .rst_n(rstn),
    .di_en_saturation(cbfp_en), // FFT 시작/진행을 제어하는 enable 신호
    .bfly02_tmp_real_in(bf3_sign_re), 
    .bfly02_tmp_imag_in(bf3_sign_im),
    .do_re(do_re), // NUM_PARALLEL_PATHS 사용
    .do_im(do_im), // NUM_PARALLEL_PATHS 사용
    .do_en(do_en),
    .do_index(do_index) // NUM_PARALLEL_PATHS 사용
);

    //assign do_re = bf3_sign_re;
    //assign do_im = bf3_sign_im;


endmodule

