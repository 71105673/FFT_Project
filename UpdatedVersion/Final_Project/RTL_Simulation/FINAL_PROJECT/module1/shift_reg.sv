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
    input  logic valid_in,

    input logic signed[din_size-1:0] din  [0:array_size-1],
    output logic signed[din_size-1:0] dout [0:array_size-1],
    output logic valid_out
);

    logic signed [din_size-1:0] buffer_din [0:buffer_depth-1];

    logic [1:0] cnt;     // 0~3
    logic flag;
    logic [4:0] flag_count;

    // 입력 단계: buffer에 16개씩 저장
    always_ff @(posedge clk or negedge rstn) begin
        integer i;

        if (~rstn) begin
            for(i=0; i<=buffer_depth; i=i+1) begin
                buffer_din[i] <= 0;
            end
                
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
            flag <= 0;
            flag_count <= 0;
            valid_out <= 0;
        end else begin
            if (valid_in) begin
                flag <= 1;
                valid_out <= 0;
            end else if (!valid_in && flag) begin  // 출력 phase
                for (int i = 0; i < array_size; i = i+1) begin
                    dout[i] <= buffer_din[cnt * array_size + i];
                end
                cnt <= cnt - 1;
                valid_out <= 1;

                if (flag_count == 15) begin
                    flag <= 0;
                end
                flag_count <= flag_count + 1;
            end else begin
                for (int i = 0; i < array_size; i = i+1)
                    dout[i] <= '0;
                cnt <= clk_cnt;
                valid_out <= 0;
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

    always_ff @( posedge clk or negedge rstn ) begin
        if (!rstn) begin
            for (i = 0; i < buffer_depth; i = i+1) begin
                buffer_din [i] <= '0; 
            end
            start <= 1;
        end else if (!valid_in && start)begin
            start <=0;
            for (i = buffer_depth -1; i > array_size -1; i = i -1) begin
                buffer_din[i] <= buffer_din[i - array_size];
            end
            for (int i = 0; i < array_size; i = i+1) begin
                    buffer_din[i] <= din[i];
            end 
        end else if (!start) begin
            for (i = buffer_depth -1; i > array_size -1; i = i -1) begin
                buffer_din[i] <= buffer_din[i - array_size];
            end
            for (int i = 0; i < array_size; i = i+1) begin
                    buffer_din[i] <= din[i];
            end 
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
