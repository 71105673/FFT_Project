`timescale 1ns / 1ps

module butterfly_16bit (
    input logic clk,
    input logic rstn,

    input  logic signed [14:0] bf3_in_re [0:15],
    input  logic signed [14:0] bf3_in_im [0:15],

    output logic signed [15:0] bf3_out_re [0:15],
    output logic signed [15:0] bf3_out_im [0:15]
);

    // 내부 결과 저장용
    logic signed [15:0] add_re [0:7];
    logic signed [15:0] sub_re [0:7];
    logic signed [15:0] add_im [0:7];
    logic signed [15:0] sub_im [0:7];

    // 버터플라이 연산 (clk 동기화)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 8; i++) begin
                add_re[i] <= 16'sd0;
                sub_re[i] <= 16'sd0;
                add_im[i] <= 16'sd0;
                sub_im[i] <= 16'sd0;
            end
        end else begin
            for (int i = 0; i < 8; i++) begin
                add_re[i] <= bf3_in_re[i] + bf3_in_re[i+8];
                sub_re[i] <= bf3_in_re[i] - bf3_in_re[i+8];
                add_im[i] <= bf3_in_im[i] + bf3_in_im[i+8];
                sub_im[i] <= bf3_in_im[i] - bf3_in_im[i+8];
            end
        end
    end

    // 출력 연결
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 8; i++) begin
                bf3_out_re[i]   <= 16'sd0;
                bf3_out_re[i+8] <= 16'sd0;
                bf3_out_im[i]   <= 16'sd0;
                bf3_out_im[i+8] <= 16'sd0;
            end
        end else begin
            for (int i = 0; i < 8; i++) begin
                bf3_out_re[i]   <= add_re[i];
                bf3_out_re[i+8] <= sub_re[i];
                bf3_out_im[i]   <= add_im[i];
                bf3_out_im[i+8] <= sub_im[i];
            end
        end
    end

endmodule
