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
