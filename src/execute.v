`timescale 1ns / 1ps


module Execute(
input wire signed[7:0] reg1,//register 1
input wire signed[7:0] reg2,//register 2
input wire signed[7:0] immediate,
input wire ALUsrc,
input wire  [3:0]opcode,
input wire [1:0] forwardA,  //for chosing between alu_result_mem,alu_result_wb,register 1
input wire [1:0] forwardB,  //for chosing between alu_result_mem,alu_result_wb,register 2
input wire signed[7:0] alu_result_mem,
input wire signed[7:0] write_data_wb,

output wire [7:0] alu_result,
output wire zero,
output wire branch_taken

    );
  reg signed[7:0] operand1,operand2,intermediate;
    always @(*) begin
    
    case(forwardA)
    
    2'b01: operand1=write_data_wb;
    2'b10:  operand1=alu_result_mem;    
   default: operand1=reg1;
    endcase
        case(forwardB)
     
    2'b01: intermediate=write_data_wb;
    2'b10:  intermediate=alu_result_mem;    
   default: intermediate=reg2;
    endcase
    end
    always @(*)
    begin
    operand2 =(ALUsrc)? immediate : intermediate;
    end
    
   alu alu_inst (
    .a(operandA),
    .b(alu_inputB),
    .opcode(opcode),
    .dir(dir),
    .result(alu_result),
    .zero(zero),
    .branch_taken(branch_taken)
  );
    
endmodule
