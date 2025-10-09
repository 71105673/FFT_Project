`timescale 1ns/1ps

module fft_cbfp_cal_zero #(
    parameter cnt_size = 5,
    parameter array_size = 16,
    parameter array_num = 4,
    parameter din_size  = 23,
    parameter buffer_depth  = 64

) (
    input logic clk,
    input logic rstn,
    input logic valid_in,

    input logic signed [din_size-1:0] din_re [0:array_size-1],
    input logic signed [din_size-1:0] din_im [0:array_size-1],

    
    output logic unsigned [cnt_size-1:0] cal_cnt [0:array_num-1]
);

    // logic signed [22:0] function_input [0:31];
    logic [4:0] lzc_re, lzc_im;
    


    always_comb begin
        lzc_re = count_min_lzc_23bit(din_re);
        lzc_im = count_min_lzc_23bit(din_im);
    end
    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            for (int i = 0; i < array_num; i=i+1) begin
                cal_cnt[i] <= '0;
            end
        end else if (valid_in) begin
            for (int i = array_num - 1; i > 0; i=i-1) begin
                cal_cnt[i] <= cal_cnt[i-1];
            end 

            
            cal_cnt[0] <= (lzc_re > lzc_im) ? lzc_im : lzc_re;


        end else begin
            for (int i = 0; i < array_num; i=i+1) begin
                cal_cnt[i] <= cal_cnt[i];
            end
        end
    end
    
endmodule

module fft_output_shift #(
    parameter cnt_size      =  5,
    parameter din_size      = 23,
    parameter dout_size     = 11,
    parameter array_num     =  4,
    parameter array_size    = 16
) (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    
    input logic unsigned [cnt_size-1:0] cal_cnt [0:array_num-1],
    input logic signed[din_size-1:0] din [0:array_size-1],

    output logic signed [dout_size-1:0] dout [0:array_size-1],
    output logic unsigned [cnt_size-1:0] min_val

    
);

    integer i;
    
    always_comb begin
        logic unsigned [cnt_size-1:0] min01, min23;

        min01 = (cal_cnt[0] < cal_cnt[1]) ? cal_cnt[0] : cal_cnt[1];
        min23 = (cal_cnt[2] < cal_cnt[3]) ? cal_cnt[2] : cal_cnt[3];
        min_val = (min01 < min23) ? min01 : min23;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < array_size; i++) begin
                dout[i] <= '0;
            end
        end else begin
            if (valid_in) begin
                for (i = 0; i < array_size; i++) begin
                    if (min_val > 12) begin
                        //dout[i] <=( (din[i] <<< min_val) >>> 12 );  // 반올림 추가
                        dout[i] <= ( (din[i] ) <<< (min_val - 12) );  // 반올림 추가
                    end else begin
                        dout[i] <= ( (din[i] ) >>> (12 - min_val) );  // 반올림 추가
                    end
                end
            end else begin
                for (i = 0; i < array_size; i++) begin
                    dout[i] <= '0;
                end
            end
        end    
        
    end
    
endmodule

module fft_cbfp_cal_zero_m1 #(
    parameter cnt_size = 5,
    parameter array_size = 8,
    parameter din_size  = 25
) (
    input logic clk,
    input logic rstn,
    input logic valid_in,

    input logic signed [din_size-1:0] din_re [0:array_size-1],
    input logic signed [din_size-1:0] din_im [0:array_size-1],

    output logic unsigned [cnt_size-1:0] cal_cnt
);

    
    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            cal_cnt <= '0;

        end else if (valid_in) begin 
            cal_cnt <= count_min_lzc_26bit({din_re,din_im});
          
        end 
    end
endmodule

module fft_output_shift_m1 #(
    parameter cnt_size      =  5,
    parameter din_size      = 25,
    parameter dout_size     = 12,
    parameter array_size    = 8
) (
    input logic clk,
    input logic rstn,
    input logic valid_in,
    
    input logic unsigned [cnt_size-1:0] min_val ,
    input logic signed [din_size-1:0] din_re [0:array_size-1],
    input logic signed [din_size-1:0] din_im [0:array_size-1],

    output logic signed [dout_size-1:0] dout_re [0:array_size-1],
    output logic signed [dout_size-1:0] dout_im [0:array_size-1]
);

    integer i;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < array_size; i++) begin
                dout_re[i] <= '0;
                dout_im[i] <= '0;
            end
        end else begin
            if (valid_in) begin
                for (i = 0; i < array_size; i =i+1) begin
                    if (min_val > 13) begin
                        dout_re[i] <= ( (din_re[i] ) <<< (min_val - 13) );  
                        dout_im[i] <= ( (din_im[i] ) <<< (min_val - 13) );  
                    end else begin
                        dout_re[i] <= ( (din_re[i] ) >>> (13 - min_val) ); 
                        dout_im[i] <= ( (din_im[i] ) >>> (13 - min_val) ); 
                    end
                end
            end 
        end    
    end
    
endmodule




