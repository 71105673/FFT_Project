`timescale 1ns/1ps

module step1_2 (
    input clk,
    input rst,
    input valid,
    input logic signed [14:0] bfly11_re_p [0:15], // input <9.7>
    input logic signed [14:0] bfly11_re_n [0:15],
    input logic signed [14:0] bfly11_im_p [0:15],
    input logic signed [14:0] bfly11_im_n [0:15],

    output logic signed [25:0] bfly12_re [0:15],
    output logic signed [25:0] bfly12_im [0:15],
    output logic               cbfp_valid
);

    integer i, j;

    logic step2_add_en, step2_sub_en, step2_mul_en;  

    logic signed [16:0] add_sub_step12_re [0:15]; // pp + pn
    logic signed [16:0] add_sub_step12_im [0:15]; // np + nn <16bit> -> <17bit> signed extension

    logic signed [8:0] m1_twf_r [0:15];
    logic signed [8:0] m1_twf_i [0:15];

    logic signed [14:0] bfly12_re_n_16_reg [0:15];
    logic signed [14:0] bfly12_im_n_16_reg [0:15];

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
            end
            step2_add_en <= 0;
            step2_sub_en <= 0;
            step2_mul_en <= 0;  
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
