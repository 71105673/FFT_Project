module sdf3 #(
    parameter N = 512,
    parameter M = 512,
    parameter WIDTH = 12,
    parameter WIDTH_DO = 13
)(
    input clk,
    input rstn,
    input fft_mode,

    input di_en,
    input signed [WIDTH-1:0] di_re[0:15],
    input signed [WIDTH-1:0] di_im[0:15],
    input [5:0] di_index[0:15],

    output logic do_en,
    output signed [WIDTH_DO-1:0] do_re[0:15],
    output signed [WIDTH_DO-1:0] do_im[0:15]
);

// log2 function
function integer log2;
    input integer x;
    integer value;
    begin
        value = (x/16)-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

localparam LOG_N = log2(N);  // Bit Length of N
localparam LOG_M = log2(M);  // Bit Length of M

// 1st bf
logic signed [WIDTH-1:0] bf1_x0_re[0:3];
logic signed [WIDTH-1:0] bf1_x0_im[0:3];
logic signed [WIDTH-1:0] bf1_x1_re[0:3];
logic signed [WIDTH-1:0] bf1_x1_im[0:3];
logic signed [WIDTH-1:0] bf1_x2_re[0:3];
logic signed [WIDTH-1:0] bf1_x2_im[0:3];
logic signed [WIDTH-1:0] bf1_x3_re[0:3];
logic signed [WIDTH-1:0] bf1_x3_im[0:3];

logic signed [WIDTH:0]   bf1_y0_re[0:15]; 
logic signed [WIDTH:0]   bf1_y0_im[0:15];
logic signed [WIDTH:0]   bf1_sp_re[0:15]; // Single Path Data Output
logic signed [WIDTH:0]   bf1_sp_im[0:15];
logic                    bf1_sp_en;
logic signed [WIDTH:0]   bf1_do_re[0:15]; // 1st bf Output
logic signed [WIDTH:0]   bf1_do_im[0:15];
logic                    bf1_do_en;


// 2nd bf
logic signed [WIDTH+1:0]   bf2_y0_re[0:15];
logic signed [WIDTH+1:0]   bf2_y0_im[0:15]; 
logic signed [WIDTH+2:0]   bf2_sp_re[0:15];
logic signed [WIDTH+2:0]   bf2_sp_im[0:15]; 
logic                    bf2_sp_en;     
logic signed [WIDTH+2:0]   bf2_do_re[0:15]; // 2nd bf Output
logic signed [WIDTH+2:0]   bf2_do_im[0:15];
logic                    bf2_do_en;

// 3rd bf
logic signed [WIDTH+3:0]   bf3_y0_re[0:15];
logic signed [WIDTH+3:0]   bf3_y0_im[0:15]; 
logic signed [WIDTH+3:0]   bf3_sp_re[0:15];
logic signed [WIDTH+3:0]   bf3_sp_im[0:15]; 
logic                    bf3_sp_en;     
logic signed [WIDTH+3:0]   bf3_do_re[0:15]; // 3rd bf Output
logic signed [WIDTH+3:0]   bf3_do_im[0:15];
logic                    bf3_do_en;

logic signed [WIDTH+1:0]  bf2_multi_i[0:3];
logic signed [WIDTH+1:0]  bf2_multi_q[0:3];
logic signed [WIDTH+10:0] bf2_multi_re[0:3];
logic signed [WIDTH+10:0] bf2_multi_im[0:3];
logic signed [WIDTH+10:0] bf2_re_cal[0:3];
logic signed [WIDTH+10:0] bf2_im_cal[0:3];
logic signed [WIDTH+2:0]  bf2_re_round[0:3];
logic signed [WIDTH+2:0]  bf2_im_round[0:3];

// CBFP
logic signed [15:0] shift_re[0:15];
logic signed [15:0] shift_im[0:15];
logic [5:0] shift_num[0:15];


