
`timescale 1ns / 1ps

module fetch789(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire stall,
    input wire [7:0] branch_target,
    input wire jump,
    input wire PC_sel,
    input wire halt,
    output reg [15:0] instruction,
    output reg [7:0] PC_out,
    output reg valid,
    output reg update
);

    reg [7:0] PC;
    reg [7:0] branch_target_d;
   
    reg [15:0] instruction_memory [0:255];

    initial begin
        $readmemb("instructions.mem", instruction_memory);
    end
    
    always @(posedge clk or posedge reset) begin
    branch_target_d <= branch_target;
        if (reset) begin
            PC <= 8'b0;
            PC_out <= 8'b0;
            instruction <= 16'b0;
            valid <= 1'b0;
            update <= 1'b0;
        end 
        
        
       
        else if (!stall ) begin
            instruction <= instruction_memory[PC];
            PC_out <= PC;
            valid <= ~flush;
            update <= 0;


            if (flush) begin
                PC <= branch_target_d;
                instruction <= 16'b1110000000000000 ;
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
