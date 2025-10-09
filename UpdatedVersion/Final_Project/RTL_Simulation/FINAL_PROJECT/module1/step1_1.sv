`timescale 1ns/1ps

module step1_1 (
    input clk,
    input rst,
    input valid, // Shift Register 128 valid signal
    input signed [11:0] bfly10_re_p [0:15], // input <4.6>
    input signed [11:0] bfly10_re_n [0:15],
    input signed [11:0] bfly10_im_p [0:15],
    input signed [11:0] bfly10_im_n [0:15],

    output logic signed [14:0] bfly11_re_p [0:15], // output <7.6>
    output logic signed [14:0] bfly11_re_n [0:15],
    output logic signed [14:0] bfly11_im_p [0:15],
    output logic signed [14:0] bfly11_im_n [0:15],
    output logic step1_mul_en
);

    logic signed [11:0] sr_re_p [0:15];
    logic signed [11:0] sr_im_p [0:15];
    logic signed [11:0] sr32_re_out [0:15];
    logic signed [11:0] sr16_re_out [0:15];
    logic signed [11:0] sr32_im_out [0:15];
    logic signed [11:0] sr16_im_out [0:15];
    logic [1:0] step1_shift_type;
    logic step1_add_sub_en;
    logic index_cnt;
    logic shift_type1_mul, shift_type3_mul;

    logic signed [12:0] add_step11_re_pp_np [0:15];
    logic signed [12:0] sub_step11_re_pn_nn [0:15];
    logic signed [12:0] add_step11_im_pp_np [0:15];
    logic signed [12:0] sub_step11_im_pn_nn [0:15];

    logic signed [22:0] mul_step11_re_pp_np [0:15];
    logic signed [22:0] mul_step11_re_pn_nn [0:15];
    logic signed [22:0] mul_step11_im_pp_np [0:15];
    logic signed [22:0] mul_step11_im_pn_nn [0:15];

    integer i, j, k;

    assign sr_re_p = (step1_shift_type == 0) ? bfly10_re_p : ((step1_shift_type == 2) ? sr32_re_out : '{default:0});
    assign sr_im_p = (step1_shift_type == 0) ? bfly10_im_p : ((step1_shift_type == 2) ? sr32_im_out : '{default:0});

    step_num_counter # (
        .NUM(1)
    ) COUNTER_1 (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .bfly_add_sub_enable(step1_add_sub_en),
        .bfly_mul_enable(step1_mul_en),
        .shift_type(step1_shift_type)
    );

    shift11_reg # (
        .FIX(12)
    ) SR128_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_re_p),
        .sr_out(sr16_re_out)
    );

    shift_reg # (
        .N(32),
        .FIX(12)
    ) SR256_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly10_re_n),
        .sr_out(sr32_re_out)
    );

    shift11_reg # (
        .FIX(12)
    ) SR128_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_im_p),
        .sr_out(sr16_im_out)
    );

    shift_reg # (
        .N(32),
        .FIX(12)
    ) SR256_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly10_im_n),
        .sr_out(sr32_im_out)
    );
    

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            for(j = 0; j < 16; j++) begin
                add_step11_re_pp_np[j] <= 0;
                sub_step11_re_pn_nn[j] <= 0;
                add_step11_im_pp_np[j] <= 0;
                sub_step11_im_pn_nn[j] <= 0;
                mul_step11_re_pp_np[j] <= 0;
                mul_step11_re_pn_nn[j] <= 0;
                mul_step11_im_pp_np[j] <= 0;
                mul_step11_im_pn_nn[j] <= 0;
            end
            
            index_cnt <= 0;

        end else begin // add & sub <4.6> + <4.6> = <5.6>
            if((step1_shift_type == 1) && step1_add_sub_en) begin
                for(j = 0; j < 16; j++) begin
                    add_step11_re_pp_np[j] <= sr16_re_out[j] + bfly10_re_p[j];
                    sub_step11_re_pn_nn[j] <= sr16_re_out[j] - bfly10_re_p[j];
                    add_step11_im_pp_np[j] <= sr16_im_out[j] + bfly10_im_p[j];
                    sub_step11_im_pn_nn[j] <= sr16_im_out[j] - bfly10_im_p[j];
                end

            end else if ((step1_shift_type == 3) && step1_add_sub_en) begin
                for (j = 0; j < 16; j++) begin
                    add_step11_re_pp_np[j] <= sr16_re_out[j] + sr32_re_out[j];
                    sub_step11_re_pn_nn[j] <= sr16_re_out[j] - sr32_re_out[j];
                    add_step11_im_pp_np[j] <= sr16_im_out[j] + sr32_im_out[j];
                    sub_step11_im_pn_nn[j] <= sr16_im_out[j] - sr32_im_out[j];
                end                
            end

            if(step1_mul_en) begin // twf factor multiply <5.6> * <2.8> = <7.14>
                if(index_cnt == 0) begin
                    for(j = 0; j < 8; j++) begin
                        mul_step11_re_pp_np[j] <= add_step11_re_pp_np[j] * 256 + 128;
                        mul_step11_re_pn_nn[j] <= sub_step11_re_pn_nn[j] * 256 + 128;
                        mul_step11_im_pp_np[j] <= add_step11_im_pp_np[j] * 256 + 128;
                        mul_step11_im_pn_nn[j] <= sub_step11_im_pn_nn[j] * 256 + 128;
                        mul_step11_re_pp_np[j+8] <= add_step11_re_pp_np[j+8] * 256 + 128;
                        mul_step11_re_pn_nn[j+8] <= sub_step11_im_pn_nn[j+8] * 256 + 128;
                        mul_step11_im_pp_np[j+8] <= add_step11_im_pp_np[j+8] * 256 + 128;   
                        mul_step11_im_pn_nn[j+8] <= sub_step11_re_pn_nn[j+8] * (-256) + 128;
                    end 
		    end else if (index_cnt == 1) begin
                    for(j = 0; j < 8; j++) begin
                        mul_step11_re_pp_np[j] <= add_step11_re_pp_np[j] * 256 + 128;
                        mul_step11_re_pn_nn[j] <= sub_step11_re_pn_nn[j] * 256 + 128;
                        mul_step11_im_pp_np[j] <= add_step11_im_pp_np[j] * 256 + 128;
                        mul_step11_im_pn_nn[j] <= sub_step11_im_pn_nn[j] * 256 + 128;
                        mul_step11_re_pp_np[j+8] <= (add_step11_re_pp_np[j+8] * 181 + add_step11_im_pp_np[j+8] * 181) + 128; // 181-j181
                        mul_step11_re_pn_nn[j+8] <= sub_step11_re_pn_nn[j+8] * (-181) + sub_step11_im_pn_nn[j+8] * 181 + 128; // -181-j181
                        mul_step11_im_pp_np[j+8] <= add_step11_im_pp_np[j+8] * 181 - add_step11_re_pp_np[j+8] * 181 + 128 ; // 181-j181
                        mul_step11_im_pn_nn[j+8] <= sub_step11_im_pn_nn[j+8] * (-181) - sub_step11_re_pn_nn[j+8] * 181 + 128 ; // -181-j181
                    end
                end 
                index_cnt <= index_cnt + 1;
            end
        end
    end

    always_comb begin
        for(k = 0; k < 16; k++) begin // Rounding 8 bit <7.14> -> <7.6>
            bfly11_re_p[k] = mul_step11_re_pp_np[k] >>> 8;
            bfly11_re_n[k] = mul_step11_re_pn_nn[k] >>> 8;
            bfly11_im_p[k] = mul_step11_im_pp_np[k] >>> 8;
            bfly11_im_n[k] = mul_step11_im_pn_nn[k] >>> 8;
        end       
    end
endmodule
