
`timescale 1ns / 1ps

module stage_WB (
    input  wire        clk,
    input  wire        reset,
    input  wire        RegWrite_WB,     
    input  wire        ResultSrc_WB,    
    input  wire [7:0]  alu_result_WB,   
    input  wire [7:0]  mem_data_WB,     
    input  wire [2:0]  rd_WB,          

    output reg         RegWrite_final,  
    output reg  [7:0]  write_data_WB,   
    output reg  [2:0]  rd_final       
);

    wire [7:0] wb_data_mux;
    writeback_stage wb_mux (
        .ResultSrc(ResultSrc_WB),
        .alu_result(alu_result_WB),
        .mem_data(mem_data_WB),
        .writeback_data(wb_data_mux)
    );
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_final <= 1'b0;
            write_data_WB <= 8'b0;
            rd_final <= 3'b0;
        end else begin
            RegWrite_final <= RegWrite_WB;
            write_data_WB <= wb_data_mux;
            rd_final <= rd_WB;
        end
    end

endmodule
