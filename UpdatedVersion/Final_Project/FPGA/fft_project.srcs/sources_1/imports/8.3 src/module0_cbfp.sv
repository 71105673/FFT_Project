`timescale 1ns/1ps

module module0_cbfp #(
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
    
    output logic signed[dout_size-1:0] dout_mux_re [0:array_size-1],
    output logic signed[dout_size-1:0] dout_mux_im [0:array_size-1],
    output logic valid_out,
    output logic [4:0] min_val0 [0:7], 
    output logic f_out

);  

    logic unsigned [cnt_size-1:0] min_val_p_re, min_val_p_im,min_val_n_re, min_val_n_im ;

    logic valid_new_im;
    logic valid_new_re;
    logic valid_out_shift;

    logic signal, ready,start;
    logic [5:0] cnt;

    logic signed  [din_size-1:0] d_semi_re_p [0:array_size-1];
    logic signed  [din_size-1:0] d_semi_re_n [0:array_size-1];
    logic signed[dout_size-1:0] dout_semi_re_n [0:array_size-1];

    logic signed[dout_size-1:0] dout_re_p [0:array_size-1];
    logic signed[dout_size-1:0] dout_re_n [0:array_size-1];

    logic [cnt_size-1:0] zero_cnt_p [0:array_num-1];      
    logic [cnt_size-1:0] zero_cnt_n [0:array_num-1];

    logic signed  [din_size-1:0] d_semi_im_p [0:array_size-1];
    logic signed  [din_size-1:0] d_semi_im_n [0:array_size-1];
    logic signed[dout_size-1:0] dout_semi_im_n [0:array_size-1];

    logic signed[dout_size-1:0] dout_im_p [0:array_size-1];
    logic signed[dout_size-1:0] dout_im_n [0:array_size-1];

    logic one, two, three, four, five, six;


    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            one <= '0;
            two <= '0;
            three <= '0;
            four <= '0;
            five <= '0;
            six <= '0;
        end else begin
            one <= valid_in;
            two <= one;
            three <= two;
            four <= three;
            five <= four;
            six <= five;    
        end
        
    end

        always_ff @( posedge clk or negedge rstn) begin 
        if (!rstn) begin
            ready <= 1;
            cnt <=0;
            valid_out <= 0;
            start <= 0;
        end else if (valid_in && ready )begin
            ready <= 0;
            valid_out <= 0;
            start <=0;
        end else if(!(valid_in || ready||start)) begin 
            valid_out <= 1;
            start <= 1;
        end else if(start) begin 
            if (cnt > 30) begin
                valid_out <= 0;
		cnt <= 0;
		ready <=1;
		start <=0;
            end else begin
                valid_out <= 1;
                cnt <= cnt +1;
            end 
        end
    end



    always_ff @( posedge clk or negedge rstn ) begin 
        if (!rstn) begin
            valid_new_im <= 0;
            valid_new_re <= 0;
        end else begin 
            valid_new_im <= valid_out_shift;
            valid_new_re <= valid_out_shift;
        end
    end

    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            if (five)begin
                dout_mux_re[i] = dout_re_p[i] ;
            end else begin
                dout_mux_re[i] = dout_re_n[i];
            end
           
        end
    end


    always_comb begin
        for (int i = 0; i < array_size; i = i+1) begin
            if (five)begin
                dout_mux_im[i] = dout_im_p[i] ;
            end else begin
                dout_mux_im[i] = dout_im_n[i];
            end
           
        end
    end

//first 4clk shift register


    logic test;
    always_ff @( posedge clk or negedge rstn ) begin
    
        if (!rstn) begin
            valid_out_shift <= 0;
            test <= 1;
        end else begin
            if (valid_in && test)begin
                valid_out_shift <= ~valid_in;
                test <= 0;
            end else if (!test) begin
                valid_out_shift <= ~valid_in;
            end
        
        end
    end


cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) re_sr_p (
    .clk(clk),
    .rstn(rstn),
   // .valid_in(three),

    .din(din_re_p),
    .dout(d_semi_re_p)
);

cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) re_sr_n (
    .clk(clk),
    .rstn(rstn),
    //.valid_in(three),

    .din(din_re_n),
    .dout(d_semi_re_n)
);


cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) im_sr_p (
    .clk(clk),
    .rstn(rstn),
  //  .valid_in(three),

    .din(din_im_p),
    .dout(d_semi_im_p)
);

cbfp_sr #(
    .array_size(16),
    .din_size(23),
    .buffer_depth(64), 
    .clk_cnt(3) 
) im_sr_n (
    .clk(clk),
    .rstn(rstn),
  //  .valid_in(three),

    .din(din_im_n),
    .dout(d_semi_im_n)
);

//first 4clk cal zero

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) cal_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re(din_re_p),  
    .din_im(din_im_p),      
    .cal_cnt (zero_cnt_p)
);

fft_cbfp_cal_zero #(
    .cnt_size (5),
    .array_size (16),
    .array_num (4),
    .din_size (23),
    .buffer_depth (64)

) cal_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re(din_re_n),
    .din_im(din_im_n),    
    
    .cal_cnt (zero_cnt_n)
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
    .valid_in(four),

    .cal_cnt(zero_cnt_p),
    .din(d_semi_re_p),

    .dout(dout_re_p),
    .min_val(min_val_p_re)
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
    .valid_in(four),

    .cal_cnt(zero_cnt_n),
    .din(d_semi_re_n),

    .dout(dout_semi_re_n),
    .min_val(min_val_n_re)
);

cbfp_sr_output #(
    .array_size(16),
    .din_size(11),
    .buffer_depth(64)
) re_output_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(six),

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
    .valid_in(four),

    .cal_cnt(zero_cnt_p),
    .din(d_semi_im_p),

    .dout(dout_im_p),
    .min_val(min_val_p_im)
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
    .valid_in(four),

    .cal_cnt(zero_cnt_n),
    .din(d_semi_im_n),

    .dout(dout_semi_im_n),
    .min_val(min_val_n_im)

);

cbfp_sr_output #(
    .array_size(16),
    .din_size(11),
    .buffer_depth(64)
) im_output_sr_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(six),

    .din(dout_semi_im_n),
    .dout(dout_im_n)
);


///////////////////////min_val0 추가

 min_val min_out(
    .clk(clk),
    .rstn(rstn),
    .valid(valid_out_shift),
    .min_p(min_val_p_re),
    .min_n(min_val_n_re),

    .min_val0(min_val0),
    .f_out(f_out)
);

///////////////////////min_val 추가 


endmodule





module min_val (
    input logic clk,
    input logic rstn,
    input logic valid,
    input logic [4:0] min_p,
    input logic [4:0] min_n,

    output logic [4:0] min_val0 [0:7],
    output logic f_out
);
    logic flag;
    logic [1:0] cnt;
    integer i;

    always_ff @( posedge clk or negedge rstn ) begin 
        if (!rstn) begin
            for (i = 0; i < 8; i = i+1)begin
                min_val0[i] <='0;
            end
            flag <= 1;
            f_out <= 0;
            cnt <= 0;
        end else begin
            if (valid && flag) begin
                min_val0[2*cnt] <= min_p;
                min_val0[2*cnt+1] <= min_n;
                flag <= 0;
                if (cnt == 3)begin
                    f_out <= 1;
                end
                cnt <= cnt + 1;
            end else if (!valid) begin
                flag <= 1;
            end
            
        end
    end
    
endmodule
