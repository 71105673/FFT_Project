`timescale 1ns/1ps

module step0_shift_reg #(
    parameter int N   = 256,  // 총 입력 수 (16의 배수)
    parameter int FIX = 10    // 고정소수점 비트 수
) (
    input clk,
    input rst,
    input valid,
    input  logic signed [FIX-1:0] bfly_re [0:15],     // FIX비트 × 16개 입력
    output logic signed [FIX-1:0] sr_out  [0:15]      // FIX비트 × 16개 출력
);

    localparam int DEPTH = N / 16;

    logic signed [FIX-1:0] shift_din [0:DEPTH-1][0:15];

    integer i, j;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < DEPTH; i++) begin
                for (j = 0; j < 16; j++) begin
                    shift_din[i][j] <= '0;
                end
            end
        end else begin
            for (i = DEPTH-1; i > 0; i--) begin
                shift_din[i] <= shift_din[i - 1];
            end
            if (valid) begin
                shift_din[0] <= bfly_re;
            end
        end
    end

    assign sr_out = shift_din[DEPTH-1];

endmodule


module shift_reg #(
    parameter int N   = 256,  // 총 입력 수 (16의 배수)
    parameter int FIX = 10    // 고정소수점 비트 수
) (
    input  logic clk,
    input  logic rst,
    input  logic signed [FIX-1:0] bfly_re [0:15],     // FIX비트 × 16개 입력
    output logic signed [FIX-1:0] sr_out  [0:15]      // FIX비트 × 16개 출력
);

    localparam int DEPTH = N / 16;

    logic signed [FIX-1:0] shift_din [0:DEPTH-1][0:15];

    integer i, j;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < DEPTH; i++) begin
                for (j = 0; j < 16; j++) begin
                    shift_din[i][j] <= '0;
                end
            end
        end else begin
            for (i = DEPTH-1; i > 0; i--) begin
                shift_din[i] <= shift_din[i - 1];
                shift_din[0] <= bfly_re;
            end
            
        end
    end

    assign sr_out = shift_din[DEPTH-1];

endmodule

module cbfp_sr #(
    parameter array_size    = 16,
    parameter din_size      = 23,
    parameter buffer_depth  = 64, 
    parameter clk_cnt = 3 // buffer_depth/array_size - 1
) (
    input  logic clk,
    input  logic rstn,
    //input  logic valid_in,
    input logic signed[din_size-1:0] din  [0:array_size-1],

    output logic signed[din_size-1:0] dout [0:array_size-1]
);


    reg signed [din_size-1:0] buffer_din [0:buffer_depth-1];

    logic [1:0] cnt;     // 0~3
    logic flag;
    logic [4:0] flag_count;
    integer i;

    // 입력 단계: buffer에 16개씩 저장
    always_ff @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                for (i = 0; i < buffer_depth; i++) begin
                    buffer_din[i] <= '0;
                end
                for (i = 0; i < array_size; i++) begin
                    dout[i] <= '0; // 이 부분 중요
                end
            end else begin
           /* for (i = 3; i >= 0; i = i - 1) begin
                buffer_din[i*16+:16] <= buffer_din[(i-1)*16+:16];
            end */
                buffer_din[48:63] <= buffer_din[32:47];
                buffer_din[32:47] <= buffer_din[16:31];
                buffer_din[16:31] <= buffer_din[0:15];
                buffer_din[0:15] <= din;

            // latch 방지: dout이 항상 명확하게 정의되도록
            for (i = 0; i < array_size; i++) begin
                //dout[i] <= valid_in ? buffer_din[buffer_depth - 2*array_size + i] : dout[i];
                dout[i] <= buffer_din[buffer_depth - 2*array_size + i] ;
            end
        end
    end

endmodule

module cbfp_sr_output #(
    parameter array_size    = 16,
    parameter din_size      = 11,
    parameter buffer_depth  = 64
) (
    input  logic clk,
    input  logic rstn,
    input  logic valid_in,

    input logic signed[din_size-1:0] din  [0:array_size-1],
    output logic signed[din_size-1:0] dout [0:array_size-1]
);

    logic signed [din_size-1:0] buffer_din [0:buffer_depth-1];
    integer i, j;
    logic start ;

    logic signed [din_size-1:0] buffer_din_next [0:buffer_depth-1];

    logic start_next;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            start <= 1;
        end else begin
            start <= start_next;
        end
    end

    always_comb begin
        if (!valid_in && start)
            start_next = 0;
        else begin 
            start_next = start;
        end
    end

    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            for (i = 0; i < buffer_depth; i = i+1)
                buffer_din[i] <= '0;
        end else begin
            for (i = buffer_depth -1; i > array_size -1; i = i -1)
                buffer_din[i] <= buffer_din[i - array_size];

            for (i = 0; i < array_size; i = i+1)
                buffer_din[i] <= din[i];
        end
    end

    always_comb begin 
        for (j= 0; j < array_size; j = j +1) begin
            dout [j] = buffer_din [j+48];
        end
    end
endmodule


module shift11_reg #(
    parameter int FIX = 10    // 고정소수점 비트 수
) (
    input  logic clk,
    input  logic rst,
    input  logic signed [FIX-1:0] bfly_re [0:15],     // FIX비트 × 16개 입력
    output logic signed [FIX-1:0] sr_out  [0:15]      // FIX비트 × 16개 출력
);

    logic signed [FIX-1:0] shift_din [0:15];

    integer j;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (j = 0; j < 16; j++) begin
                
                shift_din[j] <= '0;
              
            end
        end else begin
            for (j = 0; j < 16; j++) begin
		    //sr_out[j] <= shift_din[j];
                    shift_din[j] <= bfly_re[j];
            end
        end
    end
    assign sr_out = shift_din;


endmodule
