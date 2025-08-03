`timescale 1ns / 1ps

module stage_MEM(
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,
    input  wire        MemRead_MEM,
    input  wire        MemWrite_MEM,
    input  wire        ResultSrc_MEM,
    input  wire        RegWrite_MEM,
    input  wire [2:0]  rd_MEM,
    input wire [1:0] forward_B,
    input  wire [7:0]  alu_result_MEM,
    input  wire [7:0]  write_data_MEM,
    output reg [7:0]   mem_data_out,
    output reg [7:0]   alu_result_out,
    output reg         ResultSrc_WB,
    output reg         Regwrite_WB,
    output wire [2:0]   rd_WB,
    output reg [2:0] rd_WB_d,
    output reg [7:0]   mem_read_ex
    );

   wire [7:0] mem_read_data ;

    always@(*) begin 
        mem_read_ex = mem_read_data ;
    end

    memory_stage data_mem (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .MemRead(MemRead_MEM),
        .MemWrite(MemWrite_MEM),
        .alu_result(alu_result_MEM),
        .write_data(write_data_MEM),
        .read_data(mem_read_data),
        .forward_B(forward_B)
    );

    assign  rd_WB = rd_MEM;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
//            mem_data_out   <= 8'b0;
            alu_result_out <= 8'b0;
            ResultSrc_WB   <= 1'b0;
            Regwrite_WB    <= 1'b0;
            rd_WB_d         <= 3'b000;
        end
        
        else begin
//            mem_data_out   <= mem_read_data;
            alu_result_out <= alu_result_MEM;
            ResultSrc_WB   <= ResultSrc_MEM;
            Regwrite_WB    <= RegWrite_MEM;
            rd_WB_d        <= rd_MEM;
        end
    end
       always @(*)
       begin
       mem_data_out   = mem_read_data ;
       end

endmodule
