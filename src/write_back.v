
`timescale 1ns / 1ps

module writeback_stage(
    input wire ResultSrc,             // 0 = ALU result, 1 = memory data
    input wire [7:0] alu_result,
    input wire [7:0] mem_data,
    output wire [7:0] writeback_data , // Final data to be written to register file
    input wire clk ,
    input wire reset
);
reg ResultSrc_d ;
always@(posedge clk or posedge reset) begin
ResultSrc_d <= ResultSrc ;
end


    assign writeback_data = (ResultSrc_d == 1'b0) ? alu_result : mem_data;

endmodule
