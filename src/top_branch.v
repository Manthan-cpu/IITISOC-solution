`timescale 1ns / 1ps

module top_microprocessor(
    input wire clk,
    input wire reset
);

  
    wire stall, flush, jump, PC_sel, ALUsrc, MemRead_MEM, MemWrite_MEM;
    wire RegWrite_MEM, ResultSrc_MEM, RegWrite_WB, dir;
    wire [7:0] branch_target;
    wire [1:0] ImmSrc;
    wire [3:0] opcode;

   
    wire [7:0] PC_out_IF;
    wire [15:0] instruction_IF;
    wire predict_taken, flush_out, update;

   
    wire ResultSrc, MemRead, MemWrite, RegWrite, Branch, Jump;
    
  
    reg ResultSrc_MEM_reg, MemRead_MEM_reg, MemWrite_MEM_reg, RegWrite_MEM_reg, ResultSrc_WB_reg, RegWrite_WB_reg;
    reg [1:0] ImmSrc_reg;
    reg ALUsrc_reg, Branch_reg, Jump_reg, dir_reg;
    reg [3:0] opcode_reg;

  
    reg [7:0] branch_target_reg;
    
    control_unit control_unit_inst (
        .opcode(opcode),
        .stall(stall),
        .flush(flush_out),
        .ResultSrc(ResultSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUsrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .Jump(Jump)
    );

 
    always @(posedge clk or posedge reset) begin
        if (reset || flush_out) begin
            ResultSrc_MEM_reg <= 0;
            MemRead_MEM_reg   <= 0;
            MemWrite_MEM_reg  <= 0;
            RegWrite_MEM_reg  <= 0;
            ImmSrc_reg        <= 0;
            ALUsrc_reg        <= 0;
            Branch_reg        <= 0;
            Jump_reg          <= 0;
            dir_reg           <= 0;
            opcode_reg        <= 0;
            branch_target_reg <= 0;
        end else if (!stall) begin
            ResultSrc_MEM_reg <= ResultSrc;
            MemRead_MEM_reg   <= MemRead;
            MemWrite_MEM_reg  <= MemWrite;
            RegWrite_MEM_reg  <= RegWrite;
            ImmSrc_reg        <= ImmSrc;
            ALUsrc_reg        <= ALUsrc;
            Branch_reg        <= Branch;
            Jump_reg          <= Jump;
            dir_reg           <= dir;
            opcode_reg        <= opcode;
            branch_target_reg <= branch_target;
        end
    end

  
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ResultSrc_WB_reg <= 0;
            RegWrite_WB_reg  <= 0;
        end else begin
            ResultSrc_WB_reg <= ResultSrc_MEM_reg;
            RegWrite_WB_reg  <= RegWrite_MEM_reg;
        end
    end

  
    datapath_pipelined datapath (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush_out),
        .jump(Jump_reg),
        .PC_sel(Branch_reg), // PC_sel can be driven by Branch
        .branch_target(branch_target_reg),
        .ImmSrc(ImmSrc_reg),
        .ALUsrc(ALUsrc_reg),
        .MemRead_MEM(MemRead_MEM_reg),
        .MemWrite_MEM(MemWrite_MEM_reg),
        .RegWrite_MEM(RegWrite_MEM_reg),
        .ResultSrc_MEM(ResultSrc_MEM_reg),
        .RegWrite_WB(RegWrite_WB_reg),
        .opcode(opcode_reg),
        .dir(dir_reg),
        .PC_out_IF(PC_out_IF),
        .instruction_IF(instruction_IF),
        .predict_taken(predict_taken),
        .flush_out(flush_out),
        .update(update)
    );

   

endmodule
