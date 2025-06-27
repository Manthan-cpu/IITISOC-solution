`timescale 1ns / 1ps

module fetchinstruction(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire PC_sel,
    input wire Jump,                      // NEW: jump signal
    input wire [7:0] branch_target,

    output reg [15:0] instruction,
    output reg [7:0] PC_out,
    output reg valid
);

    reg [7:0] PC;
    reg halt;

    reg [15:0] instruction_memory [0:255];

    initial begin
        $readmemh("instruction.mem", instruction_memory);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 8'b0;
            PC_out <= 8'b0;
            halt <= 1'b0;
            instruction <= 16'h0000;
            valid <= 1'b0;
        end else if (stall || halt) begin
            valid <= 1'b0;
        end else begin
            // 🔁 FIX: Jump gets highest priority
            if (Jump)
                PC <= instruction[11:4];      // Absolute jump
            else if (PC_sel)
                PC <= branch_target;          // PC-relative branch
            else
                PC <= PC + 1;

            instruction <= flush ? 16'h0000 : instruction_memory[PC];
            PC_out <= PC;
            valid <= ~flush;

            // 🔒 Detect HLT
            if (!flush && instruction_memory[PC][15:12] == 4'b1111)
                halt <= 1'b1;
        end
    end

endmodule
