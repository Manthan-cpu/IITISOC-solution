`timescale 1ns / 1ps

module stage_WB (
    input  wire        RegWrite_WB,     
    input  wire        ResultSrc_WB,    
    input  wire [7:0]  alu_result_WB,   
    input  wire [7:0]  mem_data_WB,     
    input  wire [2:0]  rd_WB,           

    output wire        RegWrite_final,  
    output wire [7:0]  write_data_WB,   
    output wire [2:0]  rd_final      
);
    writeback_stage wb_mux (
        .ResultSrc(ResultSrc_WB),
        .alu_result(alu_result_WB),
        .mem_data(mem_data_WB),
        .writeback_data(write_data_WB)
    );

    assign RegWrite_final = RegWrite_WB;
    assign rd_final       = rd_WB;

endmodule
