
`timescale 1ns / 1ps

module immediate_generator(
    input wire [15:0] instruction,
    input wire [1:0] ImmSrc,
    output reg signed [7:0] imm_out
);

    always @(*) begin
        case (ImmSrc)
            2'b00: case(instruction[15:12])
                4'b1010: imm_out = instruction[8:1]; // LDI
                4'b1101: imm_out = instruction[11:4]; //JMP
                   endcase
            2'b01: imm_out = {{2{instruction[5]}}, instruction[5:0]}; // LOAD, STORE, BEQ, BNE
            2'b10: imm_out = {5'b00000, instruction[5:3]}; //SHIFT
            2'b11: imm_out = {{3{instruction[5]}}, instruction[5:1]}; //ADDI
            default: imm_out = 8'b0;
        endcase
    end
endmodule
