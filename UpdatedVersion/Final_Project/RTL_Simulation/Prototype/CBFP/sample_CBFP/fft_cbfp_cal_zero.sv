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

    input logic signed [din_size-1:0] din_re_p [0:array_size-1],
    
    output logic signed [cnt_size-1:0] cal_cnt [0:array_num-1]
);

    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            for (int i = 0; i < array_num; i=i+1) begin
                cal_cnt[i] <= '0;
            end
        end else if (valid_in) begin
            for (int i = array_num; i > 0; i=i-1) begin
                cal_cnt[i] <= cal_cnt[i-1];
            end 
            cal_cnt[0] <= count_min_lzc_23bit(din_re_p);

        end else begin
            for (int i = 0; i < array_num; i=i+1) begin
                cal_cnt[i] <= cal_cnt[i];
            end
        end
    end
    
endmodule


