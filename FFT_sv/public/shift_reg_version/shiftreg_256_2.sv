
`timescale 1ns / 1ps

module shift_reg #(
    parameter WIDTH = 9,
    parameter DELAY_LENGTH = 16
)(
    input clk,
    input rstn,

    input write, // 16개 묶음 복소수 쓰기
    input read,  // 16개 묶음 복소수 읽기

    input signed [WIDTH-1:0] data_in_real [15:0],
    input signed [WIDTH-1:0] data_in_imag [15:0],

    output logic signed [WIDTH-1:0] data_out_real [15:0],
    output logic signed [WIDTH-1:0] data_out_imag [15:0],

    output logic full,
    output logic empty
);

    reg signed [WIDTH-1:0] shift_din_real [DELAY_LENGTH-1:0][15:0];
    reg signed [WIDTH-1:0] shift_din_imag [DELAY_LENGTH-1:0][15:0];

    reg [$clog2(DELAY_LENGTH+1)-1:0] count;
    integer i, j;

    // full/empty 상태 관리
    assign full  = (count == DELAY_LENGTH);
    assign empty = (count == 0);

    
    // 카운터 업데이트
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            count <= 0;
        end
        else if (write && !read && !full) begin
            count <= count + 1'b1;
        end
        else if (read && !write && !empty) begin
            count <= count - 1'b1;
        end
    end

    // main logic
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 초기화
            for (i = 0; i < DELAY_LENGTH; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    shift_din_real[i][j] <= 0;
                    shift_din_imag[i][j] <= 0;
                end
            end
            for (j = 0; j < 16; j = j + 1) begin
                data_out_real[j] <= 0;
                data_out_imag[j] <= 0;
            end
        end else begin
            // read 동작 먼저 수행
            if (read && !empty) begin
                data_out_real <= shift_din_real[DELAY_LENGTH-1];
                data_out_imag <= shift_din_imag[DELAY_LENGTH-1];
            end else begin
                for (j = 0; j < 16; j = j + 1) begin
                    data_out_real[j] <= 0;
                    data_out_imag[j] <= 0;
                end
            end

            // 시프트: read 또는 write 둘 중 하나라도 있으면 시프트
            if ((read && !empty) || (write && !full)) begin
                for (i = DELAY_LENGTH-1; i > 0; i = i - 1) begin
                    shift_din_real[i] <= shift_din_real[i-1];
                    shift_din_imag[i] <= shift_din_imag[i-1];
                end

                if (write && !full) begin
                    shift_din_real[0] <= data_in_real;
                    shift_din_imag[0] <= data_in_imag;
                end else begin
                    for (j = 0; j < 16; j = j + 1) begin
                        shift_din_real[0][j] <= 0;
                        shift_din_imag[0][j] <= 0;
                    end
                end
            end
        end
    end

endmodule
