`timescale 1ns / 1ps

module cbfp2 #(
    parameter DATA_IN_WIDTH = 16, // 이전 단계 (bfly22_tmp) 데이터의 비트 폭
    parameter OWIDTH = 13,        // 최종 출력 (bfly22)의 비트 폭
    parameter INDEX_WIDTH = 6     // db_do_index의 비트 폭 (예: 6비트, 0~63)
) (
    input clk,
    input rstn,

    // 이전 단계 (예: butterfly stage 3)의 출력 데이터
    input signed [DATA_IN_WIDTH-1:0] bfly_in_re[0:15], // MATLAB의 bfly22_tmp(ii)
    input signed [DATA_IN_WIDTH-1:0] bfly_in_im[0:15], // MATLAB의 bfly22_tmp(ii)

    // 각 병렬 경로에 대한 인덱스/스케일링 정보 (MATLAB의 indexsum_re/im에 해당)
    // 이 신호가 실제로는 'indexsum' 값이어야 합니다.
    input [INDEX_WIDTH-2:0] do_index_cbfp0_real[0:15], // MATLAB의 indexsum_re/im과 같은 역할
    input [INDEX_WIDTH-2:0] do_index_cbfp0_imag[0:15],
    input [INDEX_WIDTH-2:0] do_index_cbfp1_real[0:15],
    input [INDEX_WIDTH-2:0] do_index_cbfp1_imag[0:15],

    // 최종 스케일링되고 포화된 출력
    output logic signed [OWIDTH-1:0] bfly22_re[0:15], // bfly22의 실수부
    output logic signed [OWIDTH-1:0] bfly22_im[0:15], // bfly22의 허수부

    // 이 모듈의 출력 유효 신호 (이전 단계의 do_en을 전달하거나 지연)
    input  bf3_do_en, // 이전 단계에서 온 enable 신호
    output logic do_en_out // 이 모듈에서 나가는 enable 신호
);
    // 내부 신호 선언
    logic [INDEX_WIDTH-1:0] shift_amount_re[0:15];
    logic [INDEX_WIDTH-1:0] shift_amount_im[0:15]; // 실제 시프트할 비트 수 (9-indexsum)
    
    logic signed [DATA_IN_WIDTH-1:0] tmp_shifted_re[0:15];
    logic signed [DATA_IN_WIDTH-1:0] tmp_shifted_im[0:15];

    // MATLAB의 indexsum_re/im 에 해당하는 신호 선언
    logic [INDEX_WIDTH-1:0] indexsum_re[0:15]; 
    logic [INDEX_WIDTH-1:0] indexsum_im[0:15]; 

    // ---------- 이 부분이 MATLAB 코드의 인덱스 합산 부분. ---------
    genvar g;
    for (g = 0; g < 16; g++) begin : gen_index_sum
        // MATLAB의 indexsum_re(kk) = index1_re(kk) + index2_re(kk); 에 해당
        assign indexsum_re[g] = do_index_cbfp0_real[g] + do_index_cbfp1_real[g];
        // MATLAB의 indexsum_im(kk) = index1_im(kk) + index2_im(kk); 에 해당
        assign indexsum_im[g] = do_index_cbfp0_imag[g] + do_index_cbfp1_imag[g];
    end
    // -------------------------------------------------------------------

    // --- 시프트 양 (shift_amount) 및 포화 로직 (Combinational) ---
    genvar i; // for loop 변수 선언

    for (i = 0; i < 16; i++) begin : gen_scaling_logic
        // 실수부 shift_amount 계산
        assign shift_amount_re[i] = (indexsum_re[i] > 6'd9) ? (indexsum_re[i] - 6'd9) :
                                     (indexsum_re[i] < 6'd9) ? (6'd9 - indexsum_re[i]) : 6'd0;

        // 허수부 shift_amount 계산
        assign shift_amount_im[i] = (indexsum_im[i] > 6'd9) ? (indexsum_im[i] - 6'd9) :
                                     (indexsum_im[i] < 6'd9) ? (6'd9 - indexsum_im[i]) : 6'd0;

        always_comb begin
            // 실수부 포화 및 시프트
            if (indexsum_re[i] >= 6'd23) begin // MATLAB 코드에서 'indexsum_re(ii)>=23' 이면 0으로 설정
                tmp_shifted_re[i] = '0;
            end else begin
                if (indexsum_re[i] > 6'd9) begin // '9'를 기준으로 우측 시프트
                    tmp_shifted_re[i] = bfly_in_re[i] >>> shift_amount_re[i]; // 산술 우측 시프트
                end else if (indexsum_re[i] < 6'd9) begin // '9'를 기준으로 좌측 시프트
                    tmp_shifted_re[i] = bfly_in_re[i] <<< shift_amount_re[i]; // 논리 좌측 시프트
                end else begin // shift_amount_re == 0
                    tmp_shifted_re[i] = bfly_in_re[i];
                end
            end

            // 허수부 포화 및 시프트
            if (indexsum_im[i] >= 6'd23) begin // MATLAB 코드에서 'indexsum_im(ii)>=23' 이면 0으로 설정
                tmp_shifted_im[i] = '0;
            end else begin
                if (indexsum_im[i] > 6'd9) begin // '9'를 기준으로 우측 시프트
                    tmp_shifted_im[i] = bfly_in_im[i] >>> shift_amount_im[i]; // 산술 우측 시프트
                end else if (indexsum_im[i] < 6'd9) begin // '9'를 기준으로 좌측 시프트
                    tmp_shifted_im[i] = bfly_in_im[i] <<< shift_amount_im[i]; // 논리 좌측 시프트
                end else begin // shift_amount_im == 0
                    tmp_shifted_im[i] = bfly_in_im[i];
                end
            end

            // 최종 출력 폭(OWIDTH)에 맞게 잘라내기
            bfly22_re[i] = tmp_shifted_re[i][OWIDTH-1:0];
            bfly22_im[i] = tmp_shifted_im[i][OWIDTH-1:0];
        end
    end // end of gen_scaling_logic

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            do_en_out <= 1'b0; // 리셋 시 비활성화
        end else begin
            do_en_out <= bf3_do_en; // 이전 단계의 enable 신호 전달
        end
    end

endmodule