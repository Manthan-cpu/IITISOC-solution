`timescale 1ns / 1ps


module fetchinstruction(
input wire clk,
    input wire reset,
    input wire stall,                 
    input wire flush,                 
    input wire PC_sel,               
    input wire [7:0] branch_target,   

    output reg [15:0] instruction,   
    output reg [7:0] PC_out,          
    output reg valid                  
);

    
    reg [7:0] PC;

    
    reg [15:0] instruction_memory [0:255];

    initial begin
        
        
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 8'b0;
            PC_out <= 8'b0;
            instruction <= 16'h0000;
            valid <= 1'b0;
        end else if (stall) begin
            
            valid <= 1'b0; 
        end else begin
            
            if (PC_sel)
                PC <= branch_target;
            else
                PC <= PC + 1;

            
            instruction <= flush ? 16'h0000 : instruction_memory[PC];
            PC_out <= PC;
            valid <= ~flush;
        end
    end


  
endmodule
