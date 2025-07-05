`timescale 1ns / 1ps

module control_hazard(
    input wire [7:0] branch_target,
    input wire clk,
    input wire reset,
    input wire [15:0] instruction_memory,
    input wire update,
    input wire actual_taken,              
    output reg [7:0] PC_out,
    output reg predict_taken,
    output reg flush
);

   
    

   
    reg [1:0] prediction_table[0:15];

    wire [3:0] index;
    assign index = PC_out[3:0];  

    
    localparam STRONG_NOT_TAKEN = 2'b00;
    localparam WEAK_NOT_TAKEN   = 2'b01;
    localparam WEAK_TAKEN       = 2'b10;
    localparam STRONG_TAKEN     = 2'b11;

    
    always @(*) begin
        case (prediction_table[index])
            STRONG_NOT_TAKEN,
            WEAK_NOT_TAKEN: predict_taken = 0;
            WEAK_TAKEN,
            STRONG_TAKEN:   predict_taken = 1;
        endcase
    end

    
    always @(*) begin
        if (((prediction_table[index] == STRONG_NOT_TAKEN || prediction_table[index] == WEAK_NOT_TAKEN) && actual_taken) ||
            ((prediction_table[index] == STRONG_TAKEN || prediction_table[index] == WEAK_TAKEN) && !actual_taken)) begin
            flush = 1;
        end else begin
            flush = 0;
        end
    end

   
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1)
                prediction_table[i] <= WEAK_NOT_TAKEN;  // Initialize to weakly not taken
        end else if (update) begin
            case (prediction_table[index])
                STRONG_NOT_TAKEN: prediction_table[index] <= actual_taken ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
                WEAK_NOT_TAKEN:   prediction_table[index] <= actual_taken ? WEAK_TAKEN     : STRONG_NOT_TAKEN;
                WEAK_TAKEN:       prediction_table[index] <= actual_taken ? STRONG_TAKEN   : WEAK_NOT_TAKEN;
                STRONG_TAKEN:     prediction_table[index] <= actual_taken ? STRONG_TAKEN   : WEAK_TAKEN;
            endcase
        end
    end

endmodule
