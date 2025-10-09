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
    
    input logic signed [cnt_size-1:0] cal_cnt [0:array_num-1],
    input logic signed[din_size-1:0] din [0:array_size-1],

    output logic signed [dout_size-1:0] dout [0:array_size-1]

);

    logic signed [cnt_size-1:0] min_val;

    always_comb begin
        logic signed [cnt_size-1:0] min01, min23;

        min01 = (cal_cnt[0] < cal_cnt[1]) ? cal_cnt[0] : cal_cnt[1];
        min23 = (cal_cnt[2] < cal_cnt[3]) ? cal_cnt[2] : cal_cnt[3];
        min_val = (min01 < min23) ? min01 : min23;
    end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (int i = 0; i < array_size; i++) begin
            dout[i] <= '0;
        end
    end else if (valid_in) begin
        for (int i = 0; i < array_size; i++) begin
            if (min_val > 12) begin
                dout[i] <=( (din[i] <<< min_val) >>> 12 );  // 반올림 추가
            end else begin
                dout[i] <= ( (din[i] ) >>> (12 - min_val) );  // 반올림 추가
            end
        end
    end else begin
        for (int i = 0; i < array_size; i++) begin
            dout[i] <= '0;
        end
    end
end
    
endmodule