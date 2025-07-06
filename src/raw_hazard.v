`timescale 1ns / 1ps



module data_memory_hazard(
    input wire EX_MEM_regwrite,
    input wire [2:0] EX_MEM_rd,
    input wire MEM_WB_regwrite,
    input wire [2:0] MEM_WB_rd,
    input wire [2:0] rs1,
    input wire [2:0] rs2,
    input wire clk,
    output reg [1:0] forward_A,
    output reg [1:0] forward_B
);

    always @(posedge clk) begin
        
        if (EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == rs1))
            forward_A = 2'b10;
        else if (MEM_WB_regwrite && (MEM_WB_rd != 0) && (MEM_WB_rd == rs1))
            forward_A = 2'b01;
        else
            forward_A = 2'b00;

       
        if (EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == rs2))
            forward_B = 2'b10;
        else if (MEM_WB_regwrite && (MEM_WB_rd != 0) && (MEM_WB_rd == rs2))
            forward_B = 2'b01;
        else
            forward_B = 2'b00;
    end



  

endmodule
