`timescale 1ns / 1ps


module decode(
    input wire clk,
    input wire reset,
    input wire [15:0] instruction,
    input wire RegWrite,
    input wire [2:0] write_reg,
    input wire [1:0] ImmSrc,
    output wire signed [7:0] read_data1,
    output wire signed [7:0] read_data2,
    output reg signed [7:0] imm_out,
    output wire [2:0] rs1, rs2, rd
    );
  
    
    wire [3:0] opcode;
    assign opcode = instruction[15:12];
    reg [2:0] rs1_w, rs2_w, rd_w;
    
    always @(*) begin
        rs1_w = 3'b0; rs2_w = 3'b0; rd_w = 3'b0;
        case(opcode)
            4'b0000, 4'b0001, 4'b0010,
            4'b0011, 4'b0100, 4'b0101: begin
                rs1_w = instruction[11:9];
                rs2_w = instruction[8:6];
                rd_w = instruction[5:3];
            end
            4'b0110, 4'b0111, 4'b1001: begin
                rs1_w = instruction[8:6];
                rd_w = instruction[11:9];
            end
            4'b1000: begin
                rs1_w = instruction[8:6];
                rs2_w = instruction[11:9];
            end
            4'b1010: begin
                rd_w = instruction[11:9];
            end
            4'b1011, 4'b1100: begin
                rs1_w = instruction[11:9];
                rs2_w = instruction[8:6];
            end
        endcase
    end
    
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .read_reg1(rs1_w),
        .read_reg2(rs2_w),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    immediate_generator imm_gen(
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .imm_out(imm_out)
    );
    
    assign rs1 = rs1_w;
    assign rs2 = rs2_w;
    assign rd  = rd_w;
    
endmodule
