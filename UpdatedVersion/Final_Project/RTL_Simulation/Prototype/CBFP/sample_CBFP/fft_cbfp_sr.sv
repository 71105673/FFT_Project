`timescale 1ns/1ps


module cbfp_sr #(
    parameter array_size    = 16,
    parameter din_size      = 23,
    parameter buffer_depth  = 64, 
    parameter clk_cnt = 3 // buffer_depth/array_size - 1
) (
    input  logic clk,
    input  logic rstn,
    input  logic valid_in,

    input logic signed[din_size-1:0] din  [0:array_size-1],
    output logic signed[din_size-1:0] dout [0:array_size-1],
    output logic valid_out
);

    logic signed [din_size-1:0] buffer_din [0:buffer_depth-1];

    logic [1:0] cnt;     // 0~3

    // 입력 단계: buffer에 16개씩 저장
    always_ff @(posedge clk or negedge rstn) begin
        integer i;

        if (~rstn) begin
            for(i=0; i<=buffer_depth; i=i+1)
                buffer_din[i] <= 0;
        end else if (valid_in) begin
            for (int i = buffer_depth - 1; i >= array_size; i = i-1) begin
                buffer_din[i] <= buffer_din[i - array_size];
            end
            for (int i = 0; i < array_size; i = i+1) begin
                    buffer_din[i] <= din[i];
            end
        end
    end

    // 출력 단계: 16개씩 순차 출력
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (int i = 0; i < array_size; i = i+1)
            dout[i] <= '0;
        cnt <= clk_cnt;
    end else if (!valid_in) begin  // 출력 phase라고 가정
        for (int i = 0; i < array_size; i = i+1) begin
            dout[i] <= buffer_din[cnt * array_size + i];
        end
        cnt <= cnt - 1;
        valid_out <= 1;
    end else begin
        for (int i = 0; i < array_size; i = i+1)
            dout[i] <= '0;
        cnt <= clk_cnt;
        valid_out <= 0;
    end
end

endmodule