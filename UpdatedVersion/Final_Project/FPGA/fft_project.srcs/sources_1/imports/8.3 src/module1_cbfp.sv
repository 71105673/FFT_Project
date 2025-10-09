`timescale 1ns/1ps

module module1_cbfp #(
    parameter cnt_size = 5,
    parameter array_size = 16,
    parameter array_num = 4,
    parameter din_size  = 25,
    parameter dout_size = 12,
    parameter buffer_depth  = 64

) (
    input logic clk,
    input logic rstn,
    input logic valid_in,

    input logic signed [din_size-1:0] din_re [0:array_size-1],    //real {pp, pn} -> {np, nn}
    input logic signed [din_size-1:0] din_im [0:array_size-1],    //img  {pp, pn} -> {np, nn}

    output logic signed[dout_size-1:0] dout_re [0:array_size-1],  //real {pp, pn} -> {np, nn}
    output logic signed[dout_size-1:0] dout_im [0:array_size-1],  //img  {pp, pn} -> {np, nn}

    output logic valid_out,
    output logic [4:0] min_val1 [0:1]
);  

    
    logic valid;

    logic signed [din_size-1:0] din_re_shift [0:array_size-1];    //real {pp, pn} -> {np, nn}
    logic signed [din_size-1:0] din_im_shift [0:array_size-1];    //img  {pp, pn} -> {np, nn}


    logic signed [dout_size-1:0] dout_p_re [0:7];   //real {pp, pn} -> {np, nn}
    logic signed [dout_size-1:0] dout_p_im [0:7];   //real {pp, pn} -> {np, nn}
    logic signed [dout_size-1:0] dout_n_re [0:7];   //img  {pp, pn} -> {np, nn}
    logic signed [dout_size-1:0] dout_n_im [0:7];   //img  {pp, pn} -> {np, nn}


    integer i, k; 

 
    logic signal, ready,start;
    logic [5:0] cnt;


    logic unsigned [cnt_size-1:0] zero_cnt_p;      
    logic unsigned [cnt_size-1:0] zero_cnt_n;

    always_ff @( posedge clk or negedge rstn ) begin 
	    if (!rstn) begin
		    for(k=0;k<2;k++) begin
                min_val1[k] <= 0;
            end
            valid_out <= 0;
	    end else begin
		    valid_out <= valid;
        	min_val1[0] <= zero_cnt_p;
        	min_val1[1] <= zero_cnt_n;

	    end
    end


    always_ff @( posedge clk or negedge rstn) begin 
        if (!rstn) begin
            ready <= 0;
            cnt <= 0;
            valid <= 0;
        end else if (valid_in && !ready )begin
            ready <= 1;
            valid <= 1;
            cnt <= 0;
        end else if(ready) begin 
            if (cnt > 30) begin
                valid <= 0;
                ready <= 0;
                cnt <= 0;
            end else begin
                valid <= 1;
                cnt <= cnt +1;
            end 
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i <array_size; i = i+1 ) begin
                din_re_shift[i] <= 0;
                din_im_shift[i] <= 0;
            end
        end else begin
            for (i = 0; i <array_size; i = i+1 ) begin
                din_re_shift[i] <= din_re[i];
                din_im_shift[i] <= din_im[i];
            end
        end
    end




//////////////////////cal zero  x 4

//dout_p [0:15]
fft_cbfp_cal_zero_m1 #(
    .cnt_size (5),
    .array_size (8),
    .din_size  (25)
) cal_p (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re(din_re[0:7]),
    .din_im(din_im[0:7]),
    .cal_cnt(zero_cnt_p) 
);



//dout_n [0:15]

fft_cbfp_cal_zero_m1 #(
    .cnt_size (5),
    .array_size (8),
    .din_size  (25)
) cal_n (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_in),

    .din_re(din_re[8:15]),
    .din_im(din_im[8:15]),
    .cal_cnt(zero_cnt_n) 
);


///////////////// next 1clk output

fft_output_shift_m1 #(
    .cnt_size    (5),
    .din_size    (25),
    .dout_size   (12),
    .array_size  (8)
) output_pp (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid),
    
    .min_val(zero_cnt_p),
    .din_re(din_re_shift[0:7]),
    .din_im(din_im_shift[0:7]),

    .dout_re(dout_p_re),  
    .dout_im(dout_p_im)
);


fft_output_shift_m1 #(
    .cnt_size    (5),
    .din_size    (25),
    .dout_size   (12),
    .array_size  (8)
) output_np (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid),
    
    .min_val(zero_cnt_n),
    .din_re(din_re_shift[8:15]),
    .din_im(din_im_shift[8:15]),

    .dout_re(dout_n_re),  
    .dout_im(dout_n_im)
);


genvar j;
generate
    for (j = 0; j < array_size; j = j+1)
        if (j < 8 ) begin
            assign dout_re[j] = dout_p_re [j];
            assign dout_im[j] = dout_p_im [j];
        end else begin
            assign dout_re[j] = dout_n_re [j - 8];
            assign dout_im[j] = dout_n_im [j - 8];
        end
endgenerate

endmodule

