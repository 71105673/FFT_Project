`timescale 1ns/1ps

module cos_gen(
    input clk,
    input rst,
    output logic valid,
    output logic signed [8:0] din_re [0:15],
    output logic signed [8:0] din_im [0:15]
);

    logic signed [8:0] cos_re [0:511];
    logic signed [8:0] cos_im [0:511];
    logic [4:0] cnt;
    logic [3:0] cnt1;

    integer j;

    always_ff @ (posedge clk or negedge rst ) begin
        if (~rst) begin
            for(j = 0; j < 16; j++) begin
                din_re[j] <= '0;
                din_im[j] <= '0;
            end
            cnt <= 0;
            cnt1 <= 0;
            valid <= 0;
        end else begin
            if (cnt1 ==0) begin
                cnt <= (cnt == 31) ? 0 : cnt + 1;
                cnt1 <= (cnt == 31) ? 1 : 0;

                case (cnt)
                    0: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[j];
                            din_im[j] <= cos_im[j];
                        end
                    end
                    1: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[16+j];
                            din_im[j] <= cos_im[16+j];
                        end
                    end 
                    2: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[32+j];
                            din_im[j] <= cos_im[32+j];
                        end
                    end
                    3: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[48+j];
                            din_im[j] <= cos_im[48+j];
                        end
                    end
                    4: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[64+j];
                            din_im[j] <= cos_im[64+j];
                        end
                    end
                    5: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[80+j];
                            din_im[j] <= cos_im[80+j];
                        end
                    end
                    6: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[96+j];
                            din_im[j] <= cos_im[96+j];
                        end
                    end
                    7: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[112+j];
                            din_im[j] <= cos_im[112+j];
                        end
                    end
                    8: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[128+j];
                            din_im[j] <= cos_im[128+j];
                        end
                    end
                    9: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[144+j];
                            din_im[j] <= cos_im[144+j];
                        end
                    end
                    10: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[160+j];
                            din_im[j] <= cos_im[160+j];
                        end
                    end
                    11: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[176+j];
                            din_im[j] <= cos_im[176+j];
                        end
                    end
                    12: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[192+j];
                            din_im[j] <= cos_im[192+j];
                        end
                    end
                    13: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[208+j];
                            din_im[j] <= cos_im[208+j];
                        end
                    end
                    14: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[224+j];
                            din_im[j] <= cos_im[224+j];
                        end
                    end
                    15: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[240+j];
                            din_im[j] <= cos_im[240+j];
                        end
                    end
                    16: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[256+j];
                            din_im[j] <= cos_im[256+j];
                        end
                    end
                    17: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[272+j];
                            din_im[j] <= cos_im[272+j];
                        end
                    end
                    18: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[288+j];
                            din_im[j] <= cos_im[288+j];
                        end
                    end
                    19: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[304+j];
                            din_im[j] <= cos_im[304+j];
                        end
                    end
                    20: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[320+j];
                            din_im[j] <= cos_im[320+j];
                        end
                    end
                    21: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[336+j];
                            din_im[j] <= cos_im[336+j];
                        end
                    end
                    22: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[352+j];
                            din_im[j] <= cos_im[352+j];
                        end
                    end
                    23: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[368+j];
                            din_im[j] <= cos_im[368+j];
                        end
                    end
                    24: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[384+j];
                            din_im[j] <= cos_im[384+j];
                        end
                    end
                    25: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[400+j];
                            din_im[j] <= cos_im[400+j];
                        end
                    end
                    26: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[416+j];
                            din_im[j] <= cos_im[416+j];
                        end
                    end
                    27: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[432+j];
                            din_im[j] <= cos_im[432+j];
                        end
                    end
                    28: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[448+j];
                            din_im[j] <= cos_im[448+j];
                        end
                    end
                    29: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[464+j];
                            din_im[j] <= cos_im[464+j];
                        end
                    end
                    30: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[480+j];
                            din_im[j] <= cos_im[480+j];
                        end
                    end
                    31: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= cos_re[496+j];
                            din_im[j] <= cos_im[496+j];
                        end
                    end

                    default: begin
                        for (j = 0; j < 16; j++) begin
                            din_re[j] <= '0;
                            din_im[j] <= '0;
                        end
                    end
                endcase
                valid <= 1;
            end else begin
                for(j = 0; j < 16; j++) begin
                    din_re[j] <= '0;
                    din_im[j] <= '0;
                end
		        valid <= 0;
                cnt1 <= cnt1 + 1;
                if (cnt1 == 8) begin
                    cnt1 <= 0;

                end
            end
        end
    end

    assign cos_re[0] = 63; assign cos_im[0] = 0;
    assign cos_re[1] = 64; assign cos_im[1] = 0;
    assign cos_re[2] = 64; assign cos_im[2] = 0;
    assign cos_re[3] = 64; assign cos_im[3] = 0;
    assign cos_re[4] = 64; assign cos_im[4] = 0;
    assign cos_re[5] = 64; assign cos_im[5] = 0;
    assign cos_re[6] = 64; assign cos_im[6] = 0;
    assign cos_re[7] = 64; assign cos_im[7] = 0;
    assign cos_re[8] = 64; assign cos_im[8] = 0;
    assign cos_re[9] = 64; assign cos_im[9] = 0;
    assign cos_re[10] = 64; assign cos_im[10] = 0;
    assign cos_re[11] = 63; assign cos_im[11] = 0;
    assign cos_re[12] = 63; assign cos_im[12] = 0;
    assign cos_re[13] = 63; assign cos_im[13] = 0;
    assign cos_re[14] = 63; assign cos_im[14] = 0;
    assign cos_re[15] = 63; assign cos_im[15] = 0;
    assign cos_re[16] = 63; assign cos_im[16] = 0;
    assign cos_re[17] = 63; assign cos_im[17] = 0;
    assign cos_re[18] = 62; assign cos_im[18] = 0;
    assign cos_re[19] = 62; assign cos_im[19] = 0;
    assign cos_re[20] = 62; assign cos_im[20] = 0;
    assign cos_re[21] = 62; assign cos_im[21] = 0;
    assign cos_re[22] = 62; assign cos_im[22] = 0;
    assign cos_re[23] = 61; assign cos_im[23] = 0;
    assign cos_re[24] = 61; assign cos_im[24] = 0;
    assign cos_re[25] = 61; assign cos_im[25] = 0;
    assign cos_re[26] = 61; assign cos_im[26] = 0;
    assign cos_re[27] = 61; assign cos_im[27] = 0;
    assign cos_re[28] = 60; assign cos_im[28] = 0;
    assign cos_re[29] = 60; assign cos_im[29] = 0;
    assign cos_re[30] = 60; assign cos_im[30] = 0;
    assign cos_re[31] = 59; assign cos_im[31] = 0;
    assign cos_re[32] = 59; assign cos_im[32] = 0;
    assign cos_re[33] = 59; assign cos_im[33] = 0;
    assign cos_re[34] = 59; assign cos_im[34] = 0;
    assign cos_re[35] = 58; assign cos_im[35] = 0;
    assign cos_re[36] = 58; assign cos_im[36] = 0;
    assign cos_re[37] = 58; assign cos_im[37] = 0;
    assign cos_re[38] = 57; assign cos_im[38] = 0;
    assign cos_re[39] = 57; assign cos_im[39] = 0;
    assign cos_re[40] = 56; assign cos_im[40] = 0;
    assign cos_re[41] = 56; assign cos_im[41] = 0;
    assign cos_re[42] = 56; assign cos_im[42] = 0;
    assign cos_re[43] = 55; assign cos_im[43] = 0;
    assign cos_re[44] = 55; assign cos_im[44] = 0;
    assign cos_re[45] = 54; assign cos_im[45] = 0;
    assign cos_re[46] = 54; assign cos_im[46] = 0;
    assign cos_re[47] = 54; assign cos_im[47] = 0;
    assign cos_re[48] = 53; assign cos_im[48] = 0;
    assign cos_re[49] = 53; assign cos_im[49] = 0;
    assign cos_re[50] = 52; assign cos_im[50] = 0;
    assign cos_re[51] = 52; assign cos_im[51] = 0;
    assign cos_re[52] = 51; assign cos_im[52] = 0;
    assign cos_re[53] = 51; assign cos_im[53] = 0;
    assign cos_re[54] = 50; assign cos_im[54] = 0;
    assign cos_re[55] = 50; assign cos_im[55] = 0;
    assign cos_re[56] = 49; assign cos_im[56] = 0;
    assign cos_re[57] = 49; assign cos_im[57] = 0;
    assign cos_re[58] = 48; assign cos_im[58] = 0;
    assign cos_re[59] = 48; assign cos_im[59] = 0;
    assign cos_re[60] = 47; assign cos_im[60] = 0;
    assign cos_re[61] = 47; assign cos_im[61] = 0;
    assign cos_re[62] = 46; assign cos_im[62] = 0;
    assign cos_re[63] = 46; assign cos_im[63] = 0;
    assign cos_re[64] = 45; assign cos_im[64] = 0;
    assign cos_re[65] = 45; assign cos_im[65] = 0;
    assign cos_re[66] = 44; assign cos_im[66] = 0;
    assign cos_re[67] = 44; assign cos_im[67] = 0;
    assign cos_re[68] = 43; assign cos_im[68] = 0;
    assign cos_re[69] = 42; assign cos_im[69] = 0;
    assign cos_re[70] = 42; assign cos_im[70] = 0;
    assign cos_re[71] = 41; assign cos_im[71] = 0;
    assign cos_re[72] = 41; assign cos_im[72] = 0;
    assign cos_re[73] = 40; assign cos_im[73] = 0;
    assign cos_re[74] = 39; assign cos_im[74] = 0;
    assign cos_re[75] = 39; assign cos_im[75] = 0;
    assign cos_re[76] = 38; assign cos_im[76] = 0;
    assign cos_re[77] = 37; assign cos_im[77] = 0;
    assign cos_re[78] = 37; assign cos_im[78] = 0;
    assign cos_re[79] = 36; assign cos_im[79] = 0;
    assign cos_re[80] = 36; assign cos_im[80] = 0;
    assign cos_re[81] = 35; assign cos_im[81] = 0;
    assign cos_re[82] = 34; assign cos_im[82] = 0;
    assign cos_re[83] = 34; assign cos_im[83] = 0;
    assign cos_re[84] = 33; assign cos_im[84] = 0;
    assign cos_re[85] = 32; assign cos_im[85] = 0;
    assign cos_re[86] = 32; assign cos_im[86] = 0;
    assign cos_re[87] = 31; assign cos_im[87] = 0;
    assign cos_re[88] = 30; assign cos_im[88] = 0;
    assign cos_re[89] = 29; assign cos_im[89] = 0;
    assign cos_re[90] = 29; assign cos_im[90] = 0;
    assign cos_re[91] = 28; assign cos_im[91] = 0;
    assign cos_re[92] = 27; assign cos_im[92] = 0;
    assign cos_re[93] = 27; assign cos_im[93] = 0;
    assign cos_re[94] = 26; assign cos_im[94] = 0;
    assign cos_re[95] = 25; assign cos_im[95] = 0;
    assign cos_re[96] = 24; assign cos_im[96] = 0;
    assign cos_re[97] = 24; assign cos_im[97] = 0;
    assign cos_re[98] = 23; assign cos_im[98] = 0;
    assign cos_re[99] = 22; assign cos_im[99] = 0;
    assign cos_re[100] = 22; assign cos_im[100] = 0;
    assign cos_re[101] = 21; assign cos_im[101] = 0;
    assign cos_re[102] = 20; assign cos_im[102] = 0;
    assign cos_re[103] = 19; assign cos_im[103] = 0;
    assign cos_re[104] = 19; assign cos_im[104] = 0;
    assign cos_re[105] = 18; assign cos_im[105] = 0;
    assign cos_re[106] = 17; assign cos_im[106] = 0;
    assign cos_re[107] = 16; assign cos_im[107] = 0;
    assign cos_re[108] = 16; assign cos_im[108] = 0;
    assign cos_re[109] = 15; assign cos_im[109] = 0;
    assign cos_re[110] = 14; assign cos_im[110] = 0;
    assign cos_re[111] = 13; assign cos_im[111] = 0;
    assign cos_re[112] = 12; assign cos_im[112] = 0;
    assign cos_re[113] = 12; assign cos_im[113] = 0;
    assign cos_re[114] = 11; assign cos_im[114] = 0;
    assign cos_re[115] = 10; assign cos_im[115] = 0;
    assign cos_re[116] = 9; assign cos_im[116] = 0;
    assign cos_re[117] = 9; assign cos_im[117] = 0;
    assign cos_re[118] = 8; assign cos_im[118] = 0;
    assign cos_re[119] = 7; assign cos_im[119] = 0;
    assign cos_re[120] = 6; assign cos_im[120] = 0;
    assign cos_re[121] = 5; assign cos_im[121] = 0;
    assign cos_re[122] = 5; assign cos_im[122] = 0;
    assign cos_re[123] = 4; assign cos_im[123] = 0;
    assign cos_re[124] = 3; assign cos_im[124] = 0;
    assign cos_re[125] = 2; assign cos_im[125] = 0;
    assign cos_re[126] = 2; assign cos_im[126] = 0;
    assign cos_re[127] = 1; assign cos_im[127] = 0;
    assign cos_re[128] = 0; assign cos_im[128] = 0;
    assign cos_re[129] = -1; assign cos_im[129] = 0;
    assign cos_re[130] = -2; assign cos_im[130] = 0;
    assign cos_re[131] = -2; assign cos_im[131] = 0;
    assign cos_re[132] = -3; assign cos_im[132] = 0;
    assign cos_re[133] = -4; assign cos_im[133] = 0;
    assign cos_re[134] = -5; assign cos_im[134] = 0;
    assign cos_re[135] = -5; assign cos_im[135] = 0;
    assign cos_re[136] = -6; assign cos_im[136] = 0;
    assign cos_re[137] = -7; assign cos_im[137] = 0;
    assign cos_re[138] = -8; assign cos_im[138] = 0;
    assign cos_re[139] = -9; assign cos_im[139] = 0;
    assign cos_re[140] = -9; assign cos_im[140] = 0;
    assign cos_re[141] = -10; assign cos_im[141] = 0;
    assign cos_re[142] = -11; assign cos_im[142] = 0;
    assign cos_re[143] = -12; assign cos_im[143] = 0;
    assign cos_re[144] = -12; assign cos_im[144] = 0;
    assign cos_re[145] = -13; assign cos_im[145] = 0;
    assign cos_re[146] = -14; assign cos_im[146] = 0;
    assign cos_re[147] = -15; assign cos_im[147] = 0;
    assign cos_re[148] = -16; assign cos_im[148] = 0;
    assign cos_re[149] = -16; assign cos_im[149] = 0;
    assign cos_re[150] = -17; assign cos_im[150] = 0;
    assign cos_re[151] = -18; assign cos_im[151] = 0;
    assign cos_re[152] = -19; assign cos_im[152] = 0;
    assign cos_re[153] = -19; assign cos_im[153] = 0;
    assign cos_re[154] = -20; assign cos_im[154] = 0;
    assign cos_re[155] = -21; assign cos_im[155] = 0;
    assign cos_re[156] = -22; assign cos_im[156] = 0;
    assign cos_re[157] = -22; assign cos_im[157] = 0;
    assign cos_re[158] = -23; assign cos_im[158] = 0;
    assign cos_re[159] = -24; assign cos_im[159] = 0;
    assign cos_re[160] = -24; assign cos_im[160] = 0;
    assign cos_re[161] = -25; assign cos_im[161] = 0;
    assign cos_re[162] = -26; assign cos_im[162] = 0;
    assign cos_re[163] = -27; assign cos_im[163] = 0;
    assign cos_re[164] = -27; assign cos_im[164] = 0;
    assign cos_re[165] = -28; assign cos_im[165] = 0;
    assign cos_re[166] = -29; assign cos_im[166] = 0;
    assign cos_re[167] = -29; assign cos_im[167] = 0;
    assign cos_re[168] = -30; assign cos_im[168] = 0;
    assign cos_re[169] = -31; assign cos_im[169] = 0;
    assign cos_re[170] = -32; assign cos_im[170] = 0;
    assign cos_re[171] = -32; assign cos_im[171] = 0;
    assign cos_re[172] = -33; assign cos_im[172] = 0;
    assign cos_re[173] = -34; assign cos_im[173] = 0;
    assign cos_re[174] = -34; assign cos_im[174] = 0;
    assign cos_re[175] = -35; assign cos_im[175] = 0;
    assign cos_re[176] = -36; assign cos_im[176] = 0;
    assign cos_re[177] = -36; assign cos_im[177] = 0;
    assign cos_re[178] = -37; assign cos_im[178] = 0;
    assign cos_re[179] = -37; assign cos_im[179] = 0;
    assign cos_re[180] = -38; assign cos_im[180] = 0;
    assign cos_re[181] = -39; assign cos_im[181] = 0;
    assign cos_re[182] = -39; assign cos_im[182] = 0;
    assign cos_re[183] = -40; assign cos_im[183] = 0;
    assign cos_re[184] = -41; assign cos_im[184] = 0;
    assign cos_re[185] = -41; assign cos_im[185] = 0;
    assign cos_re[186] = -42; assign cos_im[186] = 0;
    assign cos_re[187] = -42; assign cos_im[187] = 0;
    assign cos_re[188] = -43; assign cos_im[188] = 0;
    assign cos_re[189] = -44; assign cos_im[189] = 0;
    assign cos_re[190] = -44; assign cos_im[190] = 0;
    assign cos_re[191] = -45; assign cos_im[191] = 0;
    assign cos_re[192] = -45; assign cos_im[192] = 0;
    assign cos_re[193] = -46; assign cos_im[193] = 0;
    assign cos_re[194] = -46; assign cos_im[194] = 0;
    assign cos_re[195] = -47; assign cos_im[195] = 0;
    assign cos_re[196] = -47; assign cos_im[196] = 0;
    assign cos_re[197] = -48; assign cos_im[197] = 0;
    assign cos_re[198] = -48; assign cos_im[198] = 0;
    assign cos_re[199] = -49; assign cos_im[199] = 0;
    assign cos_re[200] = -49; assign cos_im[200] = 0;
    assign cos_re[201] = -50; assign cos_im[201] = 0;
    assign cos_re[202] = -50; assign cos_im[202] = 0;
    assign cos_re[203] = -51; assign cos_im[203] = 0;
    assign cos_re[204] = -51; assign cos_im[204] = 0;
    assign cos_re[205] = -52; assign cos_im[205] = 0;
    assign cos_re[206] = -52; assign cos_im[206] = 0;
    assign cos_re[207] = -53; assign cos_im[207] = 0;
    assign cos_re[208] = -53; assign cos_im[208] = 0;
    assign cos_re[209] = -54; assign cos_im[209] = 0;
    assign cos_re[210] = -54; assign cos_im[210] = 0;
    assign cos_re[211] = -54; assign cos_im[211] = 0;
    assign cos_re[212] = -55; assign cos_im[212] = 0;
    assign cos_re[213] = -55; assign cos_im[213] = 0;
    assign cos_re[214] = -56; assign cos_im[214] = 0;
    assign cos_re[215] = -56; assign cos_im[215] = 0;
    assign cos_re[216] = -56; assign cos_im[216] = 0;
    assign cos_re[217] = -57; assign cos_im[217] = 0;
    assign cos_re[218] = -57; assign cos_im[218] = 0;
    assign cos_re[219] = -58; assign cos_im[219] = 0;
    assign cos_re[220] = -58; assign cos_im[220] = 0;
    assign cos_re[221] = -58; assign cos_im[221] = 0;
    assign cos_re[222] = -59; assign cos_im[222] = 0;
    assign cos_re[223] = -59; assign cos_im[223] = 0;
    assign cos_re[224] = -59; assign cos_im[224] = 0;
    assign cos_re[225] = -59; assign cos_im[225] = 0;
    assign cos_re[226] = -60; assign cos_im[226] = 0;
    assign cos_re[227] = -60; assign cos_im[227] = 0;
    assign cos_re[228] = -60; assign cos_im[228] = 0;
    assign cos_re[229] = -61; assign cos_im[229] = 0;
    assign cos_re[230] = -61; assign cos_im[230] = 0;
    assign cos_re[231] = -61; assign cos_im[231] = 0;
    assign cos_re[232] = -61; assign cos_im[232] = 0;
    assign cos_re[233] = -61; assign cos_im[233] = 0;
    assign cos_re[234] = -62; assign cos_im[234] = 0;
    assign cos_re[235] = -62; assign cos_im[235] = 0;
    assign cos_re[236] = -62; assign cos_im[236] = 0;
    assign cos_re[237] = -62; assign cos_im[237] = 0;
    assign cos_re[238] = -62; assign cos_im[238] = 0;
    assign cos_re[239] = -63; assign cos_im[239] = 0;
    assign cos_re[240] = -63; assign cos_im[240] = 0;
    assign cos_re[241] = -63; assign cos_im[241] = 0;
    assign cos_re[242] = -63; assign cos_im[242] = 0;
    assign cos_re[243] = -63; assign cos_im[243] = 0;
    assign cos_re[244] = -63; assign cos_im[244] = 0;
    assign cos_re[245] = -63; assign cos_im[245] = 0;
    assign cos_re[246] = -64; assign cos_im[246] = 0;
    assign cos_re[247] = -64; assign cos_im[247] = 0;
    assign cos_re[248] = -64; assign cos_im[248] = 0;
    assign cos_re[249] = -64; assign cos_im[249] = 0;
    assign cos_re[250] = -64; assign cos_im[250] = 0;
    assign cos_re[251] = -64; assign cos_im[251] = 0;
    assign cos_re[252] = -64; assign cos_im[252] = 0;
    assign cos_re[253] = -64; assign cos_im[253] = 0;
    assign cos_re[254] = -64; assign cos_im[254] = 0;
    assign cos_re[255] = -64; assign cos_im[255] = 0;
    assign cos_re[256] = -64; assign cos_im[256] = 0;
    assign cos_re[257] = -64; assign cos_im[257] = 0;
    assign cos_re[258] = -64; assign cos_im[258] = 0;
    assign cos_re[259] = -64; assign cos_im[259] = 0;
    assign cos_re[260] = -64; assign cos_im[260] = 0;
    assign cos_re[261] = -64; assign cos_im[261] = 0;
    assign cos_re[262] = -64; assign cos_im[262] = 0;
    assign cos_re[263] = -64; assign cos_im[263] = 0;
    assign cos_re[264] = -64; assign cos_im[264] = 0;
    assign cos_re[265] = -64; assign cos_im[265] = 0;
    assign cos_re[266] = -64; assign cos_im[266] = 0;
    assign cos_re[267] = -63; assign cos_im[267] = 0;
    assign cos_re[268] = -63; assign cos_im[268] = 0;
    assign cos_re[269] = -63; assign cos_im[269] = 0;
    assign cos_re[270] = -63; assign cos_im[270] = 0;
    assign cos_re[271] = -63; assign cos_im[271] = 0;
    assign cos_re[272] = -63; assign cos_im[272] = 0;
    assign cos_re[273] = -63; assign cos_im[273] = 0;
    assign cos_re[274] = -62; assign cos_im[274] = 0;
    assign cos_re[275] = -62; assign cos_im[275] = 0;
    assign cos_re[276] = -62; assign cos_im[276] = 0;
    assign cos_re[277] = -62; assign cos_im[277] = 0;
    assign cos_re[278] = -62; assign cos_im[278] = 0;
    assign cos_re[279] = -61; assign cos_im[279] = 0;
    assign cos_re[280] = -61; assign cos_im[280] = 0;
    assign cos_re[281] = -61; assign cos_im[281] = 0;
    assign cos_re[282] = -61; assign cos_im[282] = 0;
    assign cos_re[283] = -61; assign cos_im[283] = 0;
    assign cos_re[284] = -60; assign cos_im[284] = 0;
    assign cos_re[285] = -60; assign cos_im[285] = 0;
    assign cos_re[286] = -60; assign cos_im[286] = 0;
    assign cos_re[287] = -59; assign cos_im[287] = 0;
    assign cos_re[288] = -59; assign cos_im[288] = 0;
    assign cos_re[289] = -59; assign cos_im[289] = 0;
    assign cos_re[290] = -59; assign cos_im[290] = 0;
    assign cos_re[291] = -58; assign cos_im[291] = 0;
    assign cos_re[292] = -58; assign cos_im[292] = 0;
    assign cos_re[293] = -58; assign cos_im[293] = 0;
    assign cos_re[294] = -57; assign cos_im[294] = 0;
    assign cos_re[295] = -57; assign cos_im[295] = 0;
    assign cos_re[296] = -56; assign cos_im[296] = 0;
    assign cos_re[297] = -56; assign cos_im[297] = 0;
    assign cos_re[298] = -56; assign cos_im[298] = 0;
    assign cos_re[299] = -55; assign cos_im[299] = 0;
    assign cos_re[300] = -55; assign cos_im[300] = 0;
    assign cos_re[301] = -54; assign cos_im[301] = 0;
    assign cos_re[302] = -54; assign cos_im[302] = 0;
    assign cos_re[303] = -54; assign cos_im[303] = 0;
    assign cos_re[304] = -53; assign cos_im[304] = 0;
    assign cos_re[305] = -53; assign cos_im[305] = 0;
    assign cos_re[306] = -52; assign cos_im[306] = 0;
    assign cos_re[307] = -52; assign cos_im[307] = 0;
    assign cos_re[308] = -51; assign cos_im[308] = 0;
    assign cos_re[309] = -51; assign cos_im[309] = 0;
    assign cos_re[310] = -50; assign cos_im[310] = 0;
    assign cos_re[311] = -50; assign cos_im[311] = 0;
    assign cos_re[312] = -49; assign cos_im[312] = 0;
    assign cos_re[313] = -49; assign cos_im[313] = 0;
    assign cos_re[314] = -48; assign cos_im[314] = 0;
    assign cos_re[315] = -48; assign cos_im[315] = 0;
    assign cos_re[316] = -47; assign cos_im[316] = 0;
    assign cos_re[317] = -47; assign cos_im[317] = 0;
    assign cos_re[318] = -46; assign cos_im[318] = 0;
    assign cos_re[319] = -46; assign cos_im[319] = 0;
    assign cos_re[320] = -45; assign cos_im[320] = 0;
    assign cos_re[321] = -45; assign cos_im[321] = 0;
    assign cos_re[322] = -44; assign cos_im[322] = 0;
    assign cos_re[323] = -44; assign cos_im[323] = 0;
    assign cos_re[324] = -43; assign cos_im[324] = 0;
    assign cos_re[325] = -42; assign cos_im[325] = 0;
    assign cos_re[326] = -42; assign cos_im[326] = 0;
    assign cos_re[327] = -41; assign cos_im[327] = 0;
    assign cos_re[328] = -41; assign cos_im[328] = 0;
    assign cos_re[329] = -40; assign cos_im[329] = 0;
    assign cos_re[330] = -39; assign cos_im[330] = 0;
    assign cos_re[331] = -39; assign cos_im[331] = 0;
    assign cos_re[332] = -38; assign cos_im[332] = 0;
    assign cos_re[333] = -37; assign cos_im[333] = 0;
    assign cos_re[334] = -37; assign cos_im[334] = 0;
    assign cos_re[335] = -36; assign cos_im[335] = 0;
    assign cos_re[336] = -36; assign cos_im[336] = 0;
    assign cos_re[337] = -35; assign cos_im[337] = 0;
    assign cos_re[338] = -34; assign cos_im[338] = 0;
    assign cos_re[339] = -34; assign cos_im[339] = 0;
    assign cos_re[340] = -33; assign cos_im[340] = 0;
    assign cos_re[341] = -32; assign cos_im[341] = 0;
    assign cos_re[342] = -32; assign cos_im[342] = 0;
    assign cos_re[343] = -31; assign cos_im[343] = 0;
    assign cos_re[344] = -30; assign cos_im[344] = 0;
    assign cos_re[345] = -29; assign cos_im[345] = 0;
    assign cos_re[346] = -29; assign cos_im[346] = 0;
    assign cos_re[347] = -28; assign cos_im[347] = 0;
    assign cos_re[348] = -27; assign cos_im[348] = 0;
    assign cos_re[349] = -27; assign cos_im[349] = 0;
    assign cos_re[350] = -26; assign cos_im[350] = 0;
    assign cos_re[351] = -25; assign cos_im[351] = 0;
    assign cos_re[352] = -24; assign cos_im[352] = 0;
    assign cos_re[353] = -24; assign cos_im[353] = 0;
    assign cos_re[354] = -23; assign cos_im[354] = 0;
    assign cos_re[355] = -22; assign cos_im[355] = 0;
    assign cos_re[356] = -22; assign cos_im[356] = 0;
    assign cos_re[357] = -21; assign cos_im[357] = 0;
    assign cos_re[358] = -20; assign cos_im[358] = 0;
    assign cos_re[359] = -19; assign cos_im[359] = 0;
    assign cos_re[360] = -19; assign cos_im[360] = 0;
    assign cos_re[361] = -18; assign cos_im[361] = 0;
    assign cos_re[362] = -17; assign cos_im[362] = 0;
    assign cos_re[363] = -16; assign cos_im[363] = 0;
    assign cos_re[364] = -16; assign cos_im[364] = 0;
    assign cos_re[365] = -15; assign cos_im[365] = 0;
    assign cos_re[366] = -14; assign cos_im[366] = 0;
    assign cos_re[367] = -13; assign cos_im[367] = 0;
    assign cos_re[368] = -12; assign cos_im[368] = 0;
    assign cos_re[369] = -12; assign cos_im[369] = 0;
    assign cos_re[370] = -11; assign cos_im[370] = 0;
    assign cos_re[371] = -10; assign cos_im[371] = 0;
    assign cos_re[372] = -9; assign cos_im[372] = 0;
    assign cos_re[373] = -9; assign cos_im[373] = 0;
    assign cos_re[374] = -8; assign cos_im[374] = 0;
    assign cos_re[375] = -7; assign cos_im[375] = 0;
    assign cos_re[376] = -6; assign cos_im[376] = 0;
    assign cos_re[377] = -5; assign cos_im[377] = 0;
    assign cos_re[378] = -5; assign cos_im[378] = 0;
    assign cos_re[379] = -4; assign cos_im[379] = 0;
    assign cos_re[380] = -3; assign cos_im[380] = 0;
    assign cos_re[381] = -2; assign cos_im[381] = 0;
    assign cos_re[382] = -2; assign cos_im[382] = 0;
    assign cos_re[383] = -1; assign cos_im[383] = 0;
    assign cos_re[384] = 0; assign cos_im[384] = 0;
    assign cos_re[385] = 1; assign cos_im[385] = 0;
    assign cos_re[386] = 2; assign cos_im[386] = 0;
    assign cos_re[387] = 2; assign cos_im[387] = 0;
    assign cos_re[388] = 3; assign cos_im[388] = 0;
    assign cos_re[389] = 4; assign cos_im[389] = 0;
    assign cos_re[390] = 5; assign cos_im[390] = 0;
    assign cos_re[391] = 5; assign cos_im[391] = 0;
    assign cos_re[392] = 6; assign cos_im[392] = 0;
    assign cos_re[393] = 7; assign cos_im[393] = 0;
    assign cos_re[394] = 8; assign cos_im[394] = 0;
    assign cos_re[395] = 9; assign cos_im[395] = 0;
    assign cos_re[396] = 9; assign cos_im[396] = 0;
    assign cos_re[397] = 10; assign cos_im[397] = 0;
    assign cos_re[398] = 11; assign cos_im[398] = 0;
    assign cos_re[399] = 12; assign cos_im[399] = 0;
    assign cos_re[400] = 12; assign cos_im[400] = 0;
    assign cos_re[401] = 13; assign cos_im[401] = 0;
    assign cos_re[402] = 14; assign cos_im[402] = 0;
    assign cos_re[403] = 15; assign cos_im[403] = 0;
    assign cos_re[404] = 16; assign cos_im[404] = 0;
    assign cos_re[405] = 16; assign cos_im[405] = 0;
    assign cos_re[406] = 17; assign cos_im[406] = 0;
    assign cos_re[407] = 18; assign cos_im[407] = 0;
    assign cos_re[408] = 19; assign cos_im[408] = 0;
    assign cos_re[409] = 19; assign cos_im[409] = 0;
    assign cos_re[410] = 20; assign cos_im[410] = 0;
    assign cos_re[411] = 21; assign cos_im[411] = 0;
    assign cos_re[412] = 22; assign cos_im[412] = 0;
    assign cos_re[413] = 22; assign cos_im[413] = 0;
    assign cos_re[414] = 23; assign cos_im[414] = 0;
    assign cos_re[415] = 24; assign cos_im[415] = 0;
    assign cos_re[416] = 24; assign cos_im[416] = 0;
    assign cos_re[417] = 25; assign cos_im[417] = 0;
    assign cos_re[418] = 26; assign cos_im[418] = 0;
    assign cos_re[419] = 27; assign cos_im[419] = 0;
    assign cos_re[420] = 27; assign cos_im[420] = 0;
    assign cos_re[421] = 28; assign cos_im[421] = 0;
    assign cos_re[422] = 29; assign cos_im[422] = 0;
    assign cos_re[423] = 29; assign cos_im[423] = 0;
    assign cos_re[424] = 30; assign cos_im[424] = 0;
    assign cos_re[425] = 31; assign cos_im[425] = 0;
    assign cos_re[426] = 32; assign cos_im[426] = 0;
    assign cos_re[427] = 32; assign cos_im[427] = 0;
    assign cos_re[428] = 33; assign cos_im[428] = 0;
    assign cos_re[429] = 34; assign cos_im[429] = 0;
    assign cos_re[430] = 34; assign cos_im[430] = 0;
    assign cos_re[431] = 35; assign cos_im[431] = 0;
    assign cos_re[432] = 36; assign cos_im[432] = 0;
    assign cos_re[433] = 36; assign cos_im[433] = 0;
    assign cos_re[434] = 37; assign cos_im[434] = 0;
    assign cos_re[435] = 37; assign cos_im[435] = 0;
    assign cos_re[436] = 38; assign cos_im[436] = 0;
    assign cos_re[437] = 39; assign cos_im[437] = 0;
    assign cos_re[438] = 39; assign cos_im[438] = 0;
    assign cos_re[439] = 40; assign cos_im[439] = 0;
    assign cos_re[440] = 41; assign cos_im[440] = 0;
    assign cos_re[441] = 41; assign cos_im[441] = 0;
    assign cos_re[442] = 42; assign cos_im[442] = 0;
    assign cos_re[443] = 42; assign cos_im[443] = 0;
    assign cos_re[444] = 43; assign cos_im[444] = 0;
    assign cos_re[445] = 44; assign cos_im[445] = 0;
    assign cos_re[446] = 44; assign cos_im[446] = 0;
    assign cos_re[447] = 45; assign cos_im[447] = 0;
    assign cos_re[448] = 45; assign cos_im[448] = 0;
    assign cos_re[449] = 46; assign cos_im[449] = 0;
    assign cos_re[450] = 46; assign cos_im[450] = 0;
    assign cos_re[451] = 47; assign cos_im[451] = 0;
    assign cos_re[452] = 47; assign cos_im[452] = 0;
    assign cos_re[453] = 48; assign cos_im[453] = 0;
    assign cos_re[454] = 48; assign cos_im[454] = 0;
    assign cos_re[455] = 49; assign cos_im[455] = 0;
    assign cos_re[456] = 49; assign cos_im[456] = 0;
    assign cos_re[457] = 50; assign cos_im[457] = 0;
    assign cos_re[458] = 50; assign cos_im[458] = 0;
    assign cos_re[459] = 51; assign cos_im[459] = 0;
    assign cos_re[460] = 51; assign cos_im[460] = 0;
    assign cos_re[461] = 52; assign cos_im[461] = 0;
    assign cos_re[462] = 52; assign cos_im[462] = 0;
    assign cos_re[463] = 53; assign cos_im[463] = 0;
    assign cos_re[464] = 53; assign cos_im[464] = 0;
    assign cos_re[465] = 54; assign cos_im[465] = 0;
    assign cos_re[466] = 54; assign cos_im[466] = 0;
    assign cos_re[467] = 54; assign cos_im[467] = 0;
    assign cos_re[468] = 55; assign cos_im[468] = 0;
    assign cos_re[469] = 55; assign cos_im[469] = 0;
    assign cos_re[470] = 56; assign cos_im[470] = 0;
    assign cos_re[471] = 56; assign cos_im[471] = 0;
    assign cos_re[472] = 56; assign cos_im[472] = 0;
    assign cos_re[473] = 57; assign cos_im[473] = 0;
    assign cos_re[474] = 57; assign cos_im[474] = 0;
    assign cos_re[475] = 58; assign cos_im[475] = 0;
    assign cos_re[476] = 58; assign cos_im[476] = 0;
    assign cos_re[477] = 58; assign cos_im[477] = 0;
    assign cos_re[478] = 59; assign cos_im[478] = 0;
    assign cos_re[479] = 59; assign cos_im[479] = 0;
    assign cos_re[480] = 59; assign cos_im[480] = 0;
    assign cos_re[481] = 59; assign cos_im[481] = 0;
    assign cos_re[482] = 60; assign cos_im[482] = 0;
    assign cos_re[483] = 60; assign cos_im[483] = 0;
    assign cos_re[484] = 60; assign cos_im[484] = 0;
    assign cos_re[485] = 61; assign cos_im[485] = 0;
    assign cos_re[486] = 61; assign cos_im[486] = 0;
    assign cos_re[487] = 61; assign cos_im[487] = 0;
    assign cos_re[488] = 61; assign cos_im[488] = 0;
    assign cos_re[489] = 61; assign cos_im[489] = 0;
    assign cos_re[490] = 62; assign cos_im[490] = 0;
    assign cos_re[491] = 62; assign cos_im[491] = 0;
    assign cos_re[492] = 62; assign cos_im[492] = 0;
    assign cos_re[493] = 62; assign cos_im[493] = 0;
    assign cos_re[494] = 62; assign cos_im[494] = 0;
    assign cos_re[495] = 63; assign cos_im[495] = 0;
    assign cos_re[496] = 63; assign cos_im[496] = 0;
    assign cos_re[497] = 63; assign cos_im[497] = 0;
    assign cos_re[498] = 63; assign cos_im[498] = 0;
    assign cos_re[499] = 63; assign cos_im[499] = 0;
    assign cos_re[500] = 63; assign cos_im[500] = 0;
    assign cos_re[501] = 63; assign cos_im[501] = 0;
    assign cos_re[502] = 64; assign cos_im[502] = 0;
    assign cos_re[503] = 64; assign cos_im[503] = 0;
    assign cos_re[504] = 64; assign cos_im[504] = 0;
    assign cos_re[505] = 64; assign cos_im[505] = 0;
    assign cos_re[506] = 64; assign cos_im[506] = 0;
    assign cos_re[507] = 64; assign cos_im[507] = 0;
    assign cos_re[508] = 64; assign cos_im[508] = 0;
    assign cos_re[509] = 64; assign cos_im[509] = 0;
    assign cos_re[510] = 64; assign cos_im[510] = 0;
    assign cos_re[511] = 64; assign cos_im[511] = 0;


endmodule

