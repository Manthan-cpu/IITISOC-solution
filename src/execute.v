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
    input  wire [1:0]        forward_BL,
    input  wire [1:0]        forward_AL,
    input  wire signed [7:0] alu_result_mem,
    input  wire signed [7:0] write_data_wb,
    input  wire signed [7:0] mem_read_ex,
    input  wire              is_unsigned,
    input  wire              ResultSrc_MEM,
    output reg  signed [7:0] alu_result,
    output reg               zero,
    output reg               branch_taken
);

    reg signed [7:0] operand1, operand2, intermediate;

    wire signed [7:0] alu_out;
    wire alu_zero;
    wire alu_branch;
    reg ResultSrc_MEM_d;
    reg ResultSrc_MEM_dd;
    
    always @(posedge clk or posedge reset) begin 
    ResultSrc_MEM_d <= ResultSrc_MEM ;
    ResultSrc_MEM_dd <= ResultSrc_MEM_d;
    end

   always @(*) begin
    // Forwarding for operand1
    if (ResultSrc_MEM_dd) begin
        case (forward_AL)
            2'b01: operand1 = write_data_wb;
            2'b10: operand1 = mem_read_ex;
            default: operand1 = reg1;
        endcase
    end else begin
        case (forward_A)
            2'b01: operand1 = write_data_wb;
            2'b10: operand1 = alu_result_mem;
            default: operand1 = reg1;
        endcase
    end

    // Forwarding for operand2 (intermediate)
    if (ResultSrc_MEM_dd) begin
        case (forward_BL)
            2'b01: intermediate = write_data_wb;
            2'b10: intermediate = mem_read_ex;
            default: intermediate = reg2;
        endcase
    end else begin
        case (forward_B)
            2'b01: intermediate = write_data_wb;
            2'b10: intermediate = alu_result_mem;
            default: intermediate = reg2;
        endcase
    end
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
