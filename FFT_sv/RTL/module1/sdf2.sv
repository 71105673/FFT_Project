`timescale 1ns/1ps

module sdf2 #(
    parameter N = 512,
    parameter M = 512,
    parameter WIDTH = 11,
    parameter WIDTH_DO = 12
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
    logic sr1_in_sel;
    logic sr1_out_sel;
    logic fac8_0_sel;
    logic [1:0]bf1_out_sel;

    logic bf2_out_en;
    logic sr2_in_sel;
    logic sr2_out_sel;
    logic [1:0] bf2_out_sel;
    logic [1:0] fac8_1_sel;

    logic bf3_out_en;

    logic bf1_sign_en;
    logic bf2_sign_en;

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
        rod1_sign_en = 1'b0;
        cbfp_en = 1'b0;

        // 1~32 -> bf1_in_en
        if ((do_count >= 6'd1) && (do_count <= 6'd32)) bf1_in_en = 1'b1;
        else bf1_in_en = 1'b0;

        // 3~34 -> bf1_out_en
        if ((do_count >= 6'd3) && (do_count <= 6'd34)) bf1_out_en = 1'b1;
        else bf1_out_en = 1'b0;

        // sr1_in_sel sr1_out_sel
        if (((do_count >= 6'd5) && (do_count <= 6'd8))
                ||((do_count >= 6'd13) && (do_count <= 6'd16))
                ||((do_count >= 6'd21) && (do_count <= 6'd24))
                ||((do_count >= 6'd29) && (do_count <= 6'd32))) begin
            sr1_in_sel  = 1'b1;
            sr1_out_sel = 1'b1;
        end else begin
            sr1_in_sel  = 1'b0;
            sr1_out_sel = 1'b0;
        end

        // bf1_out_sel 1
        if (((do_count >= 6'd5) && (do_count <= 6'd6))
                ||((do_count >= 6'd13) && (do_count <= 6'd14))
                ||((do_count >= 6'd21) && (do_count <= 6'd22))
                ||((do_count >= 6'd29) && (do_count <= 6'd30))) 
                bf1_out_sel = 2'd1;
        // bf1_out_sel 2
        else if (((do_count >= 6'd9) && (do_count <= 6'd10))
                ||((do_count >= 6'd17) && (do_count <= 6'd18))
                ||((do_count >= 6'd25) && (do_count <= 6'd26))
                ||((do_count >= 6'd33) && (do_count <= 6'd34))) 
                bf1_out_sel = 2'd2;
        else bf1_out_sel = 2'd0;


        // 27~34 -> fac8_0_en
        if ((do_count == 6'd6) || (do_count == 6'd10)
                ||(do_count == 6'd14) || (do_count == 6'd18)
                ||(do_count == 6'd22) || (do_count == 6'd26)
                ||(do_count == 6'd30) || (do_count == 6'd34)) 
                fac8_0_sel = 1'b1;
        else fac8_0_sel = 1'b0;

        // 4~35 -> bf2_out_en
        if ((do_count >= 6'd4) && (do_count <= 6'd35)) bf2_out_en = 1'b1;
        else bf2_out_en = 1'b0;




        // bf2_out_sel 1
        if ((do_count == 6'd5) || (do_count == 6'd9)
            ||(do_count == 6'd13) || (do_count == 6'd17)
            ||(do_count == 6'd21) || (do_count == 6'd25)
            ||(do_count == 6'd29) || (do_count == 6'd33)) 
            bf2_out_sel = 2'd1;
        // bf2_out_sel 2
        else if ((do_count == 6'd7) || (do_count == 6'd11)
            ||(do_count == 6'd15) || (do_count == 6'd19)
            ||(do_count == 6'd23) || (do_count == 6'd27)
            ||(do_count == 6'd31) || (do_count == 6'd35)) 
            bf2_out_sel = 2'd2;
        else bf2_out_sel = 2'b00;

        // fac8_1_sel 1
        if ((do_count == 6'd5) || (do_count == 6'd9)
            ||(do_count == 6'd13) || (do_count == 6'd17)
            ||(do_count == 6'd21) || (do_count == 6'd25)
            ||(do_count == 6'd29) || (do_count == 6'd33)) fac8_1_sel = 2'd1;
        // fac8_1_sel 2
        else if ((do_count == 6'd6) || (do_count == 6'd10)
            ||(do_count == 6'd14) || (do_count == 6'd18)
            ||(do_count == 6'd22) || (do_count == 6'd26)
            ||(do_count == 6'd30) || (do_count == 6'd34)) fac8_1_sel = 2'd2;
        // fac8_1_sel 3
        else if ((do_count == 6'd7) || (do_count == 6'd11)
            ||(do_count == 6'd15) || (do_count == 6'd19)
            ||(do_count == 6'd23) || (do_count == 6'd27)
            ||(do_count == 6'd31) || (do_count == 6'd35)) fac8_1_sel = 2'd3;
        else fac8_1_sel = 1'b0;

        // bf3_out_en
        //if ((do_count >= 6'd29) && (do_count <= 6'd60)) bf3_out_en = 1'b1;
        //else bf3_out_en = 1'b0;

        if (((do_count >= 6'd5) && (do_count <= 6'd6))
            ||((do_count >= 6'd13) && (do_count <= 6'd14))
            ||((do_count >= 6'd21) && (do_count <= 6'd22))
            ||((do_count >= 6'd29) && (do_count <= 6'd30))
            ||((do_count >= 6'd9) && (do_count <= 6'd10))
            ||((do_count >= 6'd17) && (do_count <= 6'd18))
            ||((do_count >= 6'd25) && (do_count <= 6'd26))
            ||((do_count >= 6'd33) && (do_count <= 6'd34))) begin
                sr2_in_sel  = 1'b1;
                sr2_out_sel = 1'b1;
                bf1_sign_en = 1'b1;
            end
        else begin 
            sr2_in_sel  = 1'b0;
            sr2_out_sel = 1'b0;
            bf1_sign_en = 1'b0;
        end


        // if (((do_count >= 6'd21) && (do_count <= 6'd22))
        //     ||((do_count >= 6'd29) && (do_count <= 6'd30))
        //     ||((do_count >= 6'd25) && (do_count <= 6'd26))
        //     ||((do_count >= 6'd33) && (do_count <= 6'd34))
        //     ||()) begin
        //         bf1_sign_en = 1'b1;

        //     end
        // else begin 
        //     bf1_sign_en = 1'b0;
        // end




        if ((do_count == 6'd5) || (do_count == 6'd9)
            ||(do_count == 6'd13) || (do_count == 6'd17)
            ||(do_count == 6'd21) || (do_count == 6'd25)
            ||(do_count == 6'd29) || (do_count == 6'd33)
            ||(do_count == 6'd7) || (do_count == 6'd11)
            ||(do_count == 6'd15) || (do_count == 6'd19)
            ||(do_count == 6'd23) || (do_count == 6'd27)
            ||(do_count == 6'd31) || (do_count == 6'd35)) 
            bf2_sign_en = 1'b1;
        else bf2_sign_en = 1'b0;



        if ((do_count >= 6'd6) && (do_count <= 7'd46)) cbfp_en = 1'b1;
        else cbfp_en = 1'b0;

    end

    // step.0
    logic signed [WIDTH-1:0] sr1_out_re [0:15];
    logic signed [WIDTH-1:0] sr1_out_im [0:15];
    logic signed [WIDTH-1:0] sr1_0_out_re_sat [0:15];
    logic signed [WIDTH-1:0] sr1_0_out_im_sat [0:15];
    logic signed [WIDTH-1:0] sr1_1_out_re_sat [0:15];
    logic signed [WIDTH-1:0] sr1_1_out_im_sat [0:15];
    logic signed [WIDTH:0] sr1_0_out_re [0:15];
    logic signed [WIDTH:0] sr1_0_out_im [0:15];
    logic signed [WIDTH:0] sr1_1_out_re [0:15];
    logic signed [WIDTH:0] sr1_1_out_im [0:15];
    logic signed [WIDTH:0] sr1_0_in_re [0:15];
    logic signed [WIDTH:0] sr1_0_in_im [0:15];
    logic signed [WIDTH:0] sr1_1_in_re [0:15];
    logic signed [WIDTH:0] sr1_1_in_im [0:15];
    logic signed [WIDTH:0] bf1_add_re [0:15];
    logic signed [WIDTH:0] bf1_add_im [0:15];
    logic signed [WIDTH:0] bf1_sign_re[0:15];
    logic signed [WIDTH:0] bf1_sign_im[0:15];
    logic signed [WIDTH:0] bf1_dif_re [0:15];
    logic signed [WIDTH:0] bf1_dif_im [0:15];
    logic signed [WIDTH:0] bf1_rot_re [0:15];
    logic signed [WIDTH:0] bf1_rot_im [0:15];
    logic signed [WIDTH-1:0] di_buf_re  [0:15];
    logic signed [WIDTH-1:0] di_buf_im  [0:15];
    logic signed [WIDTH-1:0] di_buf2_re  [0:15];
    logic signed [WIDTH-1:0] di_buf2_im  [0:15];
    logic signed [WIDTH:0] bf1_out_re [0:15];
    logic signed [WIDTH:0] bf1_out_im [0:15];

    delay_buf #(
        .WIDTH(11)
    ) buf1 (
        .clk(clk),
        .rstn(rstn),
        .din_re(di_re),
        .din_im(di_im),
        .dout_re(di_buf_re),
        .dout_im(di_buf_im)
    );
    delay_buf #(
        .WIDTH(11)
    ) buf2 (
        .clk(clk),
        .rstn(rstn),
        .din_re(di_buf_re),
        .din_im(di_buf_im),
        .dout_re(di_buf2_re),
        .dout_im(di_buf2_im)
    );
    butterfly2 #(
        .WIDTH(11)
    ) bf2_1 (
        .in_en (bf1_in_en),
        .out_en(bf1_out_en),
        .x0_re (di_buf2_re),
        .x0_im (di_buf2_im),
        .x1_re (sr1_out_re),
        .x1_im (sr1_out_im),
        .y0_re (bf1_add_re),
        .y0_im (bf1_add_im),
        .y1_re (bf1_dif_re),
        .y1_im (bf1_dif_im)
    );

    always_comb begin
        if (sr1_in_sel == 1'b0) begin
            sr1_0_in_re = bf1_dif_re;
            sr1_0_in_im = bf1_dif_im;
            for (int i = 0; i < 16; i++) begin
                sr1_1_in_re[i] = '0;
                sr1_1_in_im[i] = '0;
            end
        end else begin
            for (int i = 0; i < 16; i++) begin
                sr1_0_in_re[i] = '0;
                sr1_0_in_im[i] = '0;
            end
            sr1_1_in_re = bf1_dif_re;
            sr1_1_in_im = bf1_dif_im;
        end
    end

saturation #(
    .LENGTH(11), 
    .NUM_PARALLEL_PATHS(16) 
) sat1 (
    .bfly02_tmp_real_in(sr1_0_out_re), // 입력은 LENGTH + 1 비트
    .bfly02_tmp_imag_in(sr1_0_out_im),
    .bfly02_tmp_real_saturated(sr1_0_out_re_sat), // 출력은 LENGTH 비트
    .bfly02_tmp_imag_saturated(sr1_0_out_im_sat)
);
saturation #(
    .LENGTH(11), 
    .NUM_PARALLEL_PATHS(16) 
) sat2(
    .bfly02_tmp_real_in(sr1_1_out_re), // 입력은 LENGTH + 1 비트
    .bfly02_tmp_imag_in(sr1_1_out_im),
    .bfly02_tmp_real_saturated(sr1_1_out_re_sat), // 출력은 LENGTH 비트
    .bfly02_tmp_imag_saturated(sr1_1_out_im_sat)
);

    always_comb begin
        if (sr1_out_sel == 1'b0) begin
            sr1_out_re = sr1_0_out_re_sat;
            sr1_out_im = sr1_0_out_im_sat;
        end else begin
            sr1_out_re = sr1_1_out_re_sat;
            sr1_out_im = sr1_1_out_im_sat;
        end
    end
    shift_reg #(
        .WIDTH(12),
        .DELAY_LENGTH(2)
    ) sr1_0 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr1_0_in_re),
        .data_in_imag(sr1_0_in_im),
        .data_out_real(sr1_0_out_re),
        .data_out_imag(sr1_0_out_im)
    );
    
    shift_reg #(
        .WIDTH(12),
        .DELAY_LENGTH(2)
    ) sr1_1 (
        .clk(clk),
        .rstn(rstn),
        .data_in_real(sr1_1_in_re),
        .data_in_imag(sr1_1_in_im),
        .data_out_real(sr1_1_out_re),
        .data_out_imag(sr1_1_out_im)
    );
    
    always_comb begin
        case (bf1_out_sel)
            2'd0: begin
                bf1_out_re = bf1_add_re;
                bf1_out_im = bf1_add_im;
            end
            2'd1: begin
                bf1_out_re = sr1_0_out_re;
                bf1_out_im = sr1_0_out_im;

            end
            2'd2: begin
                bf1_out_re = sr1_1_out_re;
                bf1_out_im = sr1_1_out_im;
            end
            default: begin
                bf1_out_re = bf1_add_re;
                bf1_out_im = bf1_add_im;
            end
        endcase
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            if (bf1_sign_en) begin
                bf1_sign_re[i] = -bf1_out_re[i];
                bf1_sign_im[i] = -bf1_out_im[i];
            end else begin
                bf1_sign_re[i] = bf1_out_re[i];
                bf1_sign_im[i] = bf1_out_im[i];
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
    logic signed [WIDTH:0] sr2_0_in_re[0:15];
    logic signed [WIDTH:0] sr2_0_in_im[0:15];
    logic signed [WIDTH:0] sr2_1_in_re[0:15];
    logic signed [WIDTH:0] sr2_1_in_im[0:15];
    logic signed [WIDTH:0] sr2_0_out_re[0:15];
    logic signed [WIDTH:0] sr2_0_out_im[0:15];
    logic signed [WIDTH:0] sr2_1_out_re[0:15];
    logic signed [WIDTH:0] sr2_1_out_im[0:15];
    logic signed [WIDTH:0] sr2_out_re[0:15];
    logic signed [WIDTH:0] sr2_out_im[0:15];
    logic signed [WIDTH+1:0] bf2_add_re[0:15];
    logic signed [WIDTH+1:0] bf2_add_im[0:15];
    logic signed [WIDTH:0] bf2_dif_re[0:15];
    logic signed [WIDTH:0] bf2_dif_im[0:15];
    logic signed [WIDTH+1:0] bf2_out_re[0:15];
    logic signed [WIDTH+1:0] bf2_out_im[0:15];
    logic signed [WIDTH+1:0] bf2_sign_re[0:15];
    logic signed [WIDTH+1:0] bf2_sign_im[0:15];
    logic signed [WIDTH+11:0] bf2_rot_re[0:15];
    logic signed [WIDTH+11:0] bf2_rot_im[0:15];
    logic signed [WIDTH+3:0] bf2_rod_re[0:15];
    logic signed [WIDTH+3:0] bf2_rod_im[0:15];

    butterfly #(
        .WIDTH(12)
    ) bf2_2 (
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

    delaybuffer_cbfp #(
        .DEPTH(16),
        .WIDTH(12)
    ) sr2_0 (
        .clk(clk),
        .rstn(rstn),
        .di_re(sr2_0_in_re),
        .di_im(sr2_0_in_im),
        .do_re(sr2_0_out_re),
        .do_im(sr2_0_out_im)
    );
    delaybuffer_cbfp #(
        .DEPTH(16),
        .WIDTH(12)
    ) sr2_1 (
        .clk(clk),
        .rstn(rstn),
        .di_re(sr2_1_in_re),
        .di_im(sr2_1_in_im),
        .do_re(sr2_1_out_re),
        .do_im(sr2_1_out_im)
    );


    always_comb begin
        case (bf2_out_sel)
            2'd0: begin
                bf2_out_re = bf2_add_re;
                bf2_out_im = bf2_add_im;
            end
            2'd1: begin
                for (int i = 0; i < 16; i++) begin
                    bf2_out_re[i] = {sr2_0_out_re[i][11], sr2_0_out_re[i]};
                    bf2_out_im[i] = {sr2_0_out_im[i][11], sr2_0_out_im[i]};
                end
            end
            2'd2: begin
                for (int i = 0; i < 16; i++) begin
                    bf2_out_re[i] = {sr2_1_out_re[i][11], sr2_1_out_re[i]};
                    bf2_out_im[i] = {sr2_1_out_im[i][11], sr2_1_out_im[i]};
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
        for (int i = 0; i < 8; i++) begin
            case (fac8_1_sel)
                2'd0: begin
                    bf2_rot_re[i] = -bf2_sign_re[i] * 9'sd256;
                    bf2_rot_im[i] = -bf2_sign_im[i] * 9'sd256;
                    bf2_rot_re[i+8] = -bf2_sign_re[i+8] * 9'sd256;
                    bf2_rot_im[i+8] = -bf2_sign_im[i+8] * 9'sd256;
                end
                2'd1: begin
                    bf2_rot_re[i] = -bf2_sign_re[i] * 9'sd256;
                    bf2_rot_im[i] = -bf2_sign_im[i] * 9'sd256;
                    bf2_rot_re[i+8] = -bf2_sign_im[i+8] * 9'sd256;
                    bf2_rot_im[i+8] = bf2_sign_re[i+8] * 9'sd256;
                end
                2'd2: begin
                    bf2_rot_re[i] = -bf2_sign_re[i] * 9'sd256;
                    bf2_rot_im[i] = -bf2_sign_im[i] * 9'sd256;
                    bf2_rot_re[i+8] = 9'sd181 * bf2_sign_re[i+8] + 9'sd181 * bf2_sign_im[i+8];
                    bf2_rot_im[i+8] = 9'sd181 * bf2_sign_im[i+8] - 9'sd181 * bf2_sign_re[i+8];
                end
                2'd3: begin
                    bf2_rot_re[i] = -bf2_sign_re[i] * 9'sd256;
                    bf2_rot_im[i] = -bf2_sign_im[i] * 9'sd256;
                    bf2_rot_re[i+8] = -9'sd181 * bf2_sign_re[i+8] + 9'sd181 * bf2_sign_im[i+8];
                    bf2_rot_im[i+8] = -9'sd181 * bf2_sign_re[i+8] - 9'sd181 * bf2_sign_im[i+8];
                end
                default: begin
                    bf2_rot_re[i] = -bf2_sign_re[i] * 9'sd256;
                    bf2_rot_im[i] = -bf2_sign_im[i] * 9'sd256;
                    bf2_rot_re[i+8] = -bf2_sign_re[i+8] * 9'sd256;
                    bf2_rot_im[i+8] = -bf2_sign_im[i+8] * 9'sd256;
                end
            endcase
        end
    end

    always_comb begin
        // Rounding Bit 기준: 비트 위치 7 아래 버림
        for (int i = 0; i < 16; i++) begin
            automatic logic signed [22:0] re_tmp, im_tmp;

            re_tmp = bf2_rot_re[i] + 13'd128;
            im_tmp = bf2_rot_im[i] + 13'd128;

            bf2_rod_re[i] = re_tmp[22:8];
            bf2_rod_im[i] = im_tmp[22:8];
        end
    end


    // step.2
logic signed [15:0] bf3_out_re [0:15];
logic signed [15:0] bf3_out_im [0:15];

butterfly_16bit bf2_3 (
    .clk(clk),
    .rstn(rstn),
    .bf3_in_re(bf2_rod_re),
    .bf3_in_im(bf2_rod_im),
    .bf3_out_re(bf3_out_re),
    .bf3_out_im(bf3_out_im)
);
   
top_module_12_cbfp #(
    .NUM_PARALLEL_PATHS(16),
    .OWIDTH(12),
    .BLOCK_SIZE(512), // 총 데이터 블록 크기 (512 포인트 FFT로 변경)
    .DATA_IN_WIDTH(15), // 버터플라이 연산 결과의 비트 폭 (예: 13이면 [14:0])
    .TW_WIDTH(9),      // Twiddle Factor의 비트 폭 (예: 9이면 [8:0])
    .TW_TABLE_DEPTH(64) // Twiddle Factor ROM 깊이
) cbfp1 (
    .clk(clk),
    .rst_n(rstn),
    .enable_fft(cbfp_en), // FFT 시작/진행을 제어하는 enable 신호
    .bfly12_tmp_real_in(bf3_out_re), 
    .bfly12_tmp_imag_in(bf3_out_im),
    .do_re(do_re), // NUM_PARALLEL_PATHS 사용
    .do_im(do_im), // NUM_PARALLEL_PATHS 사용
    .do_en(do_en),
    .do_index(do_index) // NUM_PARALLEL_PATHS 사용
);

    //assign do_re = bf3_sign_re;
    //assign do_im = bf3_sign_im;


endmodule
