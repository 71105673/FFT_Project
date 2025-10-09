`timescale 1ns/1ps


module index_sum (
    input clk,
    input rst,
    input valid,
    input tx_start,

    input [4:0] cbfp0_index[0:7], // 8clk 동안 1개씩 전달 -> 8개
    input [4:0] cbfp1_index[0:1], // 32clk 동안 2개씩 전달 -> 64개

    output logic unsigned [5:0] cbfp_min_var [0:1]
);

    integer j;
    logic [4:0] cnt;
    logic [4:0] tx_cnt;
    logic index_flag;
    logic [5:0] cbfp_indexsum [0:63];
    

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (j = 0; j < 2; j++) begin
                cbfp_min_var[j] <= '0;
            end
            for (j=0; j<64; j++) begin
                cbfp_indexsum[j] <= '0;
            end
            cnt <= 0;
            tx_cnt <= 0;
        end else begin
            if (valid) begin
                if(cnt == 31) begin
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end

                case (cnt)
                    0: begin
                        cbfp_indexsum[0] <= cbfp0_index[0] + cbfp1_index[0];
                        cbfp_indexsum[1] <= cbfp0_index[0] + cbfp1_index[1];
                    end
                    1: begin
                        cbfp_indexsum[2] <= cbfp0_index[0] + cbfp1_index[0];
                        cbfp_indexsum[3] <= cbfp0_index[0] + cbfp1_index[1];
                    end
                    2: begin
                        cbfp_indexsum[4] <= cbfp0_index[0] + cbfp1_index[0];
                        cbfp_indexsum[5] <= cbfp0_index[0] + cbfp1_index[1];
                    end
                    3: begin
                        cbfp_indexsum[6] <= cbfp0_index[0] + cbfp1_index[0];
                        cbfp_indexsum[7] <= cbfp0_index[0] + cbfp1_index[1];
                    end
                    4: begin
                        cbfp_indexsum[8] <= cbfp0_index[1] + cbfp1_index[0];
                        cbfp_indexsum[9] <= cbfp0_index[1] + cbfp1_index[1];
                    end
                    5: begin
                        cbfp_indexsum[10] <= cbfp0_index[1] + cbfp1_index[0];
                        cbfp_indexsum[11] <= cbfp0_index[1] + cbfp1_index[1];
                    end
                    6: begin
                        cbfp_indexsum[12] <= cbfp0_index[1] + cbfp1_index[0];
                        cbfp_indexsum[13] <= cbfp0_index[1] + cbfp1_index[1];
                    end
                    7: begin
                        cbfp_indexsum[14] <= cbfp0_index[1] + cbfp1_index[0];
                        cbfp_indexsum[15] <= cbfp0_index[1] + cbfp1_index[1];
                    end
                    8: begin
                        cbfp_indexsum[16] <= cbfp0_index[2] + cbfp1_index[0];
                        cbfp_indexsum[17] <= cbfp0_index[2] + cbfp1_index[1];
                    end
                    9: begin
                        cbfp_indexsum[18] <= cbfp0_index[2] + cbfp1_index[0];
                        cbfp_indexsum[19] <= cbfp0_index[2] + cbfp1_index[1];
                    end 
                    10: begin
                        cbfp_indexsum[20] <= cbfp0_index[2] + cbfp1_index[0];
                        cbfp_indexsum[21] <= cbfp0_index[2] + cbfp1_index[1];
                    end 
                    11: begin
                        cbfp_indexsum[22] <= cbfp0_index[2] + cbfp1_index[0];
                        cbfp_indexsum[23] <= cbfp0_index[2] + cbfp1_index[1];
                    end 
                    12: begin
                        cbfp_indexsum[24] <= cbfp0_index[3] + cbfp1_index[0];
                        cbfp_indexsum[25] <= cbfp0_index[3] + cbfp1_index[1];
                    end
                    13: begin
                        cbfp_indexsum[26] <= cbfp0_index[3] + cbfp1_index[0];
                        cbfp_indexsum[27] <= cbfp0_index[3] + cbfp1_index[1];
                    end
                    14: begin
                        cbfp_indexsum[28] <= cbfp0_index[3] + cbfp1_index[0];
                        cbfp_indexsum[29] <= cbfp0_index[3] + cbfp1_index[1];
                    end
                    15: begin
                        cbfp_indexsum[30] <= cbfp0_index[3] + cbfp1_index[0];
                        cbfp_indexsum[31] <= cbfp0_index[3] + cbfp1_index[1];
                    end
                    
                    16: begin
                        cbfp_indexsum[32] <= cbfp0_index[4] + cbfp1_index[0];
                        cbfp_indexsum[33] <= cbfp0_index[4] + cbfp1_index[1];
                    end
                    17: begin
                        cbfp_indexsum[34] <= cbfp0_index[4] + cbfp1_index[0];
                        cbfp_indexsum[35] <= cbfp0_index[4] + cbfp1_index[1];
                    end
                    18: begin
                        cbfp_indexsum[36] <= cbfp0_index[4] + cbfp1_index[0];
                        cbfp_indexsum[37] <= cbfp0_index[4] + cbfp1_index[1];
                    end
                    19: begin
                        cbfp_indexsum[38] <= cbfp0_index[4] + cbfp1_index[0];
                        cbfp_indexsum[39] <= cbfp0_index[4] + cbfp1_index[1];
                    end

                    20: begin
                        cbfp_indexsum[40] <= cbfp0_index[5] + cbfp1_index[0];
                        cbfp_indexsum[41] <= cbfp0_index[5] + cbfp1_index[1];
                    end
                    21: begin
                        cbfp_indexsum[42] <= cbfp0_index[5] + cbfp1_index[0];
                        cbfp_indexsum[43] <= cbfp0_index[5] + cbfp1_index[1];
                    end
                    22: begin
                        cbfp_indexsum[44] <= cbfp0_index[5] + cbfp1_index[0];
                        cbfp_indexsum[45] <= cbfp0_index[5] + cbfp1_index[1];
                    end
                    23: begin
                        cbfp_indexsum[46] <= cbfp0_index[5] + cbfp1_index[0];
                        cbfp_indexsum[47] <= cbfp0_index[5] + cbfp1_index[1];
                    end
                    24: begin
                        cbfp_indexsum[48] <= cbfp0_index[6] + cbfp1_index[0];
                        cbfp_indexsum[49] <= cbfp0_index[6] + cbfp1_index[1];
                    end
                    25: begin
                        cbfp_indexsum[50] <= cbfp0_index[6] + cbfp1_index[0];
                        cbfp_indexsum[51] <= cbfp0_index[6] + cbfp1_index[1];
                    end
                    26: begin
                        cbfp_indexsum[52] <= cbfp0_index[6] + cbfp1_index[0];
                        cbfp_indexsum[53] <= cbfp0_index[6] + cbfp1_index[1];
                    end
                    27: begin
                        cbfp_indexsum[54] <= cbfp0_index[6] + cbfp1_index[0];
                        cbfp_indexsum[55] <= cbfp0_index[6] + cbfp1_index[1];
                    end
                    28: begin
                        cbfp_indexsum[56] <= cbfp0_index[7] + cbfp1_index[0];
                        cbfp_indexsum[57] <= cbfp0_index[7] + cbfp1_index[1];
                    end
                    29: begin
                        cbfp_indexsum[58] <= cbfp0_index[7] + cbfp1_index[0];
                        cbfp_indexsum[59] <= cbfp0_index[7] + cbfp1_index[1];
                    end
                    30: begin
                        cbfp_indexsum[60] <= cbfp0_index[7] + cbfp1_index[0];
                        cbfp_indexsum[61] <= cbfp0_index[7] + cbfp1_index[1];
                    end
                    31: begin
                        cbfp_indexsum[62] <= cbfp0_index[7] + cbfp1_index[0];
                        cbfp_indexsum[63] <= cbfp0_index[7] + cbfp1_index[1];
                    end
                    default: begin
                    end
                endcase
            end else begin
                cnt <= 0;
            end

            if(tx_start) begin
                if(tx_cnt == 31) begin
                    tx_cnt <= 0;
                end else begin
                    tx_cnt <= tx_cnt + 1;
                end

                /*cbfp_min_var[0] <= cbfp_indexsum[tx_cnt * 2];
                cbfp_min_var[1] <= cbfp_indexsum[tx_cnt * 2 + 1];*/

                 case (tx_cnt)
                    0: begin
                        cbfp_min_var[0] <= cbfp_indexsum[0];
                        cbfp_min_var[1] <= cbfp_indexsum[1];
                    end
                    1: begin
                        cbfp_min_var[0] <= cbfp_indexsum[2];
                        cbfp_min_var[1] <= cbfp_indexsum[3];
                    end
                    2: begin
                        cbfp_min_var[0] <= cbfp_indexsum[4];
                        cbfp_min_var[1] <= cbfp_indexsum[5];
                    end
                    3: begin
                        cbfp_min_var[0] <= cbfp_indexsum[6];
                        cbfp_min_var[1] <= cbfp_indexsum[7];
                    end
                    4: begin
                        cbfp_min_var[0] <= cbfp_indexsum[8];
                        cbfp_min_var[1] <= cbfp_indexsum[9];
                    end
                    5: begin
                        cbfp_min_var[0] <= cbfp_indexsum[10];
                        cbfp_min_var[1] <= cbfp_indexsum[11];
                    end
                    6: begin
                        cbfp_min_var[0] <= cbfp_indexsum[12];
                        cbfp_min_var[1] <= cbfp_indexsum[13];
                    end
                    7: begin
                        cbfp_min_var[0] <= cbfp_indexsum[14];
                        cbfp_min_var[1] <= cbfp_indexsum[15];
                    end
                    8: begin
                        cbfp_min_var[0] <= cbfp_indexsum[16];
                        cbfp_min_var[1] <= cbfp_indexsum[17];
                    end
                    9: begin
                        cbfp_min_var[0] <= cbfp_indexsum[18];
                        cbfp_min_var[1] <= cbfp_indexsum[19];
                    end
                    10: begin
                        cbfp_min_var[0] <= cbfp_indexsum[20];
                        cbfp_min_var[1] <= cbfp_indexsum[21];
                    end
                    11: begin
                        cbfp_min_var[0] <= cbfp_indexsum[22];
                        cbfp_min_var[1] <= cbfp_indexsum[23];
                    end
                    12: begin
                        cbfp_min_var[0] <= cbfp_indexsum[24];
                        cbfp_min_var[1] <= cbfp_indexsum[25];
                    end
                    13: begin
                        cbfp_min_var[0] <= cbfp_indexsum[26];
                        cbfp_min_var[1] <= cbfp_indexsum[27];
                    end
                    14: begin
                        cbfp_min_var[0] <= cbfp_indexsum[28];
                        cbfp_min_var[1] <= cbfp_indexsum[29];
                    end
                    15: begin
                        cbfp_min_var[0] <= cbfp_indexsum[30];
                        cbfp_min_var[1] <= cbfp_indexsum[31];
                    end
                    16: begin
                        cbfp_min_var[0] <= cbfp_indexsum[32];
                        cbfp_min_var[1] <= cbfp_indexsum[33];
                    end
                    17: begin
                        cbfp_min_var[0] <= cbfp_indexsum[34];
                        cbfp_min_var[1] <= cbfp_indexsum[35];
                    end
                    18: begin
                        cbfp_min_var[0] <= cbfp_indexsum[36];
                        cbfp_min_var[1] <= cbfp_indexsum[37];
                    end
                    19: begin
                        cbfp_min_var[0] <= cbfp_indexsum[38];
                        cbfp_min_var[1] <= cbfp_indexsum[39];
                    end
                    20: begin
                        cbfp_min_var[0] <= cbfp_indexsum[40];
                        cbfp_min_var[1] <= cbfp_indexsum[41];
                    end
                    21: begin
                        cbfp_min_var[0] <= cbfp_indexsum[42];
                        cbfp_min_var[1] <= cbfp_indexsum[43];
                    end
                    22: begin
                        cbfp_min_var[0] <= cbfp_indexsum[44];
                        cbfp_min_var[1] <= cbfp_indexsum[45];
                    end
                    23: begin
                        cbfp_min_var[0] <= cbfp_indexsum[46];
                        cbfp_min_var[1] <= cbfp_indexsum[47];
                    end
                    24: begin
                        cbfp_min_var[0] <= cbfp_indexsum[48];
                        cbfp_min_var[1] <= cbfp_indexsum[49];
                    end
                    25: begin
                        cbfp_min_var[0] <= cbfp_indexsum[50];
                        cbfp_min_var[1] <= cbfp_indexsum[51];
                    end
                    26: begin
                        cbfp_min_var[0] <= cbfp_indexsum[52];
                        cbfp_min_var[1] <= cbfp_indexsum[53];
                    end
                    27: begin
                        cbfp_min_var[0] <= cbfp_indexsum[54];
                        cbfp_min_var[1] <= cbfp_indexsum[55];
                    end
                    28: begin
                        cbfp_min_var[0] <= cbfp_indexsum[56];
                        cbfp_min_var[1] <= cbfp_indexsum[57];
                    end
                    29: begin
                        cbfp_min_var[0] <= cbfp_indexsum[58];
                        cbfp_min_var[1] <= cbfp_indexsum[59];
                    end
                    30: begin
                        cbfp_min_var[0] <= cbfp_indexsum[60];
                        cbfp_min_var[1] <= cbfp_indexsum[61];
                    end
                    31: begin
                        cbfp_min_var[0] <= cbfp_indexsum[62];
                        cbfp_min_var[1] <= cbfp_indexsum[63];
                    end

                    default: begin
                    end
                endcase
            end else begin
                tx_cnt <= 0;
            end
        end
    end
endmodule

module step2_0 (
    input clk,
    input rst,
    input valid,

    input logic signed [11:0] din_re [0:15],
    input logic signed [11:0] din_im [0:15],

    output logic signed [12:0] bfly20_re [0:15],
    output logic signed [12:0] bfly20_im [0:15],
    output logic step20_mul_enable
);
    
    integer j;

    logic signed [12:0] add_sub_step20_re [0:15];
    logic signed [12:0] add_sub_step20_im [0:15];

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            for(j = 0; j < 16; j++) begin
                add_sub_step20_re[j] <= '0;
                add_sub_step20_im[j] <= '0;
                bfly20_re[j] <= '0;
                bfly20_im[j] <= '0;
            end
            
            step20_mul_enable <= 0;
            
        end else begin
        
            step20_mul_enable <= valid;

            if(valid) begin
                for(j = 0; j < 8; j++) begin
                    if(j < 4) begin
                        add_sub_step20_re[j] <= din_re[j] + din_re[j + 4];
                        add_sub_step20_im[j] <= din_im[j] + din_im[j + 4];
                        add_sub_step20_re[j + 4] <= din_re[j] - din_re[j + 4];
                        add_sub_step20_im[j + 4] <= din_im[j] - din_im[j + 4];
                    end else begin
                        add_sub_step20_re[j + 4] <= din_re[j + 4] + din_re[j + 8];
                        add_sub_step20_im[j + 4] <= din_im[j + 4] + din_im[j + 8];
                        add_sub_step20_re[j + 8] <= din_re[j + 4] - din_re[j + 8];
                        add_sub_step20_im[j + 8] <= din_im[j + 4] - din_im[j + 8];
                    end
                end
            end

            if(step20_mul_enable) begin
                for(j = 0; j < 16; j++) begin
                    case (j)
                        0, 1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 13: begin
                            bfly20_re[j] <= add_sub_step20_re[j];
                            bfly20_im[j] <= add_sub_step20_im[j]; 
                        end

                        6, 7, 14, 15 : begin
                            bfly20_re[j] <= add_sub_step20_im[j];
                            bfly20_im[j] <= -add_sub_step20_re[j];
                        end
                        default: begin 
                                bfly20_re[j] <= '0;
                                bfly20_im[j] <= '0;
                        end
                    endcase
                end
            end
        end
    end

endmodule


module step2_1(
    input clk,
    input rst,
    input valid,

    input logic signed [12:0] bfly20_re [0:15],
    input logic signed [12:0] bfly20_im [0:15],

    output logic signed [14:0] bfly21_re [0:15],
    output logic signed [14:0] bfly21_im [0:15],
    output logic step21_mul_enable
);

    integer i;

    logic signed [13:0] add_sub_step21_re [0:15];
    logic signed [13:0] add_sub_step21_im [0:15];

    logic step21_add_sub_enable;

    function automatic signed [22:0] mul2_181(input signed [13:0] x);
        return (x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x;
    endfunction

    function automatic signed [22:0] mul2_neg181(input signed [13:0] x);
        return -((x <<< 7) + (x <<< 5) + (x <<< 4) + (x <<< 2) + x);
    endfunction

    always_ff @(posedge clk or negedge rst ) begin
        if(~rst) begin
            step21_add_sub_enable <= 0;
            step21_mul_enable <= 0;

            for(i = 0; i < 16; i++) begin
                add_sub_step21_re[i] <= '0;
                add_sub_step21_im[i] <= '0;
                bfly21_re[i] <= '0;
                bfly21_im[i] <= '0;
            end
        end else begin

            step21_add_sub_enable <= valid;
            step21_mul_enable <= step21_add_sub_enable;

            if (step21_add_sub_enable) begin
                for(i = 0; i < 4; i++) begin                   
                    add_sub_step21_re[i * 4] <= bfly20_re[i * 4] + bfly20_re[i * 4 + 2];                        
                    add_sub_step21_re[i * 4 + 1] <= bfly20_re[i * 4 + 1] + bfly20_re[i * 4 + 3];                     
                    add_sub_step21_re[i * 4 + 2] <= bfly20_re[i * 4] - bfly20_re[i * 4 + 2];                     
                    add_sub_step21_re[i * 4 + 3] <= bfly20_re[i * 4 + 1] - bfly20_re[i * 4 + 3];

                    add_sub_step21_im[i * 4] <= bfly20_im[i * 4] + bfly20_im[i * 4 + 2];
                    add_sub_step21_im[i * 4 + 1] <= bfly20_im[i * 4 + 1] + bfly20_im[i * 4 + 3];
                    add_sub_step21_im[i * 4 + 2] <= bfly20_im[i * 4] - bfly20_im[i * 4 + 2];
                    add_sub_step21_im[i * 4 + 3] <= bfly20_im[i * 4 + 1] - bfly20_im[i * 4 + 3];
                end
            end


            if(step21_mul_enable) begin
                for(i = 0; i < 16; i++) begin
                    case (i)
                        0, 1, 2, 4, 6, 8, 9, 10, 12, 14: begin
                            bfly21_re[i] <= ((add_sub_step21_re[i] <<< 8) + 128) >>> 8;
                            bfly21_im[i] <= ((add_sub_step21_im[i] <<< 8) + 128) >>> 8;
                        end
                            
                        3, 11 : begin
                            bfly21_re[i] <= ((add_sub_step21_im[i] <<< 8) + 128) >>> 8;
                            bfly21_im[i] <= (-(add_sub_step21_re[i] <<< 8) + 128) >>> 8;
                        end

                        5, 13 : begin
                            bfly21_re[i] <= (mul2_181(add_sub_step21_re[i]) + mul2_181(add_sub_step21_im[i]) + 128) >>> 8;
                            bfly21_im[i] <= (mul2_181(add_sub_step21_im[i]) - mul2_181(add_sub_step21_re[i]) + 128) >>> 8;
                        end

                        7, 15 : begin
                            bfly21_re[i] <= (mul2_neg181(add_sub_step21_re[i]) + mul2_181(add_sub_step21_im[i]) + 128) >>> 8;
                            bfly21_im[i] <= (mul2_neg181(add_sub_step21_im[i]) - mul2_181(add_sub_step21_re[i]) + 128) >>> 8;
                        end
                        default: begin
                            bfly21_re[i] <= '0;
                            bfly21_im[i] <= '0;
                        end
                    endcase
                end
                
            end
        end
    end
endmodule

module step2_2 (
    input clk,
    input rst,
    input valid,

    input logic unsigned [5:0] cbfp_min_var [0:1],

    input logic signed [14:0] bfly21_re [0:15],
    input logic signed [14:0] bfly21_im [0:15],

    output logic signed [12:0] bfly22_re [0:15],
    output logic signed [12:0] bfly22_im [0:15],
    output logic step22_add_sub_enable,
    output logic step22_arrangement

);
    
    integer j;
    logic signed [15:0] step22_add_sub_re [0:15];
    logic signed [15:0] step22_add_sub_im [0:15];

   // logic unsigned [5:0] cbfp_indexsum [0:1];

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            for(j=0; j<16; j++) begin
                step22_add_sub_re[j] <= '0;
                step22_add_sub_im[j] <= '0;
                bfly22_re[j] <= '0;
                bfly22_im[j] <= '0;
                //cbfp_indexsum[j] <= '0;
            end

            step22_add_sub_enable <= 0;
            step22_arrangement <= 0;

        end else begin

            step22_add_sub_enable <= valid;
            step22_arrangement <= step22_add_sub_enable;
            
            if (step22_add_sub_enable) begin // saturation
                for (j = 0; j < 8; j++) begin
                    step22_add_sub_re[j*2] <= 
                        ((bfly21_re[j*2] + bfly21_re[j*2+1]) > 32767)  ?  32767 :
                        ((bfly21_re[j*2] + bfly21_re[j*2+1]) < -32768) ? -32768 :
                        (bfly21_re[j*2] + bfly21_re[j*2+1]);

                    step22_add_sub_re[j*2+1] <= 
                        ((bfly21_re[j*2] - bfly21_re[j*2+1]) > 32767)  ?  32767 :
                        ((bfly21_re[j*2] - bfly21_re[j*2+1]) < -32768) ? -32768 :
                        (bfly21_re[j*2] - bfly21_re[j*2+1]);

                    step22_add_sub_im[j*2] <= 
                        ((bfly21_im[j*2] + bfly21_im[j*2+1]) > 32767)  ?  32767 :
                        ((bfly21_im[j*2] + bfly21_im[j*2+1]) < -32768) ? -32768 :
                        (bfly21_im[j*2] + bfly21_im[j*2+1]);

                    step22_add_sub_im[j*2+1] <= 
                        ((bfly21_im[j*2] - bfly21_im[j*2+1]) > 32767)  ?  32767 :
                        ((bfly21_im[j*2] - bfly21_im[j*2+1]) < -32768) ? -32768 :
                        (bfly21_im[j*2] - bfly21_im[j*2+1]);
                end

                /*for(j=0; j<1; j++) begin
                    cbfp_indexsum[j] <= cbfp_min_var[j];
                end*/
            end

            if (step22_arrangement) begin
                for(j=0; j<16; j++) begin
                    if(j<8) begin
                        if(cbfp_min_var[0] > 22) begin
                            bfly22_re[j] <= '0;
                            bfly22_im[j] <= '0;
                        end else if (cbfp_min_var[0] > 9) begin
                            bfly22_re[j] <= step22_add_sub_re[j] >>> (cbfp_min_var[0] - 9);
                            bfly22_im[j] <= step22_add_sub_im[j] >>> (cbfp_min_var[0] - 9);
                        end else begin
                            bfly22_re[j] <= step22_add_sub_re[j] <<< (9 - cbfp_min_var[0]);
                            bfly22_im[j] <= step22_add_sub_im[j] <<< (9 - cbfp_min_var[0]);
                        end
                    end else begin
                        if(cbfp_min_var[1] > 22) begin
                            bfly22_re[j] <= '0;
                            bfly22_im[j] <= '0;
                        end else if (cbfp_min_var[1] > 9) begin
                            bfly22_re[j] <= step22_add_sub_re[j] >>> (cbfp_min_var[1] - 9);
                            bfly22_im[j] <= step22_add_sub_im[j] >>> (cbfp_min_var[1] - 9);
                        end else begin
                            bfly22_re[j] <= step22_add_sub_re[j] <<< (9 - cbfp_min_var[1]);
                            bfly22_im[j] <= step22_add_sub_im[j] <<< (9 - cbfp_min_var[1]);
                        end
                    end
                    
                end 
            end else begin
                for(j=0; j<16; j++) begin
                    bfly22_re[j] <= '0;
                    bfly22_im[j] <= '0;
                end
            end
        end
    end
endmodule

module index_reorder (
    input clk,
    input rst,
    input bitget_valid,
    input logic signed [12:0] bfly22_re [0:15],
    input logic signed [12:0] bfly22_im [0:15],

    output logic signed [12:0] dout_re [0:15],
    output logic signed [12:0] dout_im [0:15],
    output logic complete_sig
);

    integer j;

    logic unsigned [9:0] real_index [0:15];
    logic signed [12:0] not_reordered_re [0:511];
    logic signed [12:0] not_reordered_im [0:511];
    logic [4:0] index_cnt;
    logic [4:0] reorder_cnt;
    logic [4:0] output_cnt;
    logic reorder_valid, output_valid;
    logic [8:0] index_cnt16;
    

    assign index_cnt16 = index_cnt << 4;

    
    function automatic logic bitget(input logic [8:0] val, input int k);
        // val: 9비트 이진수 (0~511 입력)
        // k: 1-based index (1 = LSB, 9 = MSB)
        if (k >= 1 && k <= 9)
            return val[k - 1];
        else
            return 1'b0;  // 잘못된 인덱스는 0 반환
    endfunction


    always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
        for (j = 0; j < 512; j++) begin
            not_reordered_re[j] <= '0;
            not_reordered_im[j] <= '0;
        end

        for(j = 0; j < 16; j ++) begin
            real_index[j] <= '0;
            dout_re[j] <= '0;
            dout_im[j] <= '0;    
        end

        index_cnt <= 0;
        reorder_cnt <= 0;
        output_cnt <= 0;
        reorder_valid <= 0;
        output_valid <= 0;
        complete_sig <= 0;

    end else begin
        if(bitget_valid) begin
            reorder_valid <= 1;

            index_cnt <= (index_cnt == 31) ? 0 : index_cnt + 1;
            

            for (j = 0; j < 16; j++) begin
                real_index[j] <=
                    bitget((index_cnt16) + j, 9)     +
                    (bitget((index_cnt16) + j, 8) << 1) +
                    (bitget((index_cnt16) + j, 7) << 2) +
                    (bitget((index_cnt16) + j, 6) << 3) +
                    (bitget((index_cnt16) + j, 5) << 4) +
                    (bitget((index_cnt16) + j, 4) << 5) +
                    (bitget((index_cnt16) + j, 3) << 6) +
                    (bitget((index_cnt16) + j, 2) << 7) +
                    (bitget((index_cnt16) + j, 1) << 8);
            end

        end else begin
            reorder_valid <= 0;
            index_cnt <= 0;
            for(j = 0; j < 16; j ++) begin
                real_index[j] <= '0;
            end
        end
        
        if (reorder_valid) begin
            if(reorder_cnt == 31) begin
                output_valid <= 1;
                reorder_cnt <= 0;
            end else begin
                reorder_cnt <= reorder_cnt + 1;
            end
            for(j=0; j<16; j++) begin
                not_reordered_re[real_index[j]] <= bfly22_re[j];
                not_reordered_im[real_index[j]] <= bfly22_im[j];
            end
        end else begin
            reorder_cnt <= 0;
        end

        if (output_valid) begin
            if(output_cnt == 31) begin
                output_cnt <= 0;
                output_valid <= 0;
            end else begin
                output_cnt <= (output_cnt == 31) ? 0 : output_cnt + 1;
            end
            /*for(j=0; j<16; j++) begin
                dout_re[j] <= not_reordered_re[output_cnt * 16 + j];
                dout_im[j] <= not_reordered_im[output_cnt * 16 + j];
            end*/
            case (output_cnt)
                0:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[j];
                        dout_im[j] <= not_reordered_im[j];
                    end 
                1:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[16+j];
                        dout_im[j] <= not_reordered_im[16+j];
                    end 
                2:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[32 + j];
                        dout_im[j] <= not_reordered_im[32 + j];
                    end 
                3:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[48+j];
                        dout_im[j] <= not_reordered_im[48+j];
                    end 
                4:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[64 + j];
                        dout_im[j] <= not_reordered_im[64 + j];
                    end 
                5:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[80 + j];
                        dout_im[j] <= not_reordered_im[80 + j];
                    end 
                6:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[96 + j];
                        dout_im[j] <= not_reordered_im[96 + j];
                    end 
                7:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[112 + j];
                        dout_im[j] <= not_reordered_im[112 + j];
                    end 
                8:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[128 + j];
                        dout_im[j] <= not_reordered_im[128 + j];
                    end 
                9:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[144 + j];
                        dout_im[j] <= not_reordered_im[144 + j];
                    end 
                10:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[160 + j];
                        dout_im[j] <= not_reordered_im[160 + j];
                    end 
                11:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[176 + j];
                        dout_im[j] <= not_reordered_im[176 + j];
                    end 
                12:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[192 + j];
                        dout_im[j] <= not_reordered_im[192 + j];
                    end 
                13:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[208 + j];
                        dout_im[j] <= not_reordered_im[208 + j];
                    end 
                14:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[224 + j];
                        dout_im[j] <= not_reordered_im[224 + j];
                    end 
                15:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[240 + j];
                        dout_im[j] <= not_reordered_im[240 + j];
                    end 
                16:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[256 + j];
                        dout_im[j] <= not_reordered_im[256 + j];
                    end 
                17:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[272  + j];
                        dout_im[j] <= not_reordered_im[272  + j];
                    end 
                18:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[288 + j];
                        dout_im[j] <= not_reordered_im[288 + j];
                    end 
                19:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[304 + j];
                        dout_im[j] <= not_reordered_im[304 + j];
                    end 
                20:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[320 + j];
                        dout_im[j] <= not_reordered_im[320 + j];
                    end 
                21:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[336+ j];
                        dout_im[j] <= not_reordered_im[336 + j];
                    end 
                22:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[352 + j];
                        dout_im[j] <= not_reordered_im[352 + j];
                    end 
                23:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[368 + j];
                        dout_im[j] <= not_reordered_im[368 + j];
                    end 
                24:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[384 + j];
                        dout_im[j] <= not_reordered_im[384 + j];
                    end 
                25:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[400 + j];
                        dout_im[j] <= not_reordered_im[400 + j];
                    end 
                26:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[416 + j];
                        dout_im[j] <= not_reordered_im[416 + j];
                    end 
                27:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[432 + j];
                        dout_im[j] <= not_reordered_im[432 + j];
                    end 
                28:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[448 + j];
                        dout_im[j] <= not_reordered_im[448 + j];
                    end 
                29:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[464 + j];
                        dout_im[j] <= not_reordered_im[464 + j];
                    end 
                30:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[480 + j];
                        dout_im[j] <= not_reordered_im[480 + j];
                    end 
                31:  for(j = 0; j < 16; j++) begin
                        dout_re[j] <= not_reordered_re[496 + j];
                        dout_im[j] <= not_reordered_im[496 + j];
                    end 
               
               
                default: for(j = 0; j < 16; j++) begin
                            dout_re[j] <= '0;
                            dout_im[j] <= '0;
                        end 
            endcase

        end else begin
            for(j = 0; j < 16; j++) begin
                dout_re[j] <= '0;
                dout_im[j] <= '0;
            end 
            output_cnt <= 0;
        end

        complete_sig <= output_valid;
    end
end
endmodule


