`timescale 1ns/1ps

module register_file(
    input wire clk,
    input wire reset,
    input wire RegWrite,
    input wire [2:0] read_reg1,
    input wire [2:0] read_reg2,
    input wire [2:0] write_reg,
    input wire signed [7:0] write_data,
    output wire signed [7:0] read_data1,
    output wire signed [7:0] read_data2
    );
    
    reg [7:0] regfile [7:0];
    assign read_data1 = regfile[read_reg1];
    assign read_data2 = regfile[read_reg2];
    integer i;
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i = i+1)
                regfile[i] <= 8'b0;
        end
        else if (RegWrite) begin
            regfile[write_reg] <= write_data;
        end
    end        
endmodule
