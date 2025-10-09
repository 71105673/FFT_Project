`timescale 1ns/1ps


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
    