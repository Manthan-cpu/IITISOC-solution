`timescale 1ns / 1ps


module top(
    input wire clk,
    input wire reset
);
    wire ResultSrc, MemRead, MemWrite, ALUSrc, RegWrite, Branch, Jump, PCSrc;
    wire [1:0] ImmSrc;
    wire [3:0] opcode;

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
        .opcode(opcode),
        .PCSrc(PCSrc)
    );
endmodule