// bf1
genvar i;
for (i=0; i<4; i=i+1) begin
    assign bf1_x0_re[i] = di_re[i];
    assign bf1_x0_im[i] = di_im[i];
    assign bf1_x1_re[i] = di_re[i+4];
    assign bf1_x1_im[i] = di_im[i+4];
    assign bf1_x2_re[i] = di_re[i+8];
    assign bf1_x2_im[i] = di_im[i+8];
    assign bf1_x3_re[i] = di_re[i+12];
    assign bf1_x3_im[i] = di_im[i+12];

    assign bf1_y0_re[i]     = bf1_x0_re[i] + bf1_x1_re[i];
    assign bf1_y0_im[i]     = bf1_x0_im[i] + bf1_x1_im[i];
    assign bf1_y0_re[i+4]   = bf1_x0_re[i] - bf1_x1_re[i];
    assign bf1_y0_im[i+4]   = bf1_x0_im[i] - bf1_x1_im[i];
    assign bf1_y0_re[i+8]   = bf1_x2_re[i] + bf1_x3_re[i];
    assign bf1_y0_im[i+8]   = bf1_x2_im[i] + bf1_x3_im[i];
    assign bf1_y0_re[i+12]  = bf1_x2_re[i] - bf1_x3_re[i];
    assign bf1_y0_im[i+12]  = bf1_x2_im[i] - bf1_x3_im[i];
end

for (i=0; i<16; i=i+1) begin
    assign bf1_sp_re[i] = (i[2:1] == 2'b11) ? bf1_y0_im[i] : bf1_y0_re[i];
    assign bf1_sp_im[i] = (i[2:1] == 2'b11) ? -bf1_y0_re[i] : bf1_y0_im[i];
end

assign bf1_sp_en = di_en;

always @(posedge clk) begin
    bf1_do_re <= bf1_sp_re;
    bf1_do_im <= bf1_sp_im;
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) bf1_do_en <= 1'b0;
    else bf1_do_en <= bf1_sp_en;
end

// bf2
for (i=0; i<4; i=i+1) begin
    always_ff @(posedge clk) begin
        bf2_y0_re[i*4]   <= bf1_do_re[i*4]   + bf1_do_re[i*4+2];
        bf2_y0_im[i*4]   <= bf1_do_im[i*4]   + bf1_do_im[i*4+2];
        bf2_y0_re[i*4+1] <= bf1_do_re[i*4+1] + bf1_do_re[i*4+3];
        bf2_y0_im[i*4+1] <= bf1_do_im[i*4+1] + bf1_do_im[i*4+3];
        bf2_y0_re[i*4+2] <= bf1_do_re[i*4]   - bf1_do_re[i*4+2];
        bf2_y0_im[i*4+2] <= bf1_do_im[i*4]   - bf1_do_im[i*4+2];
        bf2_y0_re[i*4+3] <= bf1_do_re[i*4+1] - bf1_do_re[i*4+3];
        bf2_y0_im[i*4+3] <= bf1_do_im[i*4+1] - bf1_do_im[i*4+3];
    end
end

assign bf2_multi_i[0] = bf2_y0_re[5];
assign bf2_multi_i[1] = bf2_y0_re[7];
assign bf2_multi_i[2] = bf2_y0_re[13];
assign bf2_multi_i[3] = bf2_y0_re[15];
assign bf2_multi_q[0] = bf2_y0_im[5];
assign bf2_multi_q[1] = bf2_y0_im[7];
assign bf2_multi_q[2] = bf2_y0_im[13];
assign bf2_multi_q[3] = bf2_y0_im[15];

//generate begin: gen_bf1_mul
//genvar i, j;
for (i = 0; i < 4; i = i + 1) begin
    assign bf2_multi_re[i] = ((bf2_multi_i[i] << 7) + (bf2_multi_i[i] << 5) + (bf2_multi_i[i] << 4) +
                              (bf2_multi_i[i] << 2) + bf2_multi_i[i]);
    assign bf2_multi_im[i] = ((bf2_multi_q[i] << 7) + (bf2_multi_q[i] << 5) + (bf2_multi_q[i] << 4) +
                              (bf2_multi_q[i] << 2) + bf2_multi_q[i]);

    assign bf2_re_cal[i] = (i[0]) ? -bf2_multi_re[i] + bf2_multi_im[i] : bf2_multi_re[i] + bf2_multi_im[i];
    assign bf2_im_cal[i] = (i[0]) ? -bf2_multi_im[i] - bf2_multi_re[i] : -bf2_multi_re[i] + bf2_multi_im[i];
    
    // always_comb begin
    //     for (int i = 0; i < 16; i++) begin
    //         automatic logic signed [22:0] re_tmp, im_tmp;

    //         re_tmp = bf2_re_cal[i] + 14'd256;
    //         im_tmp = bf2_im_cal[i] + 14'd256;

    //         bf2_re_round[i] = re_tmp[22:9];
    //         bf2_im_round[i] = im_tmp[22:9];
    //     end
    // end

    divide_round #(.WIDTH(WIDTH+11), .DIVIDE(8)) divide_round_re (
        .din  (bf2_re_cal[i]),
        .dout (bf2_re_round[i])
    );

    divide_round #(.WIDTH(WIDTH+11), .DIVIDE(8)) divide_round_im (
        .din  (bf2_im_cal[i]),
        .dout (bf2_im_round[i])
    );
