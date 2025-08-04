`timescale 1ns / 1ps

module cbfp #(
    parameter WIDTH = 23,
    parameter OWIDTH = 11
)(
    input clk,
    input rstn,

    input signed [WIDTH-1:0] di_re [0:15],
    input signed [WIDTH-1:0] di_im [0:15],
    input di_en,

    output logic signed [OWIDTH-1:0] do_re [0:15],
    output logic signed [OWIDTH-1:0] do_im [0:15],
    output logic do_en,
    output logic [4:0] do_index [0:15]
);

logic signed [WIDTH-1:0] db_do_re [0:15];
logic signed [WIDTH-1:0] db_do_im [0:15];

logic [4:0] mag_cnt_re [0:15];
logic [4:0] mag_cnt_im [0:15];

logic [4:0] di_count;
logic cnt_valid;

logic [4:0] comp_do_re0 [0:3];
logic [4:0] comp_do_re1;
logic [4:0] comp_do_re2;

logic [4:0] comp_do_im0 [0:3];
logic [4:0] comp_do_im1;
logic [4:0] comp_do_im2;

logic [4:0] comp_min_cbfp_re0, comp_min_cbfp_re1, comp_min_cbfp_re2, comp_min_cbfp_re3;
logic [4:0] comp_min_cbfp_im0, comp_min_cbfp_im1, comp_min_cbfp_im2, comp_min_cbfp_im3;

logic [4:0] min_value;

logic signed [22:0] shift_re [0:15];
logic signed [22:0] shift_im [0:15];

logic do_start;
logic do_end;
logic [4:0] do_count;



always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        di_count <= 'h0;
    end else begin
        di_count <= di_en ? (di_count + 1'b1) : 'h0;
    end
end


delaybuffer_cbfp #(.DEPTH(64+16), .WIDTH(WIDTH)) db1 (
    .rstn (rstn),
    .clk  (clk),
    .di_re(di_re),
    .di_im(di_im),
    .do_re(db_do_re),
    .do_im(db_do_im)
);

// Magnitude Detection
genvar i;
    for (i = 0; i < 16; i = i + 1) begin
        assign mag_cnt_re[i] =
            (di_re[i][21:0] == 22'h0 & ~di_re[i][22]) ? 5'd22 :
            (di_re[i][21:1] == 21'h0 & ~di_re[i][22]) ? 5'd21 :
            (di_re[i][21:2] == 20'h0 & ~di_re[i][22]) ? 5'd20 :
            (di_re[i][21:3] == 19'h0 & ~di_re[i][22]) ? 5'd19 :
            (di_re[i][21:4] == 18'h0 & ~di_re[i][22]) ? 5'd18 :
            (di_re[i][21:5] == 17'h0 & ~di_re[i][22]) ? 5'd17 :
            (di_re[i][21:6] == 16'h0 & ~di_re[i][22]) ? 5'd16 :
            (di_re[i][21:7] == 15'h0 & ~di_re[i][22]) ? 5'd15 :
            (di_re[i][21:8] == 14'h0 & ~di_re[i][22]) ? 5'd14 :
            (di_re[i][21:9] == 13'h0 & ~di_re[i][22]) ? 5'd13 :
            (di_re[i][21:10] == 12'h0 & ~di_re[i][22]) ? 5'd12 :
            (di_re[i][21:11] == 11'h0 & ~di_re[i][22]) ? 5'd11 :
            (di_re[i][21:12] == 10'h0 & ~di_re[i][22]) ? 5'd10 :
            (di_re[i][21:13] ==  9'h0 & ~di_re[i][22]) ? 5'd9  :
            (di_re[i][21:14] ==  8'h0 & ~di_re[i][22]) ? 5'd8  :
            (di_re[i][21:15] ==  7'h0 & ~di_re[i][22]) ? 5'd7  :
            (di_re[i][21:16] ==  6'h0 & ~di_re[i][22]) ? 5'd6  :
            (di_re[i][21:17] ==  5'h0 & ~di_re[i][22]) ? 5'd5  :
            (di_re[i][21:18] ==  4'h0 & ~di_re[i][22]) ? 5'd4  :
            (di_re[i][21:19] ==  3'h0 & ~di_re[i][22]) ? 5'd3  :
            (di_re[i][21:20] ==  2'h0 & ~di_re[i][22]) ? 5'd2  :
            (di_re[i][21]    ==  1'b0 & ~di_re[i][22]) ? 5'd1  :
            (di_re[i][21:0]  == 22'h3fffff &&  di_re[i][22]) ? 5'd22 :
            (di_re[i][21:1]  == 21'h1fffff &&  di_re[i][22]) ? 5'd21 :
            (di_re[i][21:2]  == 20'hfffff  &&  di_re[i][22]) ? 5'd20 :
            (di_re[i][21:3]  == 19'h7ffff  &&  di_re[i][22]) ? 5'd19 :
            (di_re[i][21:4]  == 18'h3ffff  &&  di_re[i][22]) ? 5'd18 :
            (di_re[i][21:5]  == 17'h1ffff  &&  di_re[i][22]) ? 5'd17 :
            (di_re[i][21:6]  == 16'hffff   &&  di_re[i][22]) ? 5'd16 :
            (di_re[i][21:7]  == 15'h7fff   &&  di_re[i][22]) ? 5'd15 :
            (di_re[i][21:8]  == 14'h3fff   &&  di_re[i][22]) ? 5'd14 :
            (di_re[i][21:9]  == 13'h1fff   &&  di_re[i][22]) ? 5'd13 :
            (di_re[i][21:10] == 12'hfff    &&  di_re[i][22]) ? 5'd12 :
            (di_re[i][21:11] == 11'h7ff    &&  di_re[i][22]) ? 5'd11 :
            (di_re[i][21:12] == 10'h3ff    &&  di_re[i][22]) ? 5'd10 :
            (di_re[i][21:13] == 9'h1ff     &&  di_re[i][22]) ? 5'd9  :
            (di_re[i][21:14] == 8'hff      &&  di_re[i][22]) ? 5'd8  :
            (di_re[i][21:15] == 7'h7f      &&  di_re[i][22]) ? 5'd7  :
            (di_re[i][21:16] == 6'h3f      &&  di_re[i][22]) ? 5'd6  :
            (di_re[i][21:17] == 5'h1f      &&  di_re[i][22]) ? 5'd5  :
            (di_re[i][21:18] == 4'hf       &&  di_re[i][22]) ? 5'd4  :
            (di_re[i][21:19] == 3'h7       &&  di_re[i][22]) ? 5'd3  :
            (di_re[i][21:20] == 2'h3       &&  di_re[i][22]) ? 5'd2  :
            (di_re[i][21]    == 1'b1       &&  di_re[i][22]) ? 5'd1  :
                                                               5'd0;
        assign mag_cnt_im[i] =
            (di_im[i][21:0] == 22'h0 & ~di_im[i][22]) ? 5'd22 :
            (di_im[i][21:1] == 21'h0 & ~di_im[i][22]) ? 5'd21 :
            (di_im[i][21:2] == 20'h0 & ~di_im[i][22]) ? 5'd20 :
            (di_im[i][21:3] == 19'h0 & ~di_im[i][22]) ? 5'd19 :
            (di_im[i][21:4] == 18'h0 & ~di_im[i][22]) ? 5'd18 :
            (di_im[i][21:5] == 17'h0 & ~di_im[i][22]) ? 5'd17 :
            (di_im[i][21:6] == 16'h0 & ~di_im[i][22]) ? 5'd16 :
            (di_im[i][21:7] == 15'h0 & ~di_im[i][22]) ? 5'd15 :
            (di_im[i][21:8] == 14'h0 & ~di_im[i][22]) ? 5'd14 :
            (di_im[i][21:9] == 13'h0 & ~di_im[i][22]) ? 5'd13 :
            (di_im[i][21:10] == 12'h0 & ~di_im[i][22]) ? 5'd12 :
            (di_im[i][21:11] == 11'h0 & ~di_im[i][22]) ? 5'd11 :
            (di_im[i][21:12] == 10'h0 & ~di_im[i][22]) ? 5'd10 :
            (di_im[i][21:13] ==  9'h0 & ~di_im[i][22]) ? 5'd9  :
            (di_im[i][21:14] ==  8'h0 & ~di_im[i][22]) ? 5'd8  :
            (di_im[i][21:15] ==  7'h0 & ~di_im[i][22]) ? 5'd7  :
            (di_im[i][21:16] ==  6'h0 & ~di_im[i][22]) ? 5'd6  :
            (di_im[i][21:17] ==  5'h0 & ~di_im[i][22]) ? 5'd5  :
            (di_im[i][21:18] ==  4'h0 & ~di_im[i][22]) ? 5'd4  :
            (di_im[i][21:19] ==  3'h0 & ~di_im[i][22]) ? 5'd3  :
            (di_im[i][21:20] ==  2'h0 & ~di_im[i][22]) ? 5'd2  :
            (di_im[i][21]    ==  1'b0 & ~di_im[i][22]) ? 5'd1  :
            (di_im[i][21:0]  == 22'h3fffff &&  di_im[i][22]) ? 5'd22 :
            (di_im[i][21:1]  == 21'h1fffff &&  di_im[i][22]) ? 5'd21 :
            (di_im[i][21:2]  == 20'hfffff  &&  di_im[i][22]) ? 5'd20 :
            (di_im[i][21:3]  == 19'h7ffff  &&  di_im[i][22]) ? 5'd19 :
            (di_im[i][21:4]  == 18'h3ffff  &&  di_im[i][22]) ? 5'd18 :
            (di_im[i][21:5]  == 17'h1ffff  &&  di_im[i][22]) ? 5'd17 :
            (di_im[i][21:6]  == 16'hffff   &&  di_im[i][22]) ? 5'd16 :
            (di_im[i][21:7]  == 15'h7fff   &&  di_im[i][22]) ? 5'd15 :
            (di_im[i][21:8]  == 14'h3fff   &&  di_im[i][22]) ? 5'd14 :
            (di_im[i][21:9]  == 13'h1fff   &&  di_im[i][22]) ? 5'd13 :
            (di_im[i][21:10] == 12'hfff    &&  di_im[i][22]) ? 5'd12 :
            (di_im[i][21:11] == 11'h7ff    &&  di_im[i][22]) ? 5'd11 :
            (di_im[i][21:12] == 10'h3ff    &&  di_im[i][22]) ? 5'd10 :
            (di_im[i][21:13] == 9'h1ff     &&  di_im[i][22]) ? 5'd9  :
            (di_im[i][21:14] == 8'hff      &&  di_im[i][22]) ? 5'd8  :
            (di_im[i][21:15] == 7'h7f      &&  di_im[i][22]) ? 5'd7  :
            (di_im[i][21:16] == 6'h3f      &&  di_im[i][22]) ? 5'd6  :
            (di_im[i][21:17] == 5'h1f      &&  di_im[i][22]) ? 5'd5  :
            (di_im[i][21:18] == 4'hf       &&  di_im[i][22]) ? 5'd4  :
            (di_im[i][21:19] == 3'h7       &&  di_im[i][22]) ? 5'd3  :
            (di_im[i][21:20] == 2'h3       &&  di_im[i][22]) ? 5'd2  :
            (di_im[i][21]    == 1'b1       &&  di_im[i][22]) ? 5'd1  :
                                                               5'd0;
    end

genvar j;
    for (j = 0; j < 4; j = j + 1) begin
        comp_min_cbfp comp_re (
            .din  ({mag_cnt_re[j*4], mag_cnt_re[j*4+1], mag_cnt_re[j*4+2], mag_cnt_re[j*4+3]}),
            .dout (comp_do_re0[j])
        );
    end

    for (j = 0; j < 4; j = j + 1) begin
        comp_min_cbfp comp_im (
            .din  ({mag_cnt_im[j*4], mag_cnt_im[j*4+1], mag_cnt_im[j*4+2], mag_cnt_im[j*4+3]}),
            .dout (comp_do_im0[j])
        );
    end


// 16 to 1 최소값
comp_min_cbfp comp_re1 (
    .din  ({comp_do_re0[0], comp_do_re0[1], comp_do_re0[2], comp_do_re0[3]}),
    .dout (comp_do_re1)
);
comp_min_cbfp comp_im1 (
    .din  ({comp_do_im0[0], comp_do_im0[1], comp_do_im0[2], comp_do_im0[3]}),
    .dout (comp_do_im1)
);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        comp_min_cbfp_re0 <= 'h0;
        comp_min_cbfp_re1 <= 'h0;
        comp_min_cbfp_re2 <= 'h0;
        comp_min_cbfp_re3 <= 'h0;
    end else if (di_en & di_count[1:0] == 2'h0) begin
        comp_min_cbfp_re0 <= comp_do_re1;
    end else if (di_en & di_count[1:0] == 2'h1) begin
        comp_min_cbfp_re1 <= comp_do_re1;
    end else if (di_en & di_count[1:0] == 2'h2) begin
        comp_min_cbfp_re2 <= comp_do_re1;
    end else if (di_en & di_count[1:0] == 2'h3) begin
        comp_min_cbfp_re3 <= comp_do_re1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        comp_min_cbfp_im0 <= 'h0;
        comp_min_cbfp_im1 <= 'h0;
        comp_min_cbfp_im2 <= 'h0;
        comp_min_cbfp_im3 <= 'h0;
    end else if (di_en && di_count[1:0] == 2'h0) begin
        comp_min_cbfp_im0 <= comp_do_im1;
    end else if (di_en && di_count[1:0] == 2'h1) begin
        comp_min_cbfp_im1 <= comp_do_im1;
    end else if (di_en && di_count[1:0] == 2'h2) begin
        comp_min_cbfp_im2 <= comp_do_im1;
    end else if (di_en && di_count[1:0] == 2'h3) begin
        comp_min_cbfp_im3 <= comp_do_im1;
    end
end

// 4 to 1 comparator
comp_min_cbfp comp_re2 (
    .din  ({comp_min_cbfp_re0, comp_min_cbfp_re1, comp_min_cbfp_re2, comp_min_cbfp_re3}),
    .dout (comp_do_re2)
);
comp_min_cbfp comp_im2 (
    .din  ({comp_min_cbfp_im0, comp_min_cbfp_im1, comp_min_cbfp_im2, comp_min_cbfp_im3}),
    .dout (comp_do_im2)
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        cnt_valid <= 'h0;
    else
        cnt_valid <= (di_count[1:0] == 2'h3) ? 1'b1 : 1'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        min_value <= 'h0;
    else if (cnt_valid)
        min_value <= (comp_do_re2 <= comp_do_im2) ? comp_do_re2 : comp_do_im2;
end

logic [4:0] min_value_limited;
assign min_value_limited = (min_value > 16) ? 5'd16 : min_value;
logic [4:0] shift_num;

assign shift_num = (min_value_limited > 12) ? (min_value_limited - 12) : (12 - min_value_limited);


for (i=0; i<16; i=i+1) begin
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            shift_re[i] <= 'h0;
            shift_im[i] <= 'h0;
        end
        else if (shift_num > 5'd0) begin
            if (min_value > 5'd12) begin
                shift_re[i] <= (db_do_re[i] <<< shift_num);
                shift_im[i] <= (db_do_im[i] <<< shift_num);
            end
            else begin
                shift_re[i] <= (db_do_re[i] >>> shift_num);
                shift_im[i] <= (db_do_im[i] >>> shift_num);
            end
        end
    end

    assign do_re[i] = shift_re[i][WIDTH-12-1:0];
    assign do_im[i] = shift_im[i][WIDTH-12-1:0];

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            do_index[i] <= 'h0;
        end else begin
        do_index[i] <= min_value;
        end
    end
end

always_comb begin
    if (di_count == 5'd5)
        do_start = 1'b1;
    else
        do_start = 1'b0;

    if (do_count == 5'd31)
        do_end = 1'b1;
    else
        do_end = 1'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        do_en <= 'h0;
        do_count <= 'h0;
    end else begin
        do_en <= (do_start ? 1'b1 : (do_end ? 1'b0 : do_en));
        do_count <= do_en ? do_count + 1'b1 : 'h0;
    end
end
endmodule

module comp_min_cbfp (
    input  logic [4:0] din [0:3],
    output logic [4:0] dout
);
    always_comb begin
        dout = din[0];
        for (int i = 1; i < 4; i++) begin
            if (din[i] < dout)
                dout = din[i];
        end
    end
endmodule

