`timescale 1ns/1ps

module shift_reg #(
    parameter WIDTH = 9,          // 각 데이터 비트 수 (예: <3.6> 고정 소수점 9비트)
    parameter GROUP_SIZE = 16,    // 한 클럭에 들어오는 병렬 데이터 개수
    parameter DEPTH = 16          // 시프트 레지스터 깊이 (몇 클럭치 쌓을지)
)(
    input  logic                     clk,
    input  logic                     rstn,
    input  logic signed [WIDTH-1:0] data_in  [0:GROUP_SIZE-1], // 병렬 입력
    output logic signed [WIDTH-1:0] data_out [0:GROUP_SIZE-1]  // 병렬 출력
);

    // DEPTH 단계, 각 단계는 GROUP_SIZE 개의 WIDTH 비트 데이터 묶음
    // 사용자 설명에 맞게: 최신 입력은 [DEPTH-1], 가장 오래된 데이터는 [0]에 위치하도록 레지스터 인덱싱 변경
    // shift_reg[DEPTH-1]이 최신, shift_reg[0]이 가장 오래된 데이터
    logic signed [WIDTH-1:0] shift_reg [0:DEPTH-1][0:GROUP_SIZE-1];

    integer i, j;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 리셋 시 모든 레지스터와 출력을 0으로 초기화
            for (i = 0; i < DEPTH; i++) begin
                for (j = 0; j < GROUP_SIZE; j++) begin
                    shift_reg[i][j] <= '0;
                end
            end
            for (j = 0; j < GROUP_SIZE; j++) begin
                data_out[j] <= '0;
            end
        end else begin
            // 1. 모든 기존 데이터를 한 칸씩 아래(오래된 쪽)로 시프트
            // shift_reg[0]의 내용이 shift_reg[1]으로, shift_reg[1]의 내용이 shift_reg[2]으로 이동
            for (i = DEPTH-1; i >= 0; i--) begin
                for (j = 0; j < GROUP_SIZE; j++) begin
                    shift_reg[i][j] <= shift_reg[i-1][j];
                end
            end

            // 2. 최신 입력을 shift_reg[0]에 저장 (가장 최신 위치)
            for (j = 0; j < GROUP_SIZE; j++) begin
                shift_reg[0][j] <= data_in[j];
            end

            // 3. 가장 오래된 데이터 (shift_reg[15])를 출력으로 내보냄
            for (i = GROUP_SIZE-1; j >= 0; j--) begin
                data_out[j] <= shift_reg[GROUP_SIZE][j];
            end
        end
    end

endmodule