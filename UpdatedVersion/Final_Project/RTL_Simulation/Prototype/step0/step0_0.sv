`timescale 1ns/1ps

module step0_0 (
    input  logic clk,
    input  logic rst,
    input  logic valid,
    input  logic signed [8:0] din_re [0:15],
    input  logic signed [8:0] din_im [0:15],
    output logic signed [9:0] bfly00_re_p [0:15][0:15],
    output logic signed [9:0] bfly00_re_n [0:15][0:15],
    output logic signed [9:0] bfly00_im_p [0:15][0:15],
    output logic signed [9:0] bfly00_im_n [0:15][0:15]
);

    logic [3:0] i, i_d1;
    logic enable_flag00;
    logic bfly00_add_sub_enable, bfly00_mul_enable;
    integer j;

    logic signed [8:0] sr_in_re [0:15];
    logic signed [8:0] sr_in_im [0:15];
    logic signed [8:0] step00_sr256_out_re [0:15];
    logic signed [8:0] step00_sr256_out_im [0:15];

    logic signed [9:0] add_step00_re [0:15][0:15];
    logic signed [9:0] sub_step00_re [0:15][0:15];
    logic signed [9:0] add_step00_im [0:15][0:15];
    logic signed [9:0] sub_step00_im [0:15][0:15];

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
    step00_num_counter #(.NUM(16)) COUNTER_16 (
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

            for (int m = 0; m < 16; m++) begin
                for (int n = 0; n < 16; n++) begin
                    add_step00_re[m][n] <= 0;
                    sub_step00_re[m][n] <= 0;
                    add_step00_im[m][n] <= 0;
                    sub_step00_im[m][n] <= 0;
                    bfly00_re_p[m][n] <= 0;
                    bfly00_re_n[m][n] <= 0;
                    bfly00_im_p[m][n] <= 0;
                    bfly00_im_n[m][n] <= 0;
                end
            end
        end else begin
            // enable_flag00 rising

            // compute
            if (bfly00_add_sub_enable) begin
                if (i < 16) begin
                    for (j = 0; j < 16; j++) begin
                        add_step00_re[i][j] <= step00_sr256_out_re[j] + din_re[j];
                        sub_step00_re[i][j] <= step00_sr256_out_re[j] - din_re[j];
                        add_step00_im[i][j] <= step00_sr256_out_im[j] + din_im[j];
                        sub_step00_im[i][j] <= step00_sr256_out_im[j] - din_im[j];
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
                        bfly00_re_p[i_d1][j] <= add_step00_re[i_d1][j];
                        bfly00_im_p[i_d1][j] <= add_step00_im[i_d1][j];
                        bfly00_re_n[i_d1][j] <= sub_step00_re[i_d1][j];
                        bfly00_im_n[i_d1][j] <= sub_step00_im[i_d1][j];
                    end 
                end else begin
                    for (j = 0; j < 16; j++) begin
                        bfly00_re_p[i_d1][j] <= add_step00_re[i_d1][j];
                        bfly00_im_p[i_d1][j] <= add_step00_im[i_d1][j];
                        bfly00_re_n[i_d1][j] <= sub_step00_im[i_d1][j];      // Re ← Im
                        bfly00_im_n[i_d1][j] <= -sub_step00_re[i_d1][j];
                    end
                end
             end
        end
    end

endmodule
