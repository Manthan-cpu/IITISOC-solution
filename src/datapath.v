`timescale 1ns / 1ps

module datapath(
    input wire clk,
    input wire reset,
    input wire ResultSrc,
    input wire MemRead,
    input wire MemWrite,
    input wire ALUSrc,
    input wire [1:0] ImmSrc,
    input wire RegWrite,
    input wire Branch,
    input wire Jump,
    output wire [3:0] opcode,
    output wire PCSrc
    );
    
    wire [15:0] instruction;
    wire signed [7:0] read_data1, read_data2, alu_in2,
                      alu_result, imm_out, mem_data,
                      writeback_data; 
    wire [7:0] PC_out;
    wire valid, zero, branch_taken;  

    assign PCSrc = (Branch & branch_taken) | Jump;
    assign alu_in2 = ALUSrc ? imm_out : read_data2;
    
    fetchinstruction fetch_unit(
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),
        .PC_sel(PCSrc),
        .branch_target(PC_out + imm_out),
        .instruction(instruction),
        .PC_out(PC_out),
        .valid(valid)
    );
    
    assign opcode = instruction[15:12];
    reg [2:0] rs1, rs2, rd;
    
    always@(*) begin
    
        rs1 = 3'b0; rs2 = 3'b0; rd = 3'b0;
        
        case(opcode)
            
            4'b0000, 4'b0001, 4'b0010,
            4'b0011, 4'b0100, 4'b0101: begin
                rs1 = instruction[11:9];
                rs2 = instruction[8:6];
                rd = instruction[5:3];
            end
            
            4'b0110, 4'b0111, 4'b1001: begin
                rs1 = instruction[8:6];
                rd = instruction[11:9];
            end
            
            4'b1000: begin
                rs1 = instruction[8:6];
                rs2 = instruction[11:9];
            end
            
            4'b1010: begin
                rd = instruction[11:9];
            end
            
            4'b1011, 4'b1100: begin
                rs1 = instruction[11:9];
                rs2 = instruction[8:6];
            end
            
            4'b1101, 4'b1110, 4'b1111: begin
            end
        endcase
    end
    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(writeback_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    immediate_generator imm_gen(
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .imm_out(imm_out)
    );
    
    alu alu(
        .a(read_data1),
        .b(alu_in2),
        .opcode(opcode),
        .dir(instruction[0]),
        .result(alu_result),
        .zero(zero),
        .branch_taken(branch_taken)
    );
    
    memory_stage mem_stage(
        .clk(clk),
        .reset(reset),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .alu_result(alu_result),
        .write_data(read_data2),
        .read_data(mem_data)
    );
    
    writeback_stage wb_stage(
        .ResultSrc(ResultSrc),
        .alu_result(alu_result),
        .mem_data(mem_data),
        .writeback_data(writeback_data)
    );
               
endmodule
