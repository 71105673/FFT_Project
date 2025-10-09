`timescale 1ns/1ps

module step0_0 (
    input  logic clk,
    input  logic rst,
    input  logic valid,
    input  logic signed [8:0] din_re [0:15],
    input  logic signed [8:0] din_im [0:15],
    output logic signed [9:0] bfly00_re_p [0:15],
    output logic signed [9:0] bfly00_re_n [0:15],
    output logic signed [9:0] bfly00_im_p [0:15],
    output logic signed [9:0] bfly00_im_n [0:15],
    output logic bfly00_mul_enable
);

    logic [3:0] i, i_d1;
    logic enable_flag00;
    logic bfly00_add_sub_enable; 
    integer j;

    logic signed [8:0] sr_in_re [0:15];
    logic signed [8:0] sr_in_im [0:15];
    logic signed [8:0] step00_sr256_out_re [0:15];
    logic signed [8:0] step00_sr256_out_im [0:15];

    logic signed [9:0] add_step00_re [0:15];
    logic signed [9:0] sub_step00_re [0:15];
    logic signed [9:0] add_step00_im [0:15];
    logic signed [9:0] sub_step00_im [0:15];

    assign sr_in_re = valid ? din_re : '{default: 0};
    assign sr_in_im = valid ? din_im : '{default: 0};

    // shift register
    shift_reg #(.N(256), .FIX(9)) SR_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_in_re),
        .sr_out(step00_sr256_out_re)
    );
    shift_reg #(.N(256), .FIX(9)) SR_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_in_im),
        .sr_out(step00_sr256_out_im)
    );

    // counter
    step0_num_counter #(.NUM(16)) COUNTER_16 (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .bfly_add_sub_en(bfly00_add_sub_enable),
        .bfly_mul_en(bfly00_mul_enable)
    );

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            i <= 0;
            i_d1 <= 0;

            for (int j = 0; j < 16; j++) begin
                add_step00_re[j] <= 0;
                sub_step00_re[j] <= 0;
                add_step00_im[j] <= 0;
                sub_step00_im[j] <= 0;
                bfly00_re_p[j] <= 0;
                bfly00_re_n[j] <= 0;
                bfly00_im_p[j] <= 0;
                bfly00_im_n[j] <= 0;
            end

        end else begin
            // enable_flag00 rising
            // compute
            if (bfly00_add_sub_enable) begin
                if (i < 16) begin
                    for (j = 0; j < 16; j++) begin
                        add_step00_re[j] <= step00_sr256_out_re[j] + din_re[j];
                        sub_step00_re[j] <= step00_sr256_out_re[j] - din_re[j];
                        add_step00_im[j] <= step00_sr256_out_im[j] + din_im[j];
                        sub_step00_im[j] <= step00_sr256_out_im[j] - din_im[j];
                    end
                    i_d1 <= i;
                    
                    if(i == 15) begin
                        i_d1 <= i;
                        i <= 0;
                    end else begin
                        i <= i + 1;
                    end
                end

                if (i_d1 == 15) begin
                    i_d1 <= i;
                    i <= 0;
                end
            end

            // output
            if (bfly00_mul_enable && i_d1 < 16) begin
                if(i_d1 < 8) begin
                    for (j = 0; j < 16; j++) begin
                        bfly00_re_p[j] <= add_step00_re[j];
                        bfly00_im_p[j] <= add_step00_im[j];
                        bfly00_re_n[j] <= sub_step00_re[j];
                        bfly00_im_n[j] <= sub_step00_im[j];
                    end 
                end else begin
                    for (j = 0; j < 16; j++) begin
                        bfly00_re_p[j] <= add_step00_re[j];
                        bfly00_im_p[j] <= add_step00_im[j];
                        bfly00_re_n[j] <= sub_step00_im[j];      // Re ← Im
                        bfly00_im_n[j] <= -sub_step00_re[j];
                    end
                end
             end
        end
    end

endmodule

module step0_1 (
    input clk,
    input rst,
    input valid, // Shift Register 128 valid signal
    input signed [9:0] bfly00_re_p [0:15], // input <4.6>
    input signed [9:0] bfly00_re_n [0:15],
    input signed [9:0] bfly00_im_p [0:15],
    input signed [9:0] bfly00_im_n [0:15],

    output logic signed [12:0] bfly01_re_p [0:15], // output <7.6>
    output logic signed [12:0] bfly01_re_n [0:15],
    output logic signed [12:0] bfly01_im_p [0:15],
    output logic signed [12:0] bfly01_im_n [0:15],
    output logic step1_mul_en
);

    logic signed [9:0] sr_re_p [0:15];
    logic signed [9:0] sr_im_p [0:15];
    logic signed [9:0] sr256_re_out [0:15];
    logic signed [9:0] sr128_re_out [0:15];
    logic signed [9:0] sr256_im_out [0:15];
    logic signed [9:0] sr128_im_out [0:15];
    logic [1:0] step1_shift_type;
    logic step1_add_sub_en;
    logic [3:0] index_cnt;
    logic shift_type1_mul, shift_type3_mul;

    logic signed [10:0] add_step01_re_pp_np [0:15];
    logic signed [10:0] sub_step01_re_pn_nn [0:15];
    logic signed [10:0] add_step01_im_pp_np [0:15];
    logic signed [10:0] sub_step01_im_pn_nn [0:15];

    logic signed [20:0] mul_step01_re_pp_np [0:15];
    logic signed [20:0] mul_step01_re_pn_nn [0:15];
    logic signed [20:0] mul_step01_im_pp_np [0:15];
    logic signed [20:0] mul_step01_im_pn_nn [0:15];

    integer i, j, k;

    assign sr_re_p = (step1_shift_type == 0) ? bfly00_re_p : ((step1_shift_type == 2) ? sr256_re_out : '{default:0});
    assign sr_im_p = (step1_shift_type == 0) ? bfly00_im_p : ((step1_shift_type == 2) ? sr256_im_out : '{default:0});

    step_num_counter # (
        .NUM(8)
    ) COUNTER_8 (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .bfly_add_sub_enable(step1_add_sub_en),
        .bfly_mul_enable(step1_mul_en),
        .shift_type(step1_shift_type)
    );

    shift_reg # (
        .N(128),
        .FIX(10)
    ) SR128_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_re_p),
        .sr_out(sr128_re_out)
    );

    shift_reg # (
        .N(256),
        .FIX(10)
    ) SR256_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly00_re_n),
        .sr_out(sr256_re_out)
    );

    shift_reg # (
        .N(128),
        .FIX(10)
    ) SR128_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_im_p),
        .sr_out(sr128_im_out)
    );

    shift_reg # (
        .N(256),
        .FIX(10)
    ) SR256_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly00_im_n),
        .sr_out(sr256_im_out)
    );

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            for(j = 0; j < 16; j++) begin
                add_step01_re_pp_np[j] <= 0;
                sub_step01_re_pn_nn[j] <= 0;
                add_step01_im_pp_np[j] <= 0;
                sub_step01_im_pn_nn[j] <= 0;
                mul_step01_re_pp_np[j] <= 0;
                mul_step01_re_pn_nn[j] <= 0;
                mul_step01_im_pp_np[j] <= 0;
                mul_step01_im_pn_nn[j] <= 0;
            end
            
            index_cnt <= 0;

        end else begin // add & sub <4.6> + <4.6> = <5.6>
            if((step1_shift_type == 1) && step1_add_sub_en) begin
                for(j = 0; j < 16; j++) begin
                    add_step01_re_pp_np[j] <= sr128_re_out[j] + bfly00_re_p[j];
                    sub_step01_re_pn_nn[j] <= sr128_re_out[j] - bfly00_re_p[j];
                    add_step01_im_pp_np[j] <= sr128_im_out[j] + bfly00_im_p[j];
                    sub_step01_im_pn_nn[j] <= sr128_im_out[j] - bfly00_im_p[j];
                end

            end else if ((step1_shift_type == 3) && step1_add_sub_en) begin
                for (j = 0; j < 16; j++) begin
                    add_step01_re_pp_np[j] <= sr128_re_out[j] + sr256_re_out[j];
                    sub_step01_re_pn_nn[j] <= sr128_re_out[j] - sr256_re_out[j];
                    add_step01_im_pp_np[j] <= sr128_im_out[j] + sr256_im_out[j];
                    sub_step01_im_pn_nn[j] <= sr128_im_out[j] - sr256_im_out[j];
                end                
            end

            if(step1_mul_en) begin // twf factor multiply <5.6> * <2.8> = <7.14>
                index_cnt <= index_cnt + 1;
                if(index_cnt < 4) begin
                    for(j = 0; j < 16; j++) begin
                        mul_step01_re_pp_np[j] <= add_step01_re_pp_np[j] * 256 + 128;
                        mul_step01_re_pn_nn[j] <= sub_step01_re_pn_nn[j] * 256 + 128;
                        mul_step01_im_pp_np[j] <= add_step01_im_pp_np[j] * 256 + 128;
                        mul_step01_im_pn_nn[j] <= sub_step01_im_pn_nn[j] * 256 + 128;
                    end
                end else if(index_cnt < 8) begin
                    for(j = 0; j < 16; j++) begin
                        mul_step01_re_pp_np[j] <= add_step01_re_pp_np[j] * 256 + 128;
                        mul_step01_re_pn_nn[j] <= sub_step01_im_pn_nn[j] * 256 + 128;
                        mul_step01_im_pp_np[j] <= add_step01_im_pp_np[j] * 256 + 128;   
                        mul_step01_im_pn_nn[j] <= sub_step01_re_pn_nn[j] * (-256) + 128;
                    end
                end else if(index_cnt < 12) begin
                    for(j = 0; j < 16; j++) begin
                        mul_step01_re_pp_np[j] <= add_step01_re_pp_np[j] * 256 + 128;
                        mul_step01_re_pn_nn[j] <= sub_step01_re_pn_nn[j] * 256 + 128; 
                        mul_step01_im_pp_np[j] <= add_step01_im_pp_np[j] * 256 + 128;
                        mul_step01_im_pn_nn[j] <= sub_step01_im_pn_nn[j] * 256 + 128; 
                    end
                end else if(index_cnt < 16) begin
                    for(j = 0; j < 16; j++) begin
                        mul_step01_re_pp_np[j] <= (add_step01_re_pp_np[j] * 181 + add_step01_im_pp_np[j] * 181) + 128; // 181-j181
                        mul_step01_re_pn_nn[j] <= sub_step01_re_pn_nn[j] * (-181) + sub_step01_im_pn_nn[j] * 181 + 128; // -181-j181
                        mul_step01_im_pp_np[j] <= add_step01_im_pp_np[j] * 181 - add_step01_re_pp_np[j] * 181 + 128 ; // 181-j181
                        mul_step01_im_pn_nn[j] <= sub_step01_im_pn_nn[j] * (-181) - sub_step01_re_pn_nn[j] * 181 + 128 ; // -181-j181
                    end
                end
            end
        end
    end

    always_comb begin
        for(k = 0; k < 16; k++) begin // Rounding 8 bit <7.14> -> <7.6>
            bfly01_re_p[k] = mul_step01_re_pp_np[k] >>> 8;
            bfly01_re_n[k] = mul_step01_re_pn_nn[k] >>> 8;
            bfly01_im_p[k] = mul_step01_im_pp_np[k] >>> 8;
            bfly01_im_n[k] = mul_step01_im_pn_nn[k] >>> 8;
        end       
    end
endmodule

module step0_2 (
    input clk,
    input rst,
    input valid,
    input logic signed [12:0] bfly01_re_p [0:15], // input <7.6>
    input logic signed [12:0] bfly01_re_n [0:15],
    input logic signed [12:0] bfly01_im_p [0:15],
    input logic signed [12:0] bfly01_im_n [0:15],

    output logic signed [22:0] bfly02_re_p [0:15],
    output logic signed [22:0] bfly02_re_n [0:15],
    output logic signed [22:0] bfly02_im_p [0:15],
    output logic signed [22:0] bfly02_im_n [0:15],
    output logic cbfp_valid
);

    integer i, j;

    logic step2_add_sub_en;
    logic [1:0] step2_shift_type;
    

    logic signed [12:0] sr_re_p [0:15];
    logic signed [12:0] sr_im_p [0:15];

    logic signed [12:0] sr128_re_out [0:15];
    logic signed [12:0] sr64_re_out [0:15];
    logic signed [12:0] sr128_im_out [0:15];
    logic signed [12:0] sr64_im_out [0:15];

    logic signed [13:0] add_step02_re_pp_np [0:15];
    logic signed [13:0] sub_step02_re_pn_nn [0:15];
    logic signed [13:0] add_step02_im_pp_np [0:15];
    logic signed [13:0] sub_step02_im_pn_nn [0:15]; // 원래 14인데, 조합으로 saturation, sign extension
    
    logic signed [13:0] ext_step02_re_pp_np [0:15];
    logic signed [13:0] ext_step02_re_pn_nn [0:15];
    logic signed [13:0] ext_step02_im_pp_np [0:15];
    logic signed [13:0] ext_step02_im_pn_nn [0:15]; // 원래 14인데, 조합으로 saturation, sign extension


    logic signed [8:0] m0_twf_r_add [0:15];
    logic signed [8:0] m0_twf_r_sub [0:15];
    logic signed [8:0] m0_twf_i_add [0:15];
    logic signed [8:0] m0_twf_i_sub [0:15];

    assign sr_re_p = (step2_shift_type == 0) ? bfly01_re_p : ((step2_shift_type == 2) ? sr128_re_out : '{default:0});
    assign sr_im_p = (step2_shift_type == 0) ? bfly01_im_p : ((step2_shift_type == 2) ? sr128_im_out : '{default:0});

    step_num_counter # (
        .NUM(4)
    ) COUNTER_4 (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .bfly_add_sub_enable(step2_add_sub_en),
        .bfly_mul_enable(step2_mul_en),
        .shift_type(step2_shift_type)
    );

    shift_reg # (
        .N(64),
        .FIX(13)
    ) SR64_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_re_p),
        .sr_out(sr64_re_out)
    );

    shift_reg # (
        .N(128),
        .FIX(13)
    ) SR128_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly01_re_n),
        .sr_out(sr128_re_out)
    );

    shift_reg # (
        .N(64),
        .FIX(13)
    ) SR64_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_im_p),
        .sr_out(sr64_im_out)
    );

    shift_reg # (
        .N(128),
        .FIX(13)
    ) SR128_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly01_im_n),
        .sr_out(sr128_im_out)
    );

    twf512 TWF512 (
        .clk(clk),
        .rst(rst),
        .valid(step2_add_sub_en),
        .twf_r_add(m0_twf_r_add),
        .twf_r_sub(m0_twf_r_sub),
        .twf_i_add(m0_twf_i_add),
        .twf_i_sub(m0_twf_i_sub)
    );

    always_ff @( posedge clk or negedge rst ) begin
        if (~rst) begin
            for (j = 0; j < 16; j++) begin
                add_step02_re_pp_np[j] <= '0;
                sub_step02_re_pn_nn[j] <= '0;
                add_step02_im_pp_np[j] <= '0;
                sub_step02_im_pn_nn[j] <= '0;
            end
            cbfp_valid <= 0;
        end else begin // add & sub <7.6> + <7.6> = <8.6>

            cbfp_valid <= step2_mul_en;

            if((step2_shift_type == 1) && step2_add_sub_en) begin
                for(j = 0; j < 16; j++) begin
                    add_step02_re_pp_np[j] <= sr64_re_out[j] + bfly01_re_p[j];
                    sub_step02_re_pn_nn[j] <= sr64_re_out[j] - bfly01_re_p[j];
                    add_step02_im_pp_np[j] <= sr64_im_out[j] + bfly01_im_p[j];
                    sub_step02_im_pn_nn[j] <= sr64_im_out[j] - bfly01_im_p[j];
                end
            end else if ((step2_shift_type == 3) && step2_add_sub_en) begin
                for (j = 0; j < 16; j++) begin
                    add_step02_re_pp_np[j] <= sr64_re_out[j] + sr128_re_out[j];
                    sub_step02_re_pn_nn[j] <= sr64_re_out[j] - sr128_re_out[j];
                    add_step02_im_pp_np[j] <= sr64_im_out[j] + sr128_im_out[j];
                    sub_step02_im_pn_nn[j] <= sr64_im_out[j] - sr128_im_out[j];
                end                
            end

            if(step2_mul_en) begin // 14bit * 9bit = 23bit
                for(j = 0; j < 16; j++) begin
                    bfly02_re_p[j] <= ext_step02_re_pp_np[j] * m0_twf_r_add[j] - ext_step02_im_pp_np[j] * m0_twf_i_add[j];
                    bfly02_re_n[j] <= ext_step02_re_pn_nn[j] * m0_twf_r_sub[j] - ext_step02_im_pn_nn[j] * m0_twf_i_sub[j];
                    bfly02_im_p[j] <= ext_step02_im_pp_np[j] * m0_twf_r_add[j] + ext_step02_re_pp_np[j] * m0_twf_i_add[j];
                    bfly02_im_n[j] <= ext_step02_im_pn_nn[j] * m0_twf_r_sub[j] + ext_step02_re_pn_nn[j] * m0_twf_i_sub[j];
                end
            end 
        end
    end
    
    always_comb begin
        for (i = 0; i < 16; i++) begin
            ext_step02_re_pp_np[i] = (add_step02_re_pp_np[i] > 4095)  ? 14'sd4095 :
                                    (add_step02_re_pp_np[i] < -4096) ? -14'sd4096 :
                                    {add_step02_re_pp_np[i][12], add_step02_re_pp_np[i]};

            ext_step02_re_pn_nn[i] = (sub_step02_re_pn_nn[i] > 4095)  ? 14'sd4095 :
                                    (sub_step02_re_pn_nn[i] < -4096) ? -14'sd4096 :
                                    {sub_step02_re_pn_nn[i][12], sub_step02_re_pn_nn[i]};

            ext_step02_im_pp_np[i] = (add_step02_im_pp_np[i] > 4095)  ? 14'sd4095 :
                                    (add_step02_im_pp_np[i] < -4096) ? -14'sd4096 :
                                    {add_step02_im_pp_np[i][12], add_step02_im_pp_np[i]};

            ext_step02_im_pn_nn[i] = (sub_step02_im_pn_nn[i] > 4095)  ? 14'sd4095 :
                                    (sub_step02_im_pn_nn[i] < -4096) ? -14'sd4096 :
                                    {sub_step02_im_pn_nn[i][12], sub_step02_im_pn_nn[i]};
        end
    end


endmodule
