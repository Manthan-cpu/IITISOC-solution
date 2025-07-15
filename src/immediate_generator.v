`timescale 1ns / 1ps

module immediate_generator(
    input wire [15:0] instruction,
    input wire [1:0] ImmSrc,
    output reg signed [7:0] imm_out
);

    always @(*) begin
        case (ImmSrc)
            2'b00: imm_out = instruction[11:4]; // 8-bit immediate (LDI, JMP)
            2'b01: imm_out = {{2{instruction[5]}}, instruction[5:0]}; // 6-bit signed (LOAD, STORE, BRANCH)
            2'b10: imm_out = {5'b00000, instruction[5:3]}; // 3-bit(SHIFT)
            2'b11: imm_out = {{3{instruction[4]}},instruction[4:0]};//5-bit(ADDI)
            default: imm_out = 8'b0;
        endcase
    end
endmodule
