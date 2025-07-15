`timescale 1ns / 1ps

module memory_stage (
    input wire        clk,
    input wire        reset,
    input wire        MemRead,
    input wire        MemWrite,
    input wire [7:0]  alu_result,           
    input wire [7:0]  write_data,         
    output reg [7:0]  read_data             
);
    reg [7:0] data_memory [0:255];
    integer i;

    // Initialize memory
    initial begin
        for (i = 0; i < 256; i = i + 1)
            data_memory[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (MemWrite)
            data_memory[alu_result] <= write_data;
    end

 
    always @(posedge clk or posedge reset) begin
        if (reset)
            read_data <= 8'b0;
        else if (MemRead)
            read_data <= data_memory[alu_result];
    end

endmodule
