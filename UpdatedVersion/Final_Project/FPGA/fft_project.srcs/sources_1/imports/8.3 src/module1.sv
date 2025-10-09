`timescale 1ns/1ps

module step1_0 (
    input  logic clk,
    input  logic rst,
    input  logic valid,
    input  logic signed [10:0] din_re [0:15],
    input  logic signed [10:0] din_im [0:15],
    output logic signed [11:0] bfly10_re_p [0:15],
    output logic signed [11:0] bfly10_re_n [0:15],
    output logic signed [11:0] bfly10_im_p [0:15],
    output logic signed [11:0] bfly10_im_n [0:15],
    output logic bfly10_mul_enable
);

    logic [3:0] i, i_d1;
    logic enable_flag00;
    logic bfly10_add_sub_enable; 
    integer j;
    logic index_cnt;
    logic signed [10:0] sr_in_re [0:15];
    logic signed [10:0] sr_in_im [0:15];
    logic signed [10:0] step10_sr32_out_re [0:15];
    logic signed [10:0] step10_sr32_out_im [0:15];

    logic signed [11:0] add_step10_re [0:15];
    logic signed [11:0] sub_step10_re [0:15];
    logic signed [11:0] add_step10_im [0:15];
    logic signed [11:0] sub_step10_im [0:15];

    assign sr_in_re = valid ? din_re : '{default: 0};
    assign sr_in_im = valid ? din_im : '{default: 0};

    // shift register
    shift_reg #(.N(32), .FIX(11)) SR_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_in_re),
        .sr_out(step10_sr32_out_re)
    );
    shift_reg #(.N(32), .FIX(11)) SR_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_in_im),
        .sr_out(step10_sr32_out_im)
    );

    // counter
    step10_num_counter #(.NUM(2)) COUNTER_2 (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .bfly_add_sub_en(bfly10_add_sub_enable),
        .bfly_mul_en(bfly10_mul_enable)
    );

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            i <= 0;
            i_d1 <= 0;

            for (int j = 0; j < 16; j++) begin
                add_step10_re[j] <= 0;
                sub_step10_re[j] <= 0;
                add_step10_im[j] <= 0;
                sub_step10_im[j] <= 0;
                bfly10_re_p[j] <= 0;
                bfly10_re_n[j] <= 0;
                bfly10_im_p[j] <= 0;
                bfly10_im_n[j] <= 0;
            end
	    index_cnt <= 0;

        end else begin
            // enable_flag00 rising
            // compute
            if (bfly10_add_sub_enable) begin
                if (i < 2) begin
                    for (j = 0; j < 16; j++) begin
                        add_step10_re[j] <= step10_sr32_out_re[j] + din_re[j];
                        sub_step10_re[j] <= step10_sr32_out_re[j] - din_re[j];
                        add_step10_im[j] <= step10_sr32_out_im[j] + din_im[j];
                        sub_step10_im[j] <= step10_sr32_out_im[j] - din_im[j];
                    end
                    i_d1 <= i;
                    
                    if(i == 1) begin
                        i_d1 <= i;
                        i <= 0;
                    end else begin
                        i <= i + 1;
                    end
                end

                if (i_d1 == 1) begin
                    i_d1 <= i;
                    i <= 0;
                end
            end else begin
                i_d1 <= 0;
            end

            // output
            /*if (bfly10_mul_enable && i_d1 < 2) begin
                if(i_d1 < 1) begin
                    for (j = 0; j < 16; j++) begin
                        bfly10_re_p[j] <= add_step10_re[j];
                        bfly10_im_p[j] <= add_step10_im[j];
                        bfly10_re_n[j] <= sub_step10_re[j];
                        bfly10_im_n[j] <= sub_step10_im[j];
                    end 
                end else begin
                    for (j = 0; j < 16; j++) begin
                        bfly10_re_p[j] <= add_step10_re[j];
                        bfly10_im_p[j] <= add_step10_im[j];
                        bfly10_re_n[j] <= sub_step10_im[j];      // Re ← Im
                        bfly10_im_n[j] <= -sub_step10_re[j];
                    end
                end
             end
             */
            if (bfly10_mul_enable) begin
               
                if(index_cnt ==0) begin
                    for (j = 0; j < 16; j++) begin
                        bfly10_re_p[j] <= add_step10_re[j];
                        bfly10_im_p[j] <= add_step10_im[j];
                        bfly10_re_n[j] <= sub_step10_re[j];
                        bfly10_im_n[j] <= sub_step10_im[j];
                    end 
                end else if (index_cnt == 1) begin
                    for (j = 0; j < 16; j++) begin
                        bfly10_re_p[j] <= add_step10_re[j];
                        bfly10_im_p[j] <= add_step10_im[j];
                        bfly10_re_n[j] <= sub_step10_im[j];      // Re ← Im
                        bfly10_im_n[j] <= -sub_step10_re[j];
                    end
                end
                index_cnt <= index_cnt +1;
             end
        end
    end

endmodule



module step1_1 (
    input clk,
    input rst,
    input valid, // Shift Register 128 valid signal
    input signed [11:0] bfly10_re_p [0:15], // input <4.6>
    input signed [11:0] bfly10_re_n [0:15],
    input signed [11:0] bfly10_im_p [0:15],
    input signed [11:0] bfly10_im_n [0:15],

    output logic signed [13:0] bfly11_re_p [0:15], // output <7.6>
    output logic signed [13:0] bfly11_re_n [0:15],
    output logic signed [13:0] bfly11_im_p [0:15],
    output logic signed [13:0] bfly11_im_n [0:15],
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

    logic signed [21:0] mul_step11_re_pp_np [0:15];
    logic signed [21:0] mul_step11_re_pn_nn [0:15];
    logic signed [21:0] mul_step11_im_pp_np [0:15];
    logic signed [21:0] mul_step11_im_pn_nn [0:15];

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
    ) SR16_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_re_p),
        .sr_out(sr16_re_out)
    );

    shift_reg # (
        .N(32),
        .FIX(12)
    ) SR32_RE (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly10_re_n),
        .sr_out(sr32_re_out)
    );

    shift11_reg # (
        .FIX(12)
    ) SR16_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(sr_im_p),
        .sr_out(sr16_im_out)
    );

    shift_reg # (
        .N(32),
        .FIX(12)
    ) SR32_IM (
        .clk(clk),
        .rst(rst),
        .bfly_re(bfly10_im_n),
        .sr_out(sr32_im_out)
    );
        
    function automatic signed [21:0] m1_mul181(input signed [12:0] x);
        return (x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x;
    endfunction

    function automatic signed [21:0] m1_mul_neg181(input signed [12:0] x);
        return -((x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x);
    endfunction

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            for(j = 0; j < 16; j++) begin
                add_step11_re_pp_np[j] <= '0;
                sub_step11_re_pn_nn[j] <= '0;
                add_step11_im_pp_np[j] <= '0;
                sub_step11_im_pn_nn[j] <= '0;
                mul_step11_re_pp_np[j] <= '0;
                mul_step11_re_pn_nn[j] <= '0;
                mul_step11_im_pp_np[j] <= '0;
                mul_step11_im_pn_nn[j] <= '0;
                bfly11_re_p[j] <= '0;
                bfly11_re_n[j] <= '0;
                bfly11_im_p[j] <= '0;
                bfly11_im_n[j] <= '0;
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
                        bfly11_re_p[j] <= ((add_step11_re_pp_np[j] <<< 8) + 128) >>> 8;
                        bfly11_re_n[j] <= ((sub_step11_re_pn_nn[j] <<< 8) + 128) >>> 8;
                        bfly11_im_p[j] <= ((add_step11_im_pp_np[j] <<< 8) + 128) >>> 8;
                        bfly11_im_n[j] <= ((sub_step11_im_pn_nn[j] <<< 8) + 128) >>> 8;
                        bfly11_re_p[j+8] <= ((add_step11_re_pp_np[j+8] <<< 8) + 128) >>> 8;
                        bfly11_re_n[j+8] <= ((sub_step11_im_pn_nn[j+8] <<< 8) + 128) >>> 8;
                        bfly11_im_p[j+8] <= ((add_step11_im_pp_np[j+8] <<< 8) + 128) >>> 8;   
                        bfly11_im_n[j+8] <= (-(sub_step11_re_pn_nn[j+8] <<< 8) + 128) >>> 8;
                    end 
          end else if (index_cnt == 1) begin
                    for(j = 0; j < 8; j++) begin
                        bfly11_re_p[j] <= ((add_step11_re_pp_np[j] <<< 8) + 128) >>> 8;
                        bfly11_re_n[j] <= ((sub_step11_re_pn_nn[j] <<< 8) + 128) >>> 8;
                        bfly11_im_p[j] <= ((add_step11_im_pp_np[j] <<< 8) + 128) >>> 8;
                        bfly11_im_n[j] <= ((sub_step11_im_pn_nn[j] <<< 8) + 128) >>> 8;
                        bfly11_re_p[j+8] <= (m1_mul181(add_step11_re_pp_np[j+8]) + m1_mul181(add_step11_im_pp_np[j+8]) + 128) >>> 8;
                        bfly11_re_n[j+8] <= (m1_mul_neg181(sub_step11_re_pn_nn[j+8]) + m1_mul181(sub_step11_im_pn_nn[j+8]) + 128) >>> 8;
                        bfly11_im_p[j+8] <= (m1_mul181(add_step11_im_pp_np[j+8]) - m1_mul181(add_step11_re_pp_np[j+8]) + 128) >>> 8;
                        bfly11_im_n[j+8] <= (m1_mul_neg181(sub_step11_im_pn_nn[j+8]) - m1_mul181(sub_step11_re_pn_nn[j+8]) + 128) >>> 8;
                    end
                end 
                index_cnt <= index_cnt + 1;
            end
        end
    end
endmodule


module step1_2 (
    input clk,
    input rst,
    input valid,
    input logic signed [13:0] bfly11_re_p [0:15], // input <9.7>
    input logic signed [13:0] bfly11_re_n [0:15],
    input logic signed [13:0] bfly11_im_p [0:15],
    input logic signed [13:0] bfly11_im_n [0:15],

    output logic signed [24:0] bfly12_re [0:15],
    output logic signed [24:0] bfly12_im [0:15],
    output logic               cbfp_valid
);

    integer i, j;

    logic step2_add_en, step2_sub_en, step2_mul_en;  

    logic signed [15:0] add_sub_step12_re [0:15]; // pp + pn
    logic signed [15:0] add_sub_step12_im [0:15]; // np + nn <16bit> signed extension

    logic signed [8:0] m1_twf_r [0:15];
    logic signed [8:0] m1_twf_i [0:15];

    logic signed [13:0] bfly12_re_n_16_reg [0:15];
    logic signed [13:0] bfly12_im_n_16_reg [0:15];

    twf64 TWF64 (
        .clk(clk),
        .rst(rst),
        .valid(step2_add_en || step2_sub_en),
        .twf_r(m1_twf_r),
        .twf_i(m1_twf_i)
    );

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for(i = 0; i < 16; i++) begin
                add_sub_step12_re[i] <= 0;
                add_sub_step12_im[i] <= 0;
                bfly12_re_n_16_reg[i] <= 0;
                bfly12_im_n_16_reg[i] <= 0;
                bfly12_re[i] <= '0;
                bfly12_im[i] <= '0;
            end
            step2_add_en <= 0;
            step2_sub_en <= 0;
            step2_mul_en <= 0;  
            cbfp_valid <= 0;
        end else begin
            step2_add_en <= valid;
            step2_sub_en <= step2_add_en;
            step2_mul_en <= step2_add_en || step2_sub_en;
            cbfp_valid <= step2_mul_en;

            if(step2_add_en) begin
                for(i = 0; i < 16; i++) begin
                    bfly12_re_n_16_reg[i] <= bfly11_re_n[i];
                    bfly12_im_n_16_reg[i] <= bfly11_im_n[i];
                end
            end
            if (step2_add_en) begin
                for(i = 0; i < 8; i++) begin
                    add_sub_step12_re[i] <= bfly11_re_p[i] + bfly11_re_p[i+8];
                    add_sub_step12_re[i+8] <= bfly11_re_p[i] - bfly11_re_p[i+8];
                    add_sub_step12_im[i] <= bfly11_im_p[i] + bfly11_im_p[i+8];
                    add_sub_step12_im[i+8] <= bfly11_im_p[i] - bfly11_im_p[i+8];
                end 
            end
            else if (step2_sub_en) begin
                for(i = 0; i < 8; i++) begin
                    add_sub_step12_re[i] <= bfly12_re_n_16_reg[i] + bfly12_re_n_16_reg[i+8];
                    add_sub_step12_re[i+8] <= bfly12_re_n_16_reg[i] - bfly12_re_n_16_reg[i+8];
                    add_sub_step12_im[i] <= bfly12_im_n_16_reg[i] + bfly12_im_n_16_reg[i+8];
                    add_sub_step12_im[i+8] <= bfly12_im_n_16_reg[i] - bfly12_im_n_16_reg[i+8];
                end
            end
            
            if(step2_mul_en) begin
                for(i = 0; i < 16; i++) begin
                    bfly12_re[i] <= add_sub_step12_re[i] * m1_twf_r[i] - add_sub_step12_im[i] * m1_twf_i[i];
                    bfly12_im[i] <= add_sub_step12_re[i] * m1_twf_i[i] + add_sub_step12_im[i] * m1_twf_r[i];
                end
            end
        end
    end

endmodule

