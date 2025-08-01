`timescale 1ns / 1ps

module control_hazard(
    input wire Branch,
    input wire Jump,
    input wire clk,
    input wire reset,
    input wire branch_taken,
    output reg flush
);
 
always@(*) begin 
        
    if (( branch_taken) || Jump) begin
        flush = 1'b1;
        end
    else begin
        flush = 1'b0;
        end
    end

endmodule
