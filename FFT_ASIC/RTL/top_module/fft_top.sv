`timescale 1ns / 1ps

module fft_top #(
    parameter WIDTH = 9
) (
    input clk,
    input rstn,
    input fft_mode, // 0: ifft, 1: fft

    input signed [WIDTH-1:0] din_i[0:15],
    input signed [WIDTH-1:0] din_q[0:15],
    input din_valid,

    output logic signed [WIDTH+3:0] do_re[0:15],
    output logic signed [WIDTH+3:0] do_im[0:15],
    output logic do_en
);

    logic [4:0] do_index_module0[0:15];
    logic [4:0] do_index_module0_buf[0:15];
    logic [4:0] do_index_module1[0:15];


    logic [5:0] di_index_sum[0:15];

    logic do_en_module0;
    logic signed [11-1:0] do_re_module0[0:15];
    logic signed [11-1:0] do_im_module0[0:15];


    logic do_en_module1;
    logic signed [12-1:0] do_re_module1[0:15];
    logic signed [12-1:0] do_im_module1[0:15];

    logic do_en_module2;
    logic signed [12:0] do_re_module2[0:15];
    logic signed [12:0] do_im_module2[0:15];

    sdf1 #(
        .N(512),
        .M(512),
        .WIDTH(9),
        .WIDTH_DO(11)
    ) MODUL0 (
        .clk(clk),
        .rstn(rstn),
        .fft_mode(1'b1),

        .di_en(din_valid),
        .di_re(din_i),
        .di_im(din_q),

        .do_index(do_index_module0),
        .do_en(do_en_module0),
        .do_re(do_re_module0),
        .do_im(do_im_module0)
    );

    sdf2 #(
        .N(512),
        .M(512),
        .WIDTH(11),
        .WIDTH_DO(12)
    ) MODUL1 (
        .clk(clk),
        .rstn(rstn),
        .fft_mode(1'b1),

        .di_en(do_en_module0),
        .di_re(do_re_module0),
        .di_im(do_im_module0),

        .do_index(do_index_module1),
        .do_en(do_en_module1),
        .do_re(do_re_module1),
        .do_im(do_im_module1)
    );

    delaybuffer_re #(
        .DEPTH(144 + 32),
        .WIDTH(5)
    ) index_buf (
        .rstn (rstn),
        .clk  (clk),
        .di_re(do_index_module0),
        .do_re(do_index_module0_buf)
    );

    index_adder_array #(
        .WIDTH_IN(5),
        .WIDTH_OUT(6),
        .SIZE(16)
    ) u_index_adder_array (
        .in0(do_index_module0_buf),
        .in1(do_index_module1),
        .out(di_index_sum)
    );

    sdf3 #(
        .N(512),
        .M(512),
        .WIDTH(12),
        .WIDTH_DO(13)
    ) MODUL2 (
        .clk(clk),
        .rstn(rstn),
        .fft_mode(1'b1),

        .di_en(do_en_module1),
        .di_re(do_re_module1),
        .di_im(do_im_module1),
        .di_index(di_index_sum),

        .do_en(do_en_module2),
        .do_re(do_re_module2),
        .do_im(do_im_module2)
    );

    bit_reverse_512_pipeline #(
        .DATA_WIDTH  (13),  // 각 데이터의 폭
        .ADDR_WIDTH  (9),   // 주소 폭 (512 = 2^9)
        .PARALLEL_NUM(16)   // 병렬 처리 개수
    ) reorder (
        .clk(clk),
        .rst_n(rstn),
        .valid_in(do_en_module2),  // 입력 데이터 유효 신호
        .data_in_re(do_re_module2),  // 16개 병렬 입력 실수부
        .data_in_im(do_im_module2),  // 16개 병렬 입력 허수부
        .data_out_re(),  // 16개 병렬 출력 실수부
        .data_out_im(),  // 16개 병렬 출력 허수부
        .addr_out   (),  // 16개 출력 주소
        .valid_out  (),  // 출력 데이터 유효 신호
        .final_dout_re    (do_re),  // 16개 병렬 최종 출력 실수부
        .final_dout_im    (do_im),  // 16개 병렬 최종 출력 허수부
        .final_block_index(),  // 현재 출력 블록 인덱스 (0~31)
        .final_valid      (do_en),  // 최종 출력 유효 신호
        .final_complete   ()
    );
endmodule



module index_adder_array #(
    parameter WIDTH_IN = 5,
    parameter WIDTH_OUT = 6,
    parameter SIZE = 16
) (
    input  logic [ WIDTH_IN-1:0] in0[0:SIZE-1],
    input  logic [ WIDTH_IN-1:0] in1[0:SIZE-1],
    output logic [WIDTH_OUT-1:0] out[0:SIZE-1]
);

    genvar i;
    generate
        for (i = 0; i < SIZE; i++) begin : add_loop
            assign out[i] = in0[i] + in1[i];
        end
    endgenerate

endmodule