end

for (i = 0; i < 16; i = i + 1) begin
    assign bf2_sp_re[i] = (i == 4'd3)  | (i == 4'd11) ? bf2_y0_im[i] :
                          (i == 4'd5)  ? bf2_re_round[0] :
                          (i == 4'd7)  ? bf2_re_round[1] :
                          (i == 4'd13) ? bf2_re_round[2] :
                          (i == 4'd15) ? bf2_re_round[3] : bf2_y0_re[i];

    assign bf2_sp_im[i] = (i == 4'd3)  | (i == 4'd11) ? -bf2_y0_re[i] :
                          (i == 4'd5)  ? bf2_im_round[0] :
                          (i == 4'd7)  ? bf2_im_round[1] :
                          (i == 4'd13) ? bf2_im_round[2] :
                          (i == 4'd15) ? bf2_im_round[3] : bf2_y0_im[i];
end

always @(posedge clk) begin
    bf2_sp_en <= bf1_do_en;
    bf2_do_re <= bf2_sp_re;
    bf2_do_im <= bf2_sp_im;
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        bf2_do_en <= 1'b0;
    end else begin
        bf2_do_en <= bf2_sp_en;
    end
end

// bf3
for (i=0; i<8; i=i+1) begin
    always_ff @(posedge clk) begin
        bf3_y0_re[i*2]   <= bf2_do_re[i*2] + bf2_do_re[i*2+1];
        bf3_y0_re[i*2+1] <= bf2_do_re[i*2] - bf2_do_re[i*2+1];
        bf3_y0_im[i*2]   <= bf2_do_im[i*2] + bf2_do_im[i*2+1];
        bf3_y0_im[i*2+1] <= bf2_do_im[i*2] - bf2_do_im[i*2+1];
    end
end

for (i=0; i<16; i=i+1) begin
    assign bf3_sp_re[i] = bf3_y0_re[i];
    assign bf3_sp_im[i] = bf3_y0_im[i];
end

always @(posedge clk) begin
    bf3_sp_en <= bf2_do_en;
    bf3_do_re <= bf3_sp_re;
    bf3_do_im <= bf3_sp_im;
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        bf3_do_en <= 1'b0;
    end else begin
        bf3_do_en <= bf3_sp_en;
    end
end

logic [5:0] db_do_index[0:15];
delaybuffer_re #(.DEPTH(80), .WIDTH(6)) db3 (
    .rstn       (rstn),
    .clk        (clk),
    .di_re      (di_index),
    .do_re      (db_do_index )
);

for (i=0; i<16; i=i+1) begin
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            shift_re[i] <= 'h0;
            shift_im[i] <= 'h0;
        end
        else if (db_do_index[i] >= 6'd23) begin
            shift_re[i] <= 'h0;
            shift_im[i] <= 'h0;
        end
        else if (shift_num[i] > 6'd0) begin
            shift_re[i] <= (bf3_do_re[i] >>> shift_num[i]);
            shift_im[i] <= (bf3_do_im[i] >>> shift_num[i]);
        end
    end

    assign shift_num[i] = (fft_mode & (db_do_index[i] > 6'd9)) ? db_do_index[i] - 6'd9 :
                         (~fft_mode & (db_do_index[i] > 6'd6)) ? db_do_index[i] - 6'd6 : 6'd0;
    assign do_re[i] = shift_re[i][WIDTH_DO-1:0];
    assign do_im[i] = shift_im[i][WIDTH_DO-1:0];
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        do_en <= 1'b0;
    end else begin
        do_en <= bf3_do_en;
    end
end

endmodule


module divide_round #(
    parameter WIDTH = 23,  
    parameter DIVIDE = 8  
) (
    input logic signed [WIDTH-1:0] din, 
    output logic signed [WIDTH-1-DIVIDE:0] dout 
);

    localparam integer ADD_VALUE = 128;
    logic signed [WIDTH-1:0] added_val; 

    assign added_val = din + ADD_VALUE;
    assign dout = added_val[WIDTH-1 : DIVIDE];

endmodule