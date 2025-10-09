function automatic logic [4:0] count_min_lzc_23bit(input logic signed [22:0] din [0:15]);
    logic [4:0] lzc [0:15];
    logic [4:0] min_val = 24;
    
    integer i;
    
    for (i = 0; i < 16; i++) begin
        lzc[i] =(din[i][21:0]  == 22'd0 && din[i][22] == 1'b0) ? 22 :
                (din[i][21:1]  == 21'd0 && din[i][22] == 1'b0) ? 21 :
                (din[i][21:2]  == 20'd0 && din[i][22] == 1'b0) ? 20 :
                (din[i][21:3]  == 19'd0 && din[i][22] == 1'b0) ? 19 :
                (din[i][21:4]  == 18'd0 && din[i][22] == 1'b0) ? 18 :
                (din[i][21:5]  == 17'd0 && din[i][22] == 1'b0) ? 17 :
                (din[i][21:6]  == 16'd0 && din[i][22] == 1'b0) ? 16 :
                (din[i][21:7]  == 15'd0 && din[i][22] == 1'b0) ? 15 :
                (din[i][21:8]  == 14'd0 && din[i][22] == 1'b0) ? 14 :
                (din[i][21:9]  == 13'd0 && din[i][22] == 1'b0) ? 13 :
                (din[i][21:10] == 12'd0 && din[i][22] == 1'b0) ? 12 :
                (din[i][21:11] == 11'd0 && din[i][22] == 1'b0) ? 11 :
                (din[i][21:12] == 10'd0 && din[i][22] == 1'b0) ? 10 :
                (din[i][21:13] == 9'd0  && din[i][22] == 1'b0) ? 9  :
                (din[i][21:14] == 8'd0  && din[i][22] == 1'b0) ? 8  :
                (din[i][21:15] == 7'd0  && din[i][22] == 1'b0) ? 7  :
                (din[i][21:16] == 6'd0  && din[i][22] == 1'b0) ? 6  :
                (din[i][21:17] == 5'd0  && din[i][22] == 1'b0) ? 5  :
                (din[i][21:18] == 4'd0  && din[i][22] == 1'b0) ? 4  :
                (din[i][21:19] == 3'd0  && din[i][22] == 1'b0) ? 3  :
                (din[i][21:20] == 2'd0  && din[i][22] == 1'b0) ? 2  :
                (din[i][21]    == 1'b0  && din[i][22] == 1'b0) ? 1  : 
                (din[i][21:0]  == 22'h3FFFFF && din[i][22] ) ? 22 :
                (din[i][21:1]  == 21'h1FFFFF && din[i][22]) ? 21 :
                (din[i][21:2]  == 20'hFFFFF  && din[i][22] ) ? 20 :
                (din[i][21:3]  == 19'h7FFFF  && din[i][22] ) ? 19 :
                (din[i][21:4]  == 18'h3FFFF  && din[i][22]) ? 18 :
                (din[i][21:5]  == 17'h1FFFF  && din[i][22] ) ? 17 :
                (din[i][21:6]  == 16'hFFFF   && din[i][22] ) ? 16 :
                (din[i][21:7]  == 15'h7FFF   && din[i][22] ) ? 15 :
                (din[i][21:8]  == 14'h3FFF   && din[i][22] ) ? 14 :
                (din[i][21:9]  == 13'h1FFF   && din[i][22] ) ? 13 :
                (din[i][21:10] == 12'hFFF    && din[i][22] ) ? 12 :
                (din[i][21:11] == 11'h7FF    && din[i][22] ) ? 11 :
                (din[i][21:12] == 10'h3FF    && din[i][22]) ? 10 :
                (din[i][21:13] ==  9'h1FF    && din[i][22] ) ? 9  :
                (din[i][21:14] ==  8'hFF     && din[i][22] ) ? 8  :
                (din[i][21:15] ==  7'h7F     && din[i][22] ) ? 7  :
                (din[i][21:16] ==  6'h3F     && din[i][22] ) ? 6  :
                (din[i][21:17] ==  5'h1F     && din[i][22] ) ? 5  :
                (din[i][21:18] ==  4'hF      && din[i][22] ) ? 4  :
                (din[i][21:19] ==  3'h7      && din[i][22] ) ? 3  :
                (din[i][21:20] ==  2'h3      && din[i][22] ) ? 2  :
                (din[i][21]    ==  1'b1      && din[i][22] ) ? 1  : 0;

        if (lzc[i] < min_val)
            min_val = lzc[i];
    end

    return min_val;
endfunction

function automatic logic [4:0] count_min_lzc_26bit(input logic signed [24:0] din [0:15]);
    logic  [4:0] lzc [0:15];
    logic  [4:0] min_val = 25;

    integer i;

    for (i = 0; i < 16; i++) begin
        lzc[i] =(din[i][23:0]  == 24'd0 && din[i][24] == 1'b0) ? 24 :
                (din[i][23:1]  == 23'd0 && din[i][24] == 1'b0) ? 23 :
                (din[i][23:2]  == 22'd0 && din[i][24] == 1'b0) ? 22 :
                (din[i][23:3]  == 21'd0 && din[i][24] == 1'b0) ? 21 :
                (din[i][23:4]  == 20'd0 && din[i][24] == 1'b0) ? 20 :
                (din[i][23:5]  == 19'd0 && din[i][24] == 1'b0) ? 19 :
                (din[i][23:6]  == 18'd0 && din[i][24] == 1'b0) ? 18 :
                (din[i][23:7]  == 17'd0 && din[i][24] == 1'b0) ? 17 :
                (din[i][23:8]  == 16'd0 && din[i][24] == 1'b0) ? 16 :
                (din[i][23:9]  == 15'd0 && din[i][24] == 1'b0) ? 15 :
                (din[i][23:10] == 14'd0 && din[i][24] == 1'b0) ? 14 :
                (din[i][23:11] == 13'd0 && din[i][24] == 1'b0) ? 13 :
                (din[i][23:12] == 12'd0 && din[i][24] == 1'b0) ? 12 :
                (din[i][23:13] == 11'd0  && din[i][24] == 1'b0) ? 11  :
                (din[i][23:14] == 10'd0  && din[i][24] == 1'b0) ? 10  :
                (din[i][23:15] == 9'd0  && din[i][24] == 1'b0) ? 9  :
                (din[i][23:16] == 8'd0  && din[i][24] == 1'b0) ? 8  :
                (din[i][23:17] == 7'd0  && din[i][24] == 1'b0) ? 7  :
                (din[i][23:18] == 6'd0  && din[i][24] == 1'b0) ? 6  :
                (din[i][23:19] == 5'd0  && din[i][24] == 1'b0) ? 5  :
                (din[i][23:20] == 4'd0  && din[i][24] == 1'b0) ? 4  :
                (din[i][23:21] == 3'd0  && din[i][24] == 1'b0) ? 3  :
                (din[i][23:22] == 2'd0  && din[i][24] == 1'b0) ? 2  :
                (din[i][23:23] == 1'b0  && din[i][24] == 1'b0) ? 1  :
                (din[i][23:0]  == 24'hFFFFFF && din[i][24] ) ? 24 :
                (din[i][23:1]  == 23'h7FFFFF  && din[i][24] ) ? 23 :
                (din[i][23:2]  == 22'h3FFFFF  && din[i][24] ) ? 22 :
                (din[i][23:3]  == 21'h1FFFFF  && din[i][24] ) ? 21 :
                (din[i][23:4]  == 20'hFFFFF  && din[i][24] ) ? 20 :
                (din[i][23:5]  == 19'h7FFFF   && din[i][24] ) ? 19 :
                (din[i][23:6]  == 18'h3FFFF   && din[i][24] ) ? 18 :
                (din[i][23:7]  == 17'h1FFFF   && din[i][24] ) ? 17 :
                (din[i][23:8]  == 16'hFFFF   && din[i][24] ) ? 16 :
                (din[i][23:9]  == 15'h7FFF    && din[i][24] ) ? 15 :
                (din[i][23:10] == 14'h3FFF    && din[i][24] ) ? 14 :
                (din[i][23:11] == 13'h1FFF    && din[i][24] ) ? 13 :
                (din[i][23:12] == 12'hFFF    && din[i][24] ) ? 12 :
                (din[i][23:13] == 11'h7FF     && din[i][24] ) ? 11 :
                (din[i][23:14] == 10'h3FF     && din[i][24] ) ? 10 :
                (din[i][23:15] == 9'h1FF     && din[i][24] ) ? 9 :
                (din[i][23:16] == 8'hFF      && din[i][24] ) ? 8  :
                (din[i][23:17] == 7'h7F       && din[i][24] ) ? 7  :
                (din[i][23:18] == 6'h3F       && din[i][24] ) ? 6  :
                (din[i][23:19] == 5'h1F       && din[i][24] ) ? 5  :
                (din[i][23:20] == 4'hF       && din[i][24] ) ? 4 :
                (din[i][23:21] == 3'h7        && din[i][24] ) ? 3 :
                (din[i][23:22] == 2'h3        && din[i][24] ) ? 2 :
                (din[i][23] == 1'b1        && din[i][24] ) ? 1 : 0;

            if (lzc[i] < min_val)
                min_val = lzc[i];
        end

        return min_val;
endfunction

function automatic signed [20:0] mul181(input signed [10:0] x);
        return (x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x;
    endfunction

function automatic signed [20:0] mul_neg181(input signed [10:0] x);
    return -((x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x);
endfunction

function automatic signed [21:0] m1_mul181(input signed [12:0] x);
    return (x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x;
endfunction

function automatic signed [21:0] m1_mul_neg181(input signed [12:0] x);
    return -((x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x);
endfunction

function automatic signed [22:0] mul2_181(input signed [13:0] x);
    return (x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x;
endfunction

function automatic signed [22:0] mul2_neg181(input signed [13:0] x);
    return -((x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x);
endfunction

function automatic logic bitget(input logic [8:0] val, input int k);
    if (k >= 1 && k <= 9)
        return val[k - 1];
    else
        return 1'b0; 
endfunction


