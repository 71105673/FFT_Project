`timescale 1ns/1ps

module twf64 (
    input clk,
    input rst,
    input valid,
    output logic signed [8:0] twf_r [0:15],
    output logic signed [8:0] twf_i [0:15]
);

    logic signed [8:0] twf_re [0:63];
    logic signed [8:0] twf_im [0:63];
    logic        [1:0]      cnt;

    always @ (posedge clk or negedge rst) begin
    if (~rst) begin
        cnt <= 0;
    end else begin
        if( valid )begin
            cnt <= (cnt == 3) ? 0 : cnt + 1;
            for (integer i = 0; i < 16; i++) begin
                twf_r[i] <= twf_re[ i + 16 * cnt];
                twf_i[i] <= twf_im[ i + 16 * cnt];
            end
        end
    end
end


assign twf_re[0] = 128; assign twf_im[0] = 0;
assign twf_re[1] = 128; assign twf_im[1] = 0;
assign twf_re[2] = 128; assign twf_im[2] = 0;
assign twf_re[3] = 128; assign twf_im[3] = 0;
assign twf_re[4] = 128; assign twf_im[4] = 0;
assign twf_re[5] = 128; assign twf_im[5] = 0;
assign twf_re[6] = 128; assign twf_im[6] = 0;
assign twf_re[7] = 128; assign twf_im[7] = 0;
assign twf_re[8] = 128; assign twf_im[8] = 0;
assign twf_re[9] = 118; assign twf_im[9] = -49;
assign twf_re[10] = 91; assign twf_im[10] = -91;
assign twf_re[11] = 49; assign twf_im[11] = -118;
assign twf_re[12] = 0; assign twf_im[12] = -128;
assign twf_re[13] = -49; assign twf_im[13] = -118;
assign twf_re[14] = -91; assign twf_im[14] = -91;
assign twf_re[15] = -118; assign twf_im[15] = -49;
assign twf_re[16] = 128; assign twf_im[16] = 0;
assign twf_re[17] = 126; assign twf_im[17] = -25;
assign twf_re[18] = 118; assign twf_im[18] = -49;
assign twf_re[19] = 106; assign twf_im[19] = -71;
assign twf_re[20] = 91; assign twf_im[20] = -91;
assign twf_re[21] = 71; assign twf_im[21] = -106;
assign twf_re[22] = 49; assign twf_im[22] = -118;
assign twf_re[23] = 25; assign twf_im[23] = -126;
assign twf_re[24] = 128; assign twf_im[24] = 0;
assign twf_re[25] = 106; assign twf_im[25] = -71;
assign twf_re[26] = 49; assign twf_im[26] = -118;
assign twf_re[27] = -25; assign twf_im[27] = -126;
assign twf_re[28] = -91; assign twf_im[28] = -91;
assign twf_re[29] = -126; assign twf_im[29] = -25;
assign twf_re[30] = -118; assign twf_im[30] = 49;
assign twf_re[31] = -71; assign twf_im[31] = 106;
assign twf_re[32] = 128; assign twf_im[32] = 0;
assign twf_re[33] = 127; assign twf_im[33] = -13;
assign twf_re[34] = 126; assign twf_im[34] = -25;
assign twf_re[35] = 122; assign twf_im[35] = -37;
assign twf_re[36] = 118; assign twf_im[36] = -49;
assign twf_re[37] = 113; assign twf_im[37] = -60;
assign twf_re[38] = 106; assign twf_im[38] = -71;
assign twf_re[39] = 99; assign twf_im[39] = -81;
assign twf_re[40] = 128; assign twf_im[40] = 0;
assign twf_re[41] = 113; assign twf_im[41] = -60;
assign twf_re[42] = 71; assign twf_im[42] = -106;
assign twf_re[43] = 13; assign twf_im[43] = -127;
assign twf_re[44] = -49; assign twf_im[44] = -118;
assign twf_re[45] = -99; assign twf_im[45] = -81;
assign twf_re[46] = -126; assign twf_im[46] = -25;
assign twf_re[47] = -122; assign twf_im[47] = 37;
assign twf_re[48] = 128; assign twf_im[48] = 0;
assign twf_re[49] = 122; assign twf_im[49] = -37;
assign twf_re[50] = 106; assign twf_im[50] = -71;
assign twf_re[51] = 81; assign twf_im[51] = -99;
assign twf_re[52] = 49; assign twf_im[52] = -118;
assign twf_re[53] = 13; assign twf_im[53] = -127;
assign twf_re[54] = -25; assign twf_im[54] = -126;
assign twf_re[55] = -60; assign twf_im[55] = -113;
assign twf_re[56] = 128; assign twf_im[56] = 0;
assign twf_re[57] = 99; assign twf_im[57] = -81;
assign twf_re[58] = 25; assign twf_im[58] = -126;
assign twf_re[59] = -60; assign twf_im[59] = -113;
assign twf_re[60] = -118; assign twf_im[60] = -49;
assign twf_re[61] = -122; assign twf_im[61] = 37;
assign twf_re[62] = -71; assign twf_im[62] = 106;
assign twf_re[63] = 13; assign twf_im[63] = 127;

endmodule
