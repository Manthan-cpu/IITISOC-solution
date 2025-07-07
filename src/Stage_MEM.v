`timescale 1ns / 1ps

module stage_MEM (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        MemRead_MEM,
    input  wire        MemWrite_MEM,
    input  wire        ResultSrc_MEM,     
    input  wire        RegWrite_MEM,      
    input  wire [2:0]  rd_MEM,            
    input  wire [7:0]  alu_result_MEM,    
    input  wire [7:0]  write_data_MEM,    
    
    output wire [7:0]  mem_data_out,      
    output wire [7:0]  alu_result_out,    
    output wire        ResultSrc_WB,      
    output wire        RegWrite_WB,      
    output wire [2:0]  rd_WB              
);

  
    memory_stage data_mem (
        .clk(clk),
        .reset(reset),
        .MemRead(MemRead_MEM),
        .MemWrite(MemWrite_MEM),
        .alu_result(alu_result_MEM),     
        .write_data(write_data_MEM),     
        .read_data(mem_data_out)        
    );

    assign alu_result_out = alu_result_MEM;

    assign ResultSrc_WB  = ResultSrc_MEM;
    assign RegWrite_WB   = RegWrite_MEM;
    assign rd_WB         = rd_MEM;

endmodule

