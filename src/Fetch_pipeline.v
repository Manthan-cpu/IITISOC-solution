`timescale 1ns / 1ps

module fetch789(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,
    input wire [7:0] branch_target,
    input wire jump,
    input wire PC_sel,
    input wire predict_taken,

    output reg [15:0] instruction,
    output reg [7:0] PC_out,
    output reg valid,
    output reg update
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
            instruction <= 16'b0;
            valid <= 1'b0;
            halt <= 1'b0;
            update <= 1'b0;
        end 
        
        
        
        else if (!stall && !halt) begin
            instruction <= instruction_memory[PC];
            PC_out <= PC;
            valid <= ~flush;
            update <= 0;




            if (instruction_memory[PC][15:12] == 4'b1111)
                halt <= 1'b1;

            if (jump) begin
                PC <= instruction_memory[PC][11:4];
            end
            else if (PC_sel) begin
                PC <= branch_target;
                update <= 1;
            end
            else if (flush) begin
                PC <= branch_target;
            end
            else if (predict_taken) begin
                PC <= branch_target;
            end
            else begin
                PC <= PC + 1;
            end
        end 
        else begin
            valid <= 1'b0;
        end
    end
    
    
    

endmodule
