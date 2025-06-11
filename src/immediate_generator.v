`timescale 1ns / 1ps

module immediate_generator(
    input [15:0] instruction,
    input [1:0] ImmSrc,
    output reg signed [7:0] imm_out
    );
    
    always@(*) begin
        case (ImmSrc)
            2'b00: imm_out = instruction[8:1]; //8-bit
            2'b01: imm_out = {{2{instruction[5]}}, instruction[5:0]}; //6-bit
            2'b10: imm_out = {3'b000, instruction[5:1]}; //5-bit
            default: imm_out = 8'b0;
        endcase
    end        
endmodule
