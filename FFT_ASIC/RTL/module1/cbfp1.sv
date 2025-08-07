`timescale 1ns / 1ps

module cbfp1 #(
    parameter WIDTH = 25,
    parameter OWIDTH = 12
)(
    input clk,
    input rstn,

    input signed [WIDTH-1:0] di_re [0:15],
    input signed [WIDTH-1:0] di_im [0:15],
    input di_en,

    output logic signed [OWIDTH-1:0] do_re [0:15],
    output logic signed [OWIDTH-1:0] do_im [0:15],
    output logic do_en,
    output logic [4:0] do_index [0:15]  // 0~511 범위를 위해 9비트로 확장
);

// 16개를 8개씩 두 블록으로 분할
logic signed [WIDTH-1:0] di_re_blk0 [0:7];   // 첫 번째 블록 (인덱스 0~7)
logic signed [WIDTH-1:0] di_re_blk1 [0:7];   // 두 번째 블록 (인덱스 8~15)
logic signed [WIDTH-1:0] di_im_blk0 [0:7];
logic signed [WIDTH-1:0] di_im_blk1 [0:7];

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_block_split
        assign di_re_blk0[i] = di_re[i];
        assign di_re_blk1[i] = di_re[i+8];
        assign di_im_blk0[i] = di_im[i];
        assign di_im_blk1[i] = di_im[i+8];
    end
endgenerate

// 각 블록별 magnitude count 배열
logic [4:0] mag_cnt_re_blk0 [0:7];
logic [4:0] mag_cnt_im_blk0 [0:7];
logic [4:0] mag_cnt_re_blk1 [0:7];
logic [4:0] mag_cnt_im_blk1 [0:7];

// 각 블록별 최소값
logic [4:0] min_value_blk0;
logic [4:0] min_value_blk1;

// 클럭 카운터 (32클럭)
logic [4:0] clk_count;
logic [8:0] base_index;  // 0, 16, 32, ..., 496

// 클럭 카운터
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_count <= 5'd0;
        base_index <= 9'd0;
    end else if (di_en) begin
        if (clk_count == 5'd31) begin
            clk_count <= 5'd0;
            base_index <= 9'd0;
        end else begin
            clk_count <= clk_count + 1'b1;
            base_index <= base_index + 9'd16;
        end
    end else begin
        clk_count <= 5'd0;
        base_index <= 9'd0;
    end
end

// Magnitude Detection for Block 0 (인덱스 0~7)
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_mag_detect_blk0
        assign mag_cnt_re_blk0[i] =
            (di_re_blk0[i][23:0] == 24'h0 & ~di_re_blk0[i][24]) ? 5'd24 :
            (di_re_blk0[i][23:1] == 23'h0 & ~di_re_blk0[i][24]) ? 5'd23 :
            (di_re_blk0[i][23:2] == 22'h0 & ~di_re_blk0[i][24]) ? 5'd22 :
            (di_re_blk0[i][23:3] == 21'h0 & ~di_re_blk0[i][24]) ? 5'd21 :
            (di_re_blk0[i][23:4] == 20'h0 & ~di_re_blk0[i][24]) ? 5'd20 :
            (di_re_blk0[i][23:5] == 19'h0 & ~di_re_blk0[i][24]) ? 5'd19 :
            (di_re_blk0[i][23:6] == 18'h0 & ~di_re_blk0[i][24]) ? 5'd18 :
            (di_re_blk0[i][23:7] == 17'h0 & ~di_re_blk0[i][24]) ? 5'd17 :
            (di_re_blk0[i][23:8] == 16'h0 & ~di_re_blk0[i][24]) ? 5'd16 :
            (di_re_blk0[i][23:9] == 15'h0 & ~di_re_blk0[i][24]) ? 5'd15 :
            (di_re_blk0[i][23:10] == 14'h0 & ~di_re_blk0[i][24]) ? 5'd14 :
            (di_re_blk0[i][23:11] == 13'h0 & ~di_re_blk0[i][24]) ? 5'd13 :
            (di_re_blk0[i][23:12] == 12'h0 & ~di_re_blk0[i][24]) ? 5'd12 :
            (di_re_blk0[i][23:13] == 11'h0 & ~di_re_blk0[i][24]) ? 5'd11 :
            (di_re_blk0[i][23:14] == 10'h0 & ~di_re_blk0[i][24]) ? 5'd10 :
            (di_re_blk0[i][23:15] ==  9'h0 & ~di_re_blk0[i][24]) ? 5'd9 :
            (di_re_blk0[i][23:16] ==  8'h0 & ~di_re_blk0[i][24]) ? 5'd8  :
            (di_re_blk0[i][23:17] ==  7'h0 & ~di_re_blk0[i][24]) ? 5'd7  :
            (di_re_blk0[i][23:18] ==  6'h0 & ~di_re_blk0[i][24]) ? 5'd6  :
            (di_re_blk0[i][23:19] ==  5'h0 & ~di_re_blk0[i][24]) ? 5'd5  :
            (di_re_blk0[i][23:20] ==  4'h0 & ~di_re_blk0[i][24]) ? 5'd4  :
            (di_re_blk0[i][23:21] ==  3'h0 & ~di_re_blk0[i][24]) ? 5'd3  :
            (di_re_blk0[i][23:22] ==  2'h0 & ~di_re_blk0[i][24]) ? 5'd2  :
            (di_re_blk0[i][23]    ==  1'b0 & ~di_re_blk0[i][24]) ? 5'd1  :
            (di_re_blk0[i][23:0]  == 24'hffffff &&  di_re_blk0[i][24]) ? 5'd24 :
            (di_re_blk0[i][23:1]  == 23'h7fffff &&  di_re_blk0[i][24]) ? 5'd23 :
            (di_re_blk0[i][23:2]  == 22'h3fffff  &&  di_re_blk0[i][24]) ? 5'd22 :
            (di_re_blk0[i][23:3]  == 21'h1fffff  &&  di_re_blk0[i][24]) ? 5'd21 :
            (di_re_blk0[i][23:4]  == 20'hfffff  &&  di_re_blk0[i][24]) ? 5'd20 :
            (di_re_blk0[i][23:5]  == 19'h7ffff  &&  di_re_blk0[i][24]) ? 5'd19 :
            (di_re_blk0[i][23:6]  == 18'h3ffff   &&  di_re_blk0[i][24]) ? 5'd18 :
            (di_re_blk0[i][23:7]  == 17'h1ffff   &&  di_re_blk0[i][24]) ? 5'd17 :
            (di_re_blk0[i][23:8]  == 16'hffff   &&  di_re_blk0[i][24]) ? 5'd16 :
            (di_re_blk0[i][23:9]  == 15'h7fff   &&  di_re_blk0[i][24]) ? 5'd15 :
            (di_re_blk0[i][23:10] == 14'h3fff    &&  di_re_blk0[i][24]) ? 5'd14 :
            (di_re_blk0[i][23:11] == 13'h1fff    &&  di_re_blk0[i][24]) ? 5'd13 :
            (di_re_blk0[i][23:12] == 12'hfff    &&  di_re_blk0[i][24]) ? 5'd12 :
            (di_re_blk0[i][23:13] == 11'h7ff    &&  di_re_blk0[i][24]) ? 5'd11  :
            (di_re_blk0[i][23:14] == 10'h3ff     &&  di_re_blk0[i][24]) ? 5'd10  :
            (di_re_blk0[i][23:15] == 9'h1ff      &&  di_re_blk0[i][24]) ? 5'd9  :
            (di_re_blk0[i][23:16] == 8'hff      &&  di_re_blk0[i][24]) ? 5'd8  :
            (di_re_blk0[i][23:17] == 7'h7f      &&  di_re_blk0[i][24]) ? 5'd7  :
            (di_re_blk0[i][23:18] == 6'h3f      &&  di_re_blk0[i][24]) ? 5'd6  :
            (di_re_blk0[i][23:19] == 5'h1f       &&  di_re_blk0[i][24]) ? 5'd5  :
            (di_re_blk0[i][23:20] == 4'hf       &&  di_re_blk0[i][24]) ? 5'd4  :
            (di_re_blk0[i][23:21] == 3'h7       &&  di_re_blk0[i][24]) ? 5'd3  :
            (di_re_blk0[i][23:22] == 2'h3       &&  di_re_blk0[i][24]) ? 5'd2  :
            (di_re_blk0[i][23] == 1'b1          &&  di_re_blk0[i][24]) ? 5'd1  :
                                                               5'd0;
        
        assign mag_cnt_im_blk0[i] =
            (di_im_blk0[i][23:0] == 24'h0 & ~di_im_blk0[i][24]) ? 5'd24 :
            (di_im_blk0[i][23:1] == 23'h0 & ~di_im_blk0[i][24]) ? 5'd23 :
            (di_im_blk0[i][23:2] == 22'h0 & ~di_im_blk0[i][24]) ? 5'd22 :
            (di_im_blk0[i][23:3] == 21'h0 & ~di_im_blk0[i][24]) ? 5'd21 :
            (di_im_blk0[i][23:4] == 20'h0 & ~di_im_blk0[i][24]) ? 5'd20 :
            (di_im_blk0[i][23:5] == 19'h0 & ~di_im_blk0[i][24]) ? 5'd19 :
            (di_im_blk0[i][23:6] == 18'h0 & ~di_im_blk0[i][24]) ? 5'd18 :
            (di_im_blk0[i][23:7] == 17'h0 & ~di_im_blk0[i][24]) ? 5'd17 :
            (di_im_blk0[i][23:8] == 16'h0 & ~di_im_blk0[i][24]) ? 5'd16 :
            (di_im_blk0[i][23:9] == 15'h0 & ~di_im_blk0[i][24]) ? 5'd15 :
            (di_im_blk0[i][23:10] == 14'h0 & ~di_im_blk0[i][24]) ? 5'd14 :
            (di_im_blk0[i][23:11] == 13'h0 & ~di_im_blk0[i][24]) ? 5'd13 :
            (di_im_blk0[i][23:12] == 12'h0 & ~di_im_blk0[i][24]) ? 5'd12 :
            (di_im_blk0[i][23:13] == 11'h0 & ~di_im_blk0[i][24]) ? 5'd11  :
            (di_im_blk0[i][23:14] == 10'h0 & ~di_im_blk0[i][24]) ? 5'd10  :
            (di_im_blk0[i][23:15] ==  9'h0 & ~di_im_blk0[i][24]) ? 5'd9  :
            (di_im_blk0[i][23:16] ==  8'h0 & ~di_im_blk0[i][24]) ? 5'd8  :
            (di_im_blk0[i][23:17] ==  7'h0 & ~di_im_blk0[i][24]) ? 5'd7  :
            (di_im_blk0[i][23:18] ==  6'h0 & ~di_im_blk0[i][24]) ? 5'd6  :
            (di_im_blk0[i][23:19] ==  5'h0 & ~di_im_blk0[i][24]) ? 5'd5  :
            (di_im_blk0[i][23:20] ==  4'h0 & ~di_im_blk0[i][24]) ? 5'd4  :
            (di_im_blk0[i][23:21] ==  3'h0 & ~di_im_blk0[i][24]) ? 5'd3  :
            (di_im_blk0[i][23:22] ==  2'h0 & ~di_im_blk0[i][24]) ? 5'd2  :
            (di_im_blk0[i][23]    ==  1'b0 & ~di_im_blk0[i][24]) ? 5'd1  :
            (di_im_blk0[i][23:0]  == 24'hffffff &&  di_im_blk0[i][24]) ? 5'd24 :
            (di_im_blk0[i][23:1]  == 23'h7fffff &&  di_im_blk0[i][24]) ? 5'd23 :
            (di_im_blk0[i][23:2]  == 22'h3fffff &&  di_im_blk0[i][24]) ? 5'd22 :
            (di_im_blk0[i][23:3]  == 21'h1fffff &&  di_im_blk0[i][24]) ? 5'd21 :
            (di_im_blk0[i][23:4]  == 20'hfffff  &&  di_im_blk0[i][24]) ? 5'd20 :
            (di_im_blk0[i][23:5]  == 19'h7ffff  &&  di_im_blk0[i][24]) ? 5'd19 :
            (di_im_blk0[i][23:6]  == 18'h3ffff  &&  di_im_blk0[i][24]) ? 5'd18 :
            (di_im_blk0[i][23:7]  == 17'h1ffff  &&  di_im_blk0[i][24]) ? 5'd17 :
            (di_im_blk0[i][23:8]  == 16'hffff   &&  di_im_blk0[i][24]) ? 5'd16 :
            (di_im_blk0[i][23:9]  == 15'h7fff   &&  di_im_blk0[i][24]) ? 5'd15 :
            (di_im_blk0[i][23:10]  == 14'h3fff   &&  di_im_blk0[i][24]) ? 5'd14 :
            (di_im_blk0[i][23:11]  == 13'h1fff   &&  di_im_blk0[i][24]) ? 5'd13 :
            (di_im_blk0[i][23:12] == 12'hfff    &&  di_im_blk0[i][24]) ? 5'd12 :
            (di_im_blk0[i][23:13] == 11'h7ff    &&  di_im_blk0[i][24]) ? 5'd11 :
            (di_im_blk0[i][23:14] == 10'h3ff    &&  di_im_blk0[i][24]) ? 5'd10 :
            (di_im_blk0[i][23:15] == 9'h1ff     &&  di_im_blk0[i][24]) ? 5'd9  :
            (di_im_blk0[i][23:16] == 8'hff      &&  di_im_blk0[i][24]) ? 5'd8  :
            (di_im_blk0[i][23:17] == 7'h7f      &&  di_im_blk0[i][24]) ? 5'd7  :
            (di_im_blk0[i][23:18] == 6'h3f      &&  di_im_blk0[i][24]) ? 5'd6  :
            (di_im_blk0[i][23:19] == 5'h1f      &&  di_im_blk0[i][24]) ? 5'd5  :
            (di_im_blk0[i][23:20] == 4'hf       &&  di_im_blk0[i][24]) ? 5'd4  :
            (di_im_blk0[i][23:21] == 3'h7       &&  di_im_blk0[i][24]) ? 5'd3  :
            (di_im_blk0[i][23:22] == 2'h3       &&  di_im_blk0[i][24]) ? 5'd2  :
            (di_im_blk0[i][23]    == 1'b1       &&  di_im_blk0[i][24]) ? 5'd1  :
                                                               5'd0;
    end
endgenerate

// Magnitude Detection for Block 1 (인덱스 8~15)
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_mag_detect_blk1
        assign mag_cnt_re_blk1[i] =
            (di_re_blk1[i][23:0] == 24'h0 & ~di_re_blk1[i][24]) ? 5'd24 :
            (di_re_blk1[i][23:1] == 23'h0 & ~di_re_blk1[i][24]) ? 5'd23 :
            (di_re_blk1[i][23:2] == 22'h0 & ~di_re_blk1[i][24]) ? 5'd22 :
            (di_re_blk1[i][23:3] == 21'h0 & ~di_re_blk1[i][24]) ? 5'd21 :
            (di_re_blk1[i][23:4] == 20'h0 & ~di_re_blk1[i][24]) ? 5'd20 :
            (di_re_blk1[i][23:5] == 19'h0 & ~di_re_blk1[i][24]) ? 5'd19 :
            (di_re_blk1[i][23:6] == 18'h0 & ~di_re_blk1[i][24]) ? 5'd18 :
            (di_re_blk1[i][23:7] == 17'h0 & ~di_re_blk1[i][24]) ? 5'd17 :
            (di_re_blk1[i][23:8] == 16'h0 & ~di_re_blk1[i][24]) ? 5'd16 :
            (di_re_blk1[i][23:9] == 15'h0 & ~di_re_blk1[i][24]) ? 5'd15 :
            (di_re_blk1[i][23:10] == 14'h0 & ~di_re_blk1[i][24]) ? 5'd14 :
            (di_re_blk1[i][23:11] == 13'h0 & ~di_re_blk1[i][24]) ? 5'd13 :
            (di_re_blk1[i][23:12] == 12'h0 & ~di_re_blk1[i][24]) ? 5'd12 :
            (di_re_blk1[i][23:13] == 11'h0 & ~di_re_blk1[i][24]) ? 5'd11 :
            (di_re_blk1[i][23:14] == 10'h0 & ~di_re_blk1[i][24]) ? 5'd10 :
            (di_re_blk1[i][23:15] ==  9'h0 & ~di_re_blk1[i][24]) ? 5'd9 :
            (di_re_blk1[i][23:16] ==  8'h0 & ~di_re_blk1[i][24]) ? 5'd8  :
            (di_re_blk1[i][23:17] ==  7'h0 & ~di_re_blk1[i][24]) ? 5'd7  :
            (di_re_blk1[i][23:18] ==  6'h0 & ~di_re_blk1[i][24]) ? 5'd6  :
            (di_re_blk1[i][23:19] ==  5'h0 & ~di_re_blk1[i][24]) ? 5'd5  :
            (di_re_blk1[i][23:20] ==  4'h0 & ~di_re_blk1[i][24]) ? 5'd4  :
            (di_re_blk1[i][23:21] ==  3'h0 & ~di_re_blk1[i][24]) ? 5'd3  :
            (di_re_blk1[i][23:22] ==  2'h0 & ~di_re_blk1[i][24]) ? 5'd2  :
            (di_re_blk1[i][23]    ==  1'b0 & ~di_re_blk1[i][24]) ? 5'd1  :
            (di_re_blk1[i][23:0]  == 24'hffffff &&  di_re_blk1[i][24]) ? 5'd24 :
            (di_re_blk1[i][23:1]  == 23'h7fffff &&  di_re_blk1[i][24]) ? 5'd23 :
            (di_re_blk1[i][23:2]  == 22'h3fffff  &&  di_re_blk1[i][24]) ? 5'd22 :
            (di_re_blk1[i][23:3]  == 21'h1fffff  &&  di_re_blk1[i][24]) ? 5'd21 :
            (di_re_blk1[i][23:4]  == 20'hfffff  &&  di_re_blk1[i][24]) ? 5'd20 :
            (di_re_blk1[i][23:5]  == 19'h7ffff  &&  di_re_blk1[i][24]) ? 5'd19 :
            (di_re_blk1[i][23:6]  == 18'h3ffff   &&  di_re_blk1[i][24]) ? 5'd18 :
            (di_re_blk1[i][23:7]  == 17'h1ffff   &&  di_re_blk1[i][24]) ? 5'd17 :
            (di_re_blk1[i][23:8]  == 16'hffff   &&  di_re_blk1[i][24]) ? 5'd16 :
            (di_re_blk1[i][23:9]  == 15'h7fff   &&  di_re_blk1[i][24]) ? 5'd15 :
            (di_re_blk1[i][23:10] == 14'h3fff    &&  di_re_blk1[i][24]) ? 5'd14 :
            (di_re_blk1[i][23:11] == 13'h1fff    &&  di_re_blk1[i][24]) ? 5'd13 :
            (di_re_blk1[i][23:12] == 12'hfff    &&  di_re_blk1[i][24]) ? 5'd12 :
            (di_re_blk1[i][23:13] == 11'h7ff    &&  di_re_blk1[i][24]) ? 5'd11  :
            (di_re_blk1[i][23:14] == 10'h3ff     &&  di_re_blk1[i][24]) ? 5'd10  :
            (di_re_blk1[i][23:15] == 9'h1ff      &&  di_re_blk1[i][24]) ? 5'd9  :
            (di_re_blk1[i][23:16] == 8'hff      &&  di_re_blk1[i][24]) ? 5'd8  :
            (di_re_blk1[i][23:17] == 7'h7f      &&  di_re_blk1[i][24]) ? 5'd7  :
            (di_re_blk1[i][23:18] == 6'h3f      &&  di_re_blk1[i][24]) ? 5'd6  :
            (di_re_blk1[i][23:19] == 5'h1f       &&  di_re_blk1[i][24]) ? 5'd5  :
            (di_re_blk1[i][23:20] == 4'hf       &&  di_re_blk1[i][24]) ? 5'd4  :
            (di_re_blk1[i][23:21] == 3'h7       &&  di_re_blk1[i][24]) ? 5'd3  :
            (di_re_blk1[i][23:22] == 2'h3       &&  di_re_blk1[i][24]) ? 5'd2  :
            (di_re_blk1[i][23] == 1'b1          &&  di_re_blk1[i][24]) ? 5'd1  :
                                                               5'd0;
        
        assign mag_cnt_im_blk1[i] =
            (di_im_blk1[i][23:0] == 24'h0 & ~di_im_blk1[i][24]) ? 5'd24 :
            (di_im_blk1[i][23:1] == 23'h0 & ~di_im_blk1[i][24]) ? 5'd23 :
            (di_im_blk1[i][23:2] == 22'h0 & ~di_im_blk1[i][24]) ? 5'd22 :
            (di_im_blk1[i][23:3] == 21'h0 & ~di_im_blk1[i][24]) ? 5'd21 :
            (di_im_blk1[i][23:4] == 20'h0 & ~di_im_blk1[i][24]) ? 5'd20 :
            (di_im_blk1[i][23:5] == 19'h0 & ~di_im_blk1[i][24]) ? 5'd19 :
            (di_im_blk1[i][23:6] == 18'h0 & ~di_im_blk1[i][24]) ? 5'd18 :
            (di_im_blk1[i][23:7] == 17'h0 & ~di_im_blk1[i][24]) ? 5'd17 :
            (di_im_blk1[i][23:8] == 16'h0 & ~di_im_blk1[i][24]) ? 5'd16 :
            (di_im_blk1[i][23:9] == 15'h0 & ~di_im_blk1[i][24]) ? 5'd15 :
            (di_im_blk1[i][23:10] == 14'h0 & ~di_im_blk1[i][24]) ? 5'd14 :
            (di_im_blk1[i][23:11] == 13'h0 & ~di_im_blk1[i][24]) ? 5'd13 :
            (di_im_blk1[i][23:12] == 12'h0 & ~di_im_blk1[i][24]) ? 5'd12 :
            (di_im_blk1[i][23:13] == 11'h0 & ~di_im_blk1[i][24]) ? 5'd11  :
            (di_im_blk1[i][23:14] == 10'h0 & ~di_im_blk1[i][24]) ? 5'd10  :
            (di_im_blk1[i][23:15] ==  9'h0 & ~di_im_blk1[i][24]) ? 5'd9  :
            (di_im_blk1[i][23:16] ==  8'h0 & ~di_im_blk1[i][24]) ? 5'd8  :
            (di_im_blk1[i][23:17] ==  7'h0 & ~di_im_blk1[i][24]) ? 5'd7  :
            (di_im_blk1[i][23:18] ==  6'h0 & ~di_im_blk1[i][24]) ? 5'd6  :
            (di_im_blk1[i][23:19] ==  5'h0 & ~di_im_blk1[i][24]) ? 5'd5  :
            (di_im_blk1[i][23:20] ==  4'h0 & ~di_im_blk1[i][24]) ? 5'd4  :
            (di_im_blk1[i][23:21] ==  3'h0 & ~di_im_blk1[i][24]) ? 5'd3  :
            (di_im_blk1[i][23:22] ==  2'h0 & ~di_im_blk1[i][24]) ? 5'd2  :
            (di_im_blk1[i][23]    ==  1'b0 & ~di_im_blk1[i][24]) ? 5'd1  :
            (di_im_blk1[i][23:0]  == 24'hffffff &&  di_im_blk1[i][24]) ? 5'd24 :
            (di_im_blk1[i][23:1]  == 23'h7fffff &&  di_im_blk1[i][24]) ? 5'd23 :
            (di_im_blk1[i][23:2]  == 22'h3fffff &&  di_im_blk1[i][24]) ? 5'd22 :
            (di_im_blk1[i][23:3]  == 21'h1fffff &&  di_im_blk1[i][24]) ? 5'd21 :
            (di_im_blk1[i][23:4]  == 20'hfffff  &&  di_im_blk1[i][24]) ? 5'd20 :
            (di_im_blk1[i][23:5]  == 19'h7ffff  &&  di_im_blk1[i][24]) ? 5'd19 :
            (di_im_blk1[i][23:6]  == 18'h3ffff  &&  di_im_blk1[i][24]) ? 5'd18 :
            (di_im_blk1[i][23:7]  == 17'h1ffff  &&  di_im_blk1[i][24]) ? 5'd17 :
            (di_im_blk1[i][23:8]  == 16'hffff   &&  di_im_blk1[i][24]) ? 5'd16 :
            (di_im_blk1[i][23:9]  == 15'h7fff   &&  di_im_blk1[i][24]) ? 5'd15 :
            (di_im_blk1[i][23:10]  == 14'h3fff   &&  di_im_blk1[i][24]) ? 5'd14 :
            (di_im_blk1[i][23:11]  == 13'h1fff   &&  di_im_blk1[i][24]) ? 5'd13 :
            (di_im_blk1[i][23:12] == 12'hfff    &&  di_im_blk1[i][24]) ? 5'd12 :
            (di_im_blk1[i][23:13] == 11'h7ff    &&  di_im_blk1[i][24]) ? 5'd11 :
            (di_im_blk1[i][23:14] == 10'h3ff    &&  di_im_blk1[i][24]) ? 5'd10 :
            (di_im_blk1[i][23:15] == 9'h1ff     &&  di_im_blk1[i][24]) ? 5'd9  :
            (di_im_blk1[i][23:16] == 8'hff      &&  di_im_blk1[i][24]) ? 5'd8  :
            (di_im_blk1[i][23:17] == 7'h7f      &&  di_im_blk1[i][24]) ? 5'd7  :
            (di_im_blk1[i][23:18] == 6'h3f      &&  di_im_blk1[i][24]) ? 5'd6  :
            (di_im_blk1[i][23:19] == 5'h1f      &&  di_im_blk1[i][24]) ? 5'd5  :
            (di_im_blk1[i][23:20] == 4'hf       &&  di_im_blk1[i][24]) ? 5'd4  :
            (di_im_blk1[i][23:21] == 3'h7       &&  di_im_blk1[i][24]) ? 5'd3  :
            (di_im_blk1[i][23:22] == 2'h3       &&  di_im_blk1[i][24]) ? 5'd2  :
            (di_im_blk1[i][23]    == 1'b1       &&  di_im_blk1[i][24]) ? 5'd1  :
                                                               5'd0;
    end
endgenerate

// 각 블록별 최소값 계산
always_comb begin
    // Block 0 최소값 계산
    min_value_blk0 = mag_cnt_re_blk0[0];
    for (int j = 0; j < 8; j++) begin
        if (mag_cnt_re_blk0[j] < min_value_blk0)
            min_value_blk0 = mag_cnt_re_blk0[j];
        if (mag_cnt_im_blk0[j] < min_value_blk0)
            min_value_blk0 = mag_cnt_im_blk0[j];
    end
    
    // Block 1 최소값 계산
    min_value_blk1 = mag_cnt_re_blk1[0];
    for (int j = 0; j < 8; j++) begin
        if (mag_cnt_re_blk1[j] < min_value_blk1)
            min_value_blk1 = mag_cnt_re_blk1[j];
        if (mag_cnt_im_blk1[j] < min_value_blk1)
            min_value_blk1 = mag_cnt_im_blk1[j];
    end
end

// 시프트 연산을 위한 임시 변수들
logic signed [WIDTH-1:0] temp_shift_re [0:15];
logic signed [WIDTH-1:0] temp_shift_im [0:15];

// 시프트 연산 및 출력 생성
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_block0_output
        // Block 0 시프트 연산 (인덱스 0~7)
        always_comb begin
            if (min_value_blk0 > 5'd13) begin
                temp_shift_re[i] = (di_re[i] <<< min_value_blk0) >>> 13;
                temp_shift_im[i] = (di_im[i] <<< min_value_blk0) >>> 13;
            end else if (min_value_blk0 == 5'd13) begin
                temp_shift_re[i] = di_re[i];
                temp_shift_im[i] = di_im[i];
            end else begin
                temp_shift_re[i] = di_re[i] >>> (5'd13 - min_value_blk0);
                temp_shift_im[i] = di_im[i] >>> (5'd13 - min_value_blk0);
            end
        end
        
        // Block 0 출력 할당
        assign do_re[i] = temp_shift_re[i][OWIDTH-1:0];
        assign do_im[i] = temp_shift_im[i][OWIDTH-1:0];
        
        // Block 0 인덱스 출력
        assign do_index[i] = min_value_blk0;
    end
    
    for (i = 0; i < 8; i = i + 1) begin : gen_block1_output
        // Block 1 시프트 연산 (인덱스 8~15)
        always_comb begin
            if (min_value_blk1 > 5'd13) begin
                temp_shift_re[i+8] = (di_re[i+8] <<< min_value_blk1) >>> 13;
                temp_shift_im[i+8] = (di_im[i+8] <<< min_value_blk1) >>> 13;
            end else if (min_value_blk1 == 5'd13) begin
                temp_shift_re[i+8] = di_re[i+8];
                temp_shift_im[i+8] = di_im[i+8];
            end else begin
                temp_shift_re[i+8] = di_re[i+8] >>> (5'd13 - min_value_blk1);
                temp_shift_im[i+8] = di_im[i+8] >>> (5'd13 - min_value_blk1);
            end
        end
        
        // Block 1 출력 할당
        assign do_re[i+8] = temp_shift_re[i+8][OWIDTH-1:0];
        assign do_im[i+8] = temp_shift_im[i+8][OWIDTH-1:0];
        
        // Block 1 인덱스 출력
        assign do_index[i+8] = min_value_blk1;
    end
endgenerate

    // 7. do_en 및 do_count 제어 (출력 데이터 유효 신호)
    logic [4:0] do_count;
    logic do_start;
    logic do_end;
    always_comb begin
        if (clk_count == 5'd2)
            do_start = 1'b1;
        else
            do_start = 1'b0;
        if (do_count == 5'd31)
            do_end = 1'b1;
        else
            do_end = 1'b0;
    end

    // 이 always_ff 블록을 삼항 연산자 스타일로 수정합니다.
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            do_en <= 1'b0;
            do_count <= 'h0;
        end else begin
            do_en <= (do_start ? 1'b1 : (do_end ? 1'b0 : do_en));
            do_count <= (do_start || do_end) ? 'h0 : (do_en ? do_count + 1'b1 : 'h0);
        end
    end
endmodule

// 기존 comp_min 모듈은 더 이상 사용되지 않으므로 제거하거나 그대로 유지
