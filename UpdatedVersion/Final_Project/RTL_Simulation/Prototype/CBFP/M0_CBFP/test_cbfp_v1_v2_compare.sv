`timescale 1ns/1ps

module test_cbfp #(
    parameter cnt_size = 5,
    parameter array_size = 16,
    parameter array_num = 4,
    parameter din_size  = 23,
    parameter dout_size = 11,
    parameter buffer_depth  = 64

) (
    input logic clk,
    input logic rstn,
    input logic valid_in,

    input logic signed [din_size-1:0] din_re_p [0:array_size-1],
    input logic signed [din_size-1:0] din_re_n [0:array_size-1],
    input logic signed [din_size-1:0] din_im_p [0:array_size-1],
    input logic signed [din_size-1:0] din_im_n [0:array_size-1],


    output logic signed[dout_size-1:0] dout_re [0:array_size-1],
    output logic signed[dout_size-1:0] dout_im [0:array_size-1],
    output logic signed[dout_size-1:0] dout_mux_re [0:array_size-1],
    output logic signed[dout_size-1:0] dout_mux_im [0:array_size-1],
    output logic valid_out

     
);  

    logic valid_shift0, valid_shift;
    always_ff @( posedge clk or negedge rstn) begin 
        if (!rstn) begin
            valid_shift <= '0;
            valid_shift0 <= '0;

        end else begin
            valid_shift0 <= valid_in;
            valid_shift <= valid_shift0;

        end
        
    end


    logic signal, ready,start;
    logic [5:0] cnt;

    always_ff @( posedge clk or negedge rstn) begin 
        if (!rstn) begin
            ready <= 1;
            signal <= 1;
            start <=0;
            cnt <=0;
            valid_out <= 0;
        end else if (!valid_in && ready)begin
            valid_out <= 0;
        end else if (valid_in && signal)begin
            if (cnt == 3) begin
                ready <= 0;
                valid_out <= 0;
                signal <= 0;
                cnt <= 0;
            end else begin
                ready <= 0;
                valid_out <= 0;
                cnt <= cnt +1;
            end
        end else if(!signal) begin 
            if (cnt == 32) begin
                valid_out <= 0;
                start <= 0;
            end else if (start) begin
                valid_out <= 1;
                cnt <= cnt +1;
            end else begin
                valid_out <= 0;
                start <= 1;
            end 
        end
    end


    logic signed  [din_size-1:0] d_semi_re_p [0:array_size-1];
    logic signed  [din_size-1:0] d_semi_re_n [0:array_size-1];
    logic signed[dout_size-1:0] dout_semi_re_n [0:array_size-1];

    logic signed[dout_size-1:0] dout_re_p [0:array_size-1];
    logic signed[dout_size-1:0] dout_re_n [0:array_size-1];

    logic [cnt_size-1:0] zero_cnt_p_re [0:array_num-1];      
    logic [cnt_size-1:0] zero_cnt_n_re [0:array_num-1];

    logic valid_out_p_re, valid_out_n_re, valid_out_trash_re;

    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            dout_re[i] =  dout_re_p[i] + dout_re_n[i];
        end
    end

    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            dout_mux_re[i] =  (!valid_shift ) ? dout_re_p[i] :dout_re_n[i];
        end
    end

    logic signed  [din_size-1:0] d_semi_im_p [0:array_size-1];
    logic signed  [din_size-1:0] d_semi_im_n [0:array_size-1];
    logic signed[dout_size-1:0] dout_semi_im_n [0:array_size-1];

    logic signed[dout_size-1:0] dout_im_p [0:array_size-1];
    logic signed[dout_size-1:0] dout_im_n [0:array_size-1];

    logic [cnt_size-1:0] zero_cnt_p_im [0:array_num-1];      
    logic [cnt_size-1:0] zero_cnt_n_im [0:array_num-1];

    logic valid_out_p_im, valid_out_n_im, valid_out_trash_im;

    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            dout_im[i] =  dout_im_p[i] + dout_im_n[i];
        end
    end

    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            dout_mux_im[i] =  (!valid_shift ) ? dout_im_p[i] :dout_im_n[i];
        end
    end


//first 4clk shift register

cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) re_sr_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din(din_re_p),
    .dout(d_semi_re_p),
    .valid_out(valid_out_p_re)
);

cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) re_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din(din_re_n),
    .dout(d_semi_re_n),
    .valid_out(valid_out_n_re)
);


cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) im_sr_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din(din_im_p),
    .dout(d_semi_im_p),
    .valid_out(valid_out_p_im)
);

cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) im_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din(din_im_n),
    .dout(d_semi_im_n),
    .valid_out(valid_out_n_im)
);

//first 4clk cal zero

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) re_cal_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re_p(din_re_p),    
    .cal_cnt (zero_cnt_p_re)
);

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) re_cal_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re_p(din_re_n),    
    .cal_cnt (zero_cnt_n_re)
);

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) im_cal_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re_p(din_im_p),    
    .cal_cnt (zero_cnt_p_im)
);

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) im_cal_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re_p(din_im_n),    
    .cal_cnt (zero_cnt_n_im)
);



//next 4clk output


fft_output_shift #(
    .cnt_size (5),
    .din_size (23),
    .dout_size (11),
    .array_num (4),
    .array_size (16)
) re_output_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_p_re),

    .cal_cnt(zero_cnt_p_re),
    .din(d_semi_re_p),

    .dout(dout_re_p)
);


fft_output_shift #(
    .cnt_size (5),
    .din_size (23),
    .dout_size (11),
    .array_num (4),
    .array_size (16)
) re_output_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_n_re),

    .cal_cnt(zero_cnt_n_re),
    .din(d_semi_re_n),

    .dout(dout_semi_re_n)
);

cbfp_sr_output #(
    .array_size(16),
    .din_size(11),
    .buffer_depth(64)
) re_output_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_n_re),

    .din(dout_semi_re_n),
    .dout(dout_re_n)
);



fft_output_shift #(
    .cnt_size (5),
    .din_size (23),
    .dout_size (11),
    .array_num (4),
    .array_size (16)
) im_output_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_p_im),

    .cal_cnt(zero_cnt_p_im),
    .din(d_semi_im_p),

    .dout(dout_im_p)
);


fft_output_shift #(
    .cnt_size (5),
    .din_size (23),
    .dout_size (11),
    .array_num (4),
    .array_size (16)
) im_output_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_n_im),

    .cal_cnt(zero_cnt_n_im),
    .din(d_semi_im_n),

    .dout(dout_semi_im_n)
);

cbfp_sr_output #(
    .array_size(16),
    .din_size(11),
    .buffer_depth(64)
) im_output_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_n_im),

    .din(dout_semi_im_n),
    .dout(dout_im_n)
);


endmodule


