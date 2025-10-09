`timescale 1ns/1ps

module num_counter #(
    parameter NUM = 16
)  (
    input clk,
    input rst,
    input valid,
    output logic bfly_enable
);

    logic [$clog2(NUM) - 1:0] cnt;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            cnt <= 0;
            bfly_enable <= 0;
        end else if (valid) begin
            if(cnt == NUM - 1) begin
                cnt <= 0;
                bfly_enable <= 1;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule

module step0_num_counter #(
    parameter NUM = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic valid,
    output logic bfly_add_sub_en,
    output logic bfly_mul_en
);

    logic [$clog2(NUM)-1:0] cnt;

    // count 시작 조건: valid 또는 mul_stage_flag가 올라간 이후
    logic cnt_enable;
    logic add_sub_flag, mul_flag;

    assign cnt_enable = valid | bfly_add_sub_en;
    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            cnt <= 0;
            bfly_add_sub_en <= 0;
            bfly_mul_en <= 0;
            add_sub_flag <= 0;
            mul_flag <= 0;
        end else begin
            if (cnt_enable) begin
                if ((add_sub_flag == 0) && (cnt == NUM - 1)) begin
                    cnt <= 0;
                    bfly_add_sub_en <= 1;
                    add_sub_flag <= 1;
                end else if ((add_sub_flag == 1) && (cnt == NUM - 1)) begin
                    bfly_add_sub_en <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end

            if((mul_flag == 0) && (bfly_add_sub_en == 1)) begin
                mul_flag <= 1;
                bfly_mul_en <= 1;
            end else if ((mul_flag == 1) && (bfly_add_sub_en == 0)) begin
                mul_flag <= 0;
                bfly_mul_en <= 0;
            end
        end
    end

endmodule
