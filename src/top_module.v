`timescale 1ns / 1ps


module top(
    input wire clk,
    input wire reset
);
    wire ResultSrc, MemRead, MemWrite, ALUSrc, RegWrite, Branch, Jump;
    wire [1:0] ImmSrc;
    wire [3:0] opcode;
    wire PCSrc;
    wire branch_taken;

    control_unit cu (
        .opcode(opcode),
        .ResultSrc(ResultSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .Jump(Jump)
    );

    assign PCSrc = Jump | (Branch & branch_taken); //changes made here

    datapath dp (
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .Jump(Jump),
        .PCSrc(PCSrc),
        .opcode(opcode),
        .branch_taken(branch_taken)
    );
endmodule
