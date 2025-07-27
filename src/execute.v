`timescale 1ns / 1ps

module Execute(
    input  wire              clk,
    input  wire              reset,
    input  wire              flush, 
    input  wire signed [7:0] reg1,
    input  wire signed [7:0] reg2,
    input  wire signed [7:0] immediate,
    input  wire              ALUsrc,
    input  wire              dir,
    input  wire [3:0]        opcode,
    input  wire [1:0]        forward_A,
    input  wire [1:0]        forward_B,
    input  wire signed [7:0] alu_result_mem,
    input  wire signed [7:0] write_data_wb,
    input  wire              is_unsigned,
    output reg signed [7:0] alu_result,
    output reg              zero,
    output reg              branch_taken
);

    reg signed [7:0] operand1, operand2, intermediate;

    wire signed [7:0] alu_out;
    wire alu_zero;
    wire alu_branch;

    always @(*) begin
        case (forward_A)
            2'b01: operand1 = write_data_wb;
            2'b10: operand1 = alu_result_mem;
            default: operand1 = reg1;
        endcase

        case (forward_B)
            2'b01: intermediate = write_data_wb;
            2'b10: intermediate = alu_result_mem;
            default: intermediate = reg2;
        endcase
    

  
        operand2 = (ALUsrc) ? immediate : intermediate;
    end

    alu alu_inst (
        .a(operand1),
        .b(operand2),
        .opcode(opcode),
        .dir(dir),
        .result(alu_out),
        .zero(alu_zero),
        .branch_taken(alu_branch),
        .is_unsigned(is_unsigned)
    );

    always @(*) begin
        if (reset ) begin
            alu_result   = 8'd0;
            zero         = 1'b0;
            branch_taken = 1'b0;
        end 
        else if(flush)begin
            alu_result   = 8'd0;
            zero         = 1'b0;
            branch_taken = alu_branch;
        end
        else begin
            alu_result   = alu_out;
            zero         = alu_zero;
            branch_taken = alu_branch;
        end
    end

endmodule


