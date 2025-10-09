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
    

function automatic logic [4:0] count_min_lzc_23bit(input logic signed [22:0] din [0:15]);
    logic [4:0] lzc [0:15];
    logic [4:0] min_val = 24;
    
    integer i;
    
    for (i = 0; i < 16; i++) begin
        lzc[i] =(din[i][21:0]  == 22'd0 && din[i][22] == 1'b0) ? 22 :
                (din[i][21:1]  == 21'd0 && din[i][22] == 1'b0) ? 21 :
                (din[i][21:2]  == 20'd0 && din[i][22] == 1'b0) ? 20 :
                (din[i][21:3]  == 19'd0 && din[i][22] == 1'b0) ? 19 :
                (din[i][21:4]  == 18'd0 && din[i][22] == 1'b0) ? 18 :
                (din[i][21:5]  == 17'd0 && din[i][22] == 1'b0) ? 17 :
                (din[i][21:6]  == 16'd0 && din[i][22] == 1'b0) ? 16 :
                (din[i][21:7]  == 15'd0 && din[i][22] == 1'b0) ? 15 :
                (din[i][21:8]  == 14'd0 && din[i][22] == 1'b0) ? 14 :
                (din[i][21:9]  == 13'd0 && din[i][22] == 1'b0) ? 13 :
                (din[i][21:10] == 12'd0 && din[i][22] == 1'b0) ? 12 :
                (din[i][21:11] == 11'd0 && din[i][22] == 1'b0) ? 11 :
                (din[i][21:12] == 10'd0 && din[i][22] == 1'b0) ? 10 :
                (din[i][21:13] == 9'd0  && din[i][22] == 1'b0) ? 9  :
                (din[i][21:14] == 8'd0  && din[i][22] == 1'b0) ? 8  :
                (din[i][21:15] == 7'd0  && din[i][22] == 1'b0) ? 7  :
                (din[i][21:16] == 6'd0  && din[i][22] == 1'b0) ? 6  :
                (din[i][21:17] == 5'd0  && din[i][22] == 1'b0) ? 5  :
                (din[i][21:18] == 4'd0  && din[i][22] == 1'b0) ? 4  :
                (din[i][21:19] == 3'd0  && din[i][22] == 1'b0) ? 3  :
                (din[i][21:20] == 2'd0  && din[i][22] == 1'b0) ? 2  :
                (din[i][21]    == 1'b0  && din[i][22] == 1'b0) ? 1  : 
                (din[i][21:0]  == 22'h3FFFFF && din[i][22] ) ? 22 :
                (din[i][21:1]  == 21'h1FFFFF && din[i][22]) ? 21 :
                (din[i][21:2]  == 20'hFFFFF  && din[i][22] ) ? 20 :
                (din[i][21:3]  == 19'h7FFFF  && din[i][22] ) ? 19 :
                (din[i][21:4]  == 18'h3FFFF  && din[i][22]) ? 18 :
                (din[i][21:5]  == 17'h1FFFF  && din[i][22] ) ? 17 :
                (din[i][21:6]  == 16'hFFFF   && din[i][22] ) ? 16 :
                (din[i][21:7]  == 15'h7FFF   && din[i][22] ) ? 15 :
                (din[i][21:8]  == 14'h3FFF   && din[i][22] ) ? 14 :
                (din[i][21:9]  == 13'h1FFF   && din[i][22] ) ? 13 :
                (din[i][21:10] == 12'hFFF    && din[i][22] ) ? 12 :
                (din[i][21:11] == 11'h7FF    && din[i][22] ) ? 11 :
                (din[i][21:12] == 10'h3FF    && din[i][22]) ? 10 :
                (din[i][21:13] ==  9'h1FF    && din[i][22] ) ? 9  :
                (din[i][21:14] ==  8'hFF     && din[i][22] ) ? 8  :
                (din[i][21:15] ==  7'h7F     && din[i][22] ) ? 7  :
                (din[i][21:16] ==  6'h3F     && din[i][22] ) ? 6  :
                (din[i][21:17] ==  5'h1F     && din[i][22] ) ? 5  :
                (din[i][21:18] ==  4'hF      && din[i][22] ) ? 4  :
                (din[i][21:19] ==  3'h7      && din[i][22] ) ? 3  :
                (din[i][21:20] ==  2'h3      && din[i][22] ) ? 2  :
                (din[i][21]    ==  1'b1      && din[i][22] ) ? 1  : 0;

        if (lzc[i] < min_val)
            min_val = lzc[i];
    end

    return min_val;
endfunction
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

    logic signed [24:0] function_input [0:15];

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            function_input[i]     = din_re[i];
            function_input[i+8]   = din_im[i];
        end
    end 

    function automatic logic [4:0] count_min_lzc_26bit(input logic signed [24:0] din [0:15]);
    logic  [4:0] lzc [0:15];
    logic  [4:0] min_val = 25;

    integer i;

    for (i = 0; i < 16; i++) begin
        lzc[i] =(din[i][23:0]  == 24'd0 && din[i][24] == 1'b0) ? 24 :
                (din[i][23:1]  == 23'd0 && din[i][24] == 1'b0) ? 23 :
                (din[i][23:2]  == 22'd0 && din[i][24] == 1'b0) ? 22 :
                (din[i][23:3]  == 21'd0 && din[i][24] == 1'b0) ? 21 :
                (din[i][23:4]  == 20'd0 && din[i][24] == 1'b0) ? 20 :
                (din[i][23:5]  == 19'd0 && din[i][24] == 1'b0) ? 19 :
                (din[i][23:6]  == 18'd0 && din[i][24] == 1'b0) ? 18 :
                (din[i][23:7]  == 17'd0 && din[i][24] == 1'b0) ? 17 :
                (din[i][23:8]  == 16'd0 && din[i][24] == 1'b0) ? 16 :
                (din[i][23:9]  == 15'd0 && din[i][24] == 1'b0) ? 15 :
                (din[i][23:10] == 14'd0 && din[i][24] == 1'b0) ? 14 :
                (din[i][23:11] == 13'd0 && din[i][24] == 1'b0) ? 13 :
                (din[i][23:12] == 12'd0 && din[i][24] == 1'b0) ? 12 :
                (din[i][23:13] == 11'd0  && din[i][24] == 1'b0) ? 11  :
                (din[i][23:14] == 10'd0  && din[i][24] == 1'b0) ? 10  :
                (din[i][23:15] == 9'd0  && din[i][24] == 1'b0) ? 9  :
                (din[i][23:16] == 8'd0  && din[i][24] == 1'b0) ? 8  :
                (din[i][23:17] == 7'd0  && din[i][24] == 1'b0) ? 7  :
                (din[i][23:18] == 6'd0  && din[i][24] == 1'b0) ? 6  :
                (din[i][23:19] == 5'd0  && din[i][24] == 1'b0) ? 5  :
                (din[i][23:20] == 4'd0  && din[i][24] == 1'b0) ? 4  :
                (din[i][23:21] == 3'd0  && din[i][24] == 1'b0) ? 3  :
                (din[i][23:22] == 2'd0  && din[i][24] == 1'b0) ? 2  :
                (din[i][23:23] == 1'b0  && din[i][24] == 1'b0) ? 1  :
                (din[i][23:0]  == 24'hFFFFFF && din[i][24] ) ? 24 :
                (din[i][23:1]  == 23'h7FFFFF  && din[i][24] ) ? 23 :
                (din[i][23:2]  == 22'h3FFFFF  && din[i][24] ) ? 22 :
                (din[i][23:3]  == 21'h1FFFFF  && din[i][24] ) ? 21 :
                (din[i][23:4]  == 20'hFFFFF  && din[i][24] ) ? 20 :
                (din[i][23:5]  == 19'h7FFFF   && din[i][24] ) ? 19 :
                (din[i][23:6]  == 18'h3FFFF   && din[i][24] ) ? 18 :
                (din[i][23:7]  == 17'h1FFFF   && din[i][24] ) ? 17 :
                (din[i][23:8]  == 16'hFFFF   && din[i][24] ) ? 16 :
                (din[i][23:9]  == 15'h7FFF    && din[i][24] ) ? 15 :
                (din[i][23:10] == 14'h3FFF    && din[i][24] ) ? 14 :
                (din[i][23:11] == 13'h1FFF    && din[i][24] ) ? 13 :
                (din[i][23:12] == 12'hFFF    && din[i][24] ) ? 12 :
                (din[i][23:13] == 11'h7FF     && din[i][24] ) ? 11 :
                (din[i][23:14] == 10'h3FF     && din[i][24] ) ? 10 :
                (din[i][23:15] == 9'h1FF     && din[i][24] ) ? 9 :
                (din[i][23:16] == 8'hFF      && din[i][24] ) ? 8  :
                (din[i][23:17] == 7'h7F       && din[i][24] ) ? 7  :
                (din[i][23:18] == 6'h3F       && din[i][24] ) ? 6  :
                (din[i][23:19] == 5'h1F       && din[i][24] ) ? 5  :
                (din[i][23:20] == 4'hF       && din[i][24] ) ? 4 :
                (din[i][23:21] == 3'h7        && din[i][24] ) ? 3 :
                (din[i][23:22] == 2'h3        && din[i][24] ) ? 2 :
                (din[i][23] == 1'b1        && din[i][24] ) ? 1 : 0;

                if (lzc[i] < min_val)
                    min_val = lzc[i];
            end

            return min_val;
    endfunction
    
    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            cal_cnt <= '0;

        end else if (valid_in) begin 
            cal_cnt <= count_min_lzc_26bit(function_input);
          
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




