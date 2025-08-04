`timescale 1ns / 1ps

module twiddle_64 #(
    parameter WIDTH = 9,
    parameter TW_TABLE_DEPTH = 64,
    parameter TW_FF = 1,
    parameter NUM_PARALLEL_PATHS = 16 // 이 파라미터를 추가
)(
    input clk,
    input [$clog2(TW_TABLE_DEPTH)-1:0] addr, 
    
    output signed [WIDTH-1:0] tw_re,
    output signed [WIDTH-1:0] tw_im
);

    wire[8:0]  twf_m1_real_val[0:TW_TABLE_DEPTH-1];   //  Twiddle Table (Real)
    wire[8:0]  twf_m1_imag_val[0:TW_TABLE_DEPTH-1];   //  Twiddle Table (Imag)
    wire[8:0]  mx_re;          //  Multiplexer output (Real)
    wire[8:0]  mx_im;          //  Multiplexer output (Imag)
    reg [8:0]  ff_re;          //  Register output (Real)
    reg [8:0]  ff_im;          //  Register output (Imag)

    assign  mx_re = twf_m1_real_val[addr];
    assign  mx_im = twf_m1_imag_val[addr];

    always @(posedge clk) begin
        ff_re <= mx_re;
        ff_im <= mx_im;
    end

    assign  tw_re = TW_FF ? ff_re : mx_re;
    assign  tw_im = TW_FF ? ff_im : mx_im;

    //----------------------------------------------------------------------
    //  Twiddle Factor Value
    //----------------------------------------------------------------------
    assign twf_m1_real_val[ 0] = 9'd128; assign twf_m1_imag_val[ 0] = 9'd0;
    assign twf_m1_real_val[ 1] = 9'd128; assign twf_m1_imag_val[ 1] = 9'd0;
    assign twf_m1_real_val[ 2] = 9'd128; assign twf_m1_imag_val[ 2] = 9'd0;
    assign twf_m1_real_val[ 3] = 9'd128; assign twf_m1_imag_val[ 3] = 9'd0;
    assign twf_m1_real_val[ 4] = 9'd128; assign twf_m1_imag_val[ 4] = 9'd0;
    assign twf_m1_real_val[ 5] = 9'd128; assign twf_m1_imag_val[ 5] = 9'd0;
    assign twf_m1_real_val[ 6] = 9'd128; assign twf_m1_imag_val[ 6] = 9'd0;
    assign twf_m1_real_val[ 7] = 9'd128; assign twf_m1_imag_val[ 7] = 9'd0;

    // k=4
    assign twf_m1_real_val[ 8] = 9'd128; assign twf_m1_imag_val[ 8] = 9'd0;
    assign twf_m1_real_val[ 9] = 9'd118; assign twf_m1_imag_val[ 9] = -9'd49;
    assign twf_m1_real_val[ 10] = 9'd91; assign twf_m1_imag_val[ 10] = -9'd91;
    assign twf_m1_real_val[ 11] = 9'd49; assign twf_m1_imag_val[ 11] = -9'd118;
    assign twf_m1_real_val[ 12] = 9'd0; assign twf_m1_imag_val[ 12] = -9'd128;
    assign twf_m1_real_val[ 13] = -9'd49; assign twf_m1_imag_val[ 13] = -9'd118;
    assign twf_m1_real_val[ 14] = -9'd91; assign twf_m1_imag_val[ 14] = -9'd91;
    assign twf_m1_real_val[ 15] = -9'd118; assign twf_m1_imag_val[ 15] = -9'd49;

    // k=2
    assign twf_m1_real_val[ 16] = 9'd128; assign twf_m1_imag_val[ 16] = 9'd0;
    assign twf_m1_real_val[ 17] = 9'd126; assign twf_m1_imag_val[ 17] = -9'd25;
    assign twf_m1_real_val[ 18] = 9'd118; assign twf_m1_imag_val[ 18] = -9'd49;
    assign twf_m1_real_val[ 19] = 9'd106; assign twf_m1_imag_val[ 19] = -9'd71;
    assign twf_m1_real_val[ 20] = 9'd91; assign twf_m1_imag_val[ 20] = -9'd91;
    assign twf_m1_real_val[ 21] = 9'd71; assign twf_m1_imag_val[ 21] = -9'd106;
    assign twf_m1_real_val[ 22] = 9'd49; assign twf_m1_imag_val[ 22] = -9'd118;
    assign twf_m1_real_val[ 23] = 9'd25; assign twf_m1_imag_val[ 23] = -9'd126;

    // k=6
    assign twf_m1_real_val[ 24] = 9'd128; assign twf_m1_imag_val[ 24] = 9'd0;
    assign twf_m1_real_val[ 25] = 9'd106; assign twf_m1_imag_val[ 25] = -9'd71;
    assign twf_m1_real_val[ 26] = 9'd49; assign twf_m1_imag_val[ 26] = -9'd118;
    assign twf_m1_real_val[ 27] = -9'd25; assign twf_m1_imag_val[ 27] = -9'd126;
    assign twf_m1_real_val[ 28] = -9'd91; assign twf_m1_imag_val[ 28] = -9'd91;
    assign twf_m1_real_val[ 29] = -9'd126; assign twf_m1_imag_val[ 29] = -9'd25;
    assign twf_m1_real_val[ 30] = -9'd118; assign twf_m1_imag_val[ 30] = 9'd49;
    assign twf_m1_real_val[ 31] = -9'd71; assign twf_m1_imag_val[ 31] = 9'd106;

    // k=1
    assign twf_m1_real_val[ 32] = 9'd128; assign twf_m1_imag_val[ 32] = 9'd0;
    assign twf_m1_real_val[ 33] = 9'd127; assign twf_m1_imag_val[ 33] = -9'd13;
    assign twf_m1_real_val[ 34] = 9'd126; assign twf_m1_imag_val[ 34] = -9'd25;
    assign twf_m1_real_val[ 35] = 9'd122; assign twf_m1_imag_val[ 35] = -9'd37;
    assign twf_m1_real_val[ 36] = 9'd118; assign twf_m1_imag_val[ 36] = -9'd49;
    assign twf_m1_real_val[ 37] = 9'd113; assign twf_m1_imag_val[ 37] = -9'd60;
    assign twf_m1_real_val[ 38] = 9'd106; assign twf_m1_imag_val[ 38] = -9'd71;
    assign twf_m1_real_val[ 39] = 9'd99; assign twf_m1_imag_val[ 39] = -9'd81;

    // k=5
    assign twf_m1_real_val[ 40] = 9'd128; assign twf_m1_imag_val[ 40] = 9'd0;
    assign twf_m1_real_val[ 41] = 9'd113; assign twf_m1_imag_val[ 41] = -9'd60;
    assign twf_m1_real_val[ 42] = 9'd71; assign twf_m1_imag_val[ 42] = -9'd106;
    assign twf_m1_real_val[ 43] = 9'd13; assign twf_m1_imag_val[ 43] = -9'd127;
    assign twf_m1_real_val[ 44] = -9'd49; assign twf_m1_imag_val[ 44] = -9'd118;
    assign twf_m1_real_val[ 45] = -9'd99; assign twf_m1_imag_val[ 45] = -9'd81;
    assign twf_m1_real_val[ 46] = -9'd126; assign twf_m1_imag_val[ 46] = -9'd25;
    assign twf_m1_real_val[ 47] = -9'd122; assign twf_m1_imag_val[ 47] = 9'd37;

    // k=3
    assign twf_m1_real_val[ 48] = 9'd128; assign twf_m1_imag_val[ 48] = 9'd0;
    assign twf_m1_real_val[ 49] = 9'd122; assign twf_m1_imag_val[ 49] = -9'd37;
    assign twf_m1_real_val[ 50] = 9'd106; assign twf_m1_imag_val[ 50] = -9'd71;
    assign twf_m1_real_val[ 51] = 9'd81; assign twf_m1_imag_val[ 51] = -9'd99;
    assign twf_m1_real_val[ 52] = 9'd49; assign twf_m1_imag_val[ 52] = -9'd118;
    assign twf_m1_real_val[ 53] = 9'd13; assign twf_m1_imag_val[ 53] = -9'd127;
    assign twf_m1_real_val[ 54] = -9'd25; assign twf_m1_imag_val[ 54] = -9'd126;
    assign twf_m1_real_val[ 55] = -9'd60; assign twf_m1_imag_val[ 55] = -9'd113;

    // k=7
    assign twf_m1_real_val[ 56] = 9'd128; assign twf_m1_imag_val[ 56] = 9'd0;
    assign twf_m1_real_val[ 57] = 9'd99; assign twf_m1_imag_val[ 57] = -9'd81;
    assign twf_m1_real_val[ 58] = 9'd25; assign twf_m1_imag_val[ 58] = -9'd126;
    assign twf_m1_real_val[ 59] = -9'd60; assign twf_m1_imag_val[ 59] = -9'd113;
    assign twf_m1_real_val[ 60] = -9'd118; assign twf_m1_imag_val[ 60] = -9'd49;
    assign twf_m1_real_val[ 61] = -9'd122; assign twf_m1_imag_val[ 61] = 9'd37;
    assign twf_m1_real_val[ 62] = -9'd71; assign twf_m1_imag_val[ 62] = 9'd106;
    assign twf_m1_real_val[ 63] = 9'd13; assign twf_m1_imag_val[ 63] = 9'd127;

endmodule


