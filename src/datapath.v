`timescale 1ns / 1ps

module datapath_pipelined(
    input wire clk,
    input wire reset,
    output wire stall,
    input wire jump,
    input wire PC_sel,
    input wire [7:0] branch_target,
    input wire [1:0] ImmSrc,
    input wire ALUsrc,
    input wire MemRead_MEM,
    input wire MemWrite_MEM,
    input wire RegWrite_MEM,
    input wire ResultSrc_MEM,
    input wire RegWrite_WB,
    input wire [3:0] opcode,
    input wire dir,
    input wire is_unsigned,
    input wire Branch,
    output wire [7:0] PC_out_IF,
    output wire [15:0] instruction_IF,
    output wire flush_out,
    output wire update,
    output wire halt       
);

    wire signed [7:0] read_data1_ID, read_data2_ID;
    wire signed [7:0] imm_out_ID;
    wire [2:0] rs1_ID, rs2_ID, rd_ID;
    wire signed [7:0] alu_result_EX;
    wire zero_EX, branch_taken_EX;
    wire signed [7:0] mem_data_WB, alu_result_MEM;
    wire [2:0] rd_EX, rd_MEM, rd_WB,rd_WB_d, rd_final;
    wire [7:0] write_data_WB;
    wire RegWrite_final;
    wire ResultSrc_WB;
    wire [1:0] forward_A, forward_B;
    wire valid_IF;
    wire flush;
    wire stall_internal;
    wire halt_fetch;
    wire [7:0]mem_read_ex ;
    wire [1:0]forward_AL ;
    wire [1:0]forward_BL;
    wire Regwrite_WB;

    assign stall = stall_internal;
    assign halt = halt_fetch;

    hazard_detection_unit hazard_detection_unit(
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),
        .rd_EX(rd_EX),
        .MemRead_EX(MemRead_MEM),
        .stall(stall_internal)
    );

    fetch789 fetch_stage(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall_internal),
        .branch_target(imm_out_ID),
        .jump(jump),
        .PC_sel(PC_sel),
        .instruction(instruction_IF),
        .PC_out(PC_out_IF),
        .valid(valid_IF),
        .update(update),
        .halt(halt_fetch)     
    );

    control_hazard control_hazard_unit(
        .Branch(Branch),
        .clk(clk),
        .reset(reset),
        .Jump(jump),
        .branch_taken(branch_taken),
        .flush(flush)
    );
    
    assign flush_out = flush;

    decode decode_stage(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .instruction(instruction_IF),
        .RegWrite(RegWrite_final),
        .write_reg(rd_final),
        .write_data(write_data_WB),
        .ImmSrc(ImmSrc),
        .read_data1(read_data1_ID),
        .read_data2(read_data2_ID),
        .imm_out(imm_out_ID),
        .rs1(rs1_ID),
        .rs2(rs2_ID),
        .rd(rd_ID)
    );

    reg signed [7:0] reg1_EX, reg2_EX, imm_EX;
    reg [2:0] rs1_EX, rs2_EX;
    reg [2:0] rd_EX_reg;
    reg [3:0] opcode_EX;
    reg ALUsrc_EX, dir_EX;
    reg is_unsigned_EX;

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            imm_EX <= 0;
            rs1_EX <= 0;
            rs2_EX <= 0;
            rd_EX_reg <= 0;
            opcode_EX <= 0;
            ALUsrc_EX <= 0;
            dir_EX <= 0;
            is_unsigned_EX <= 0;
        end
        
        else if (!stall_internal) begin
            imm_EX <= imm_out_ID;
            rs1_EX <= rs1_ID;
            rs2_EX <= rs2_ID;
            rd_EX_reg <= rd_ID;
            opcode_EX <= opcode;
            ALUsrc_EX <= ALUsrc;
            dir_EX <= dir;
            is_unsigned_EX <= is_unsigned;
        end
    end

    assign rd_EX = rd_EX_reg;

    Execute execute_stage(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .reg1(read_data1_ID),
        .reg2(read_data2_ID),
        .immediate(imm_EX),
        .ALUsrc(ALUsrc_EX),
        .dir(dir_EX),
        .opcode(opcode_EX),
        .forward_A(forward_A),
        .forward_B(forward_B),
        .alu_result_mem(alu_result_MEM),
        .write_data_wb(write_data_WB),
        .is_unsigned(is_unsigned_EX),
        .alu_result(alu_result_EX),
        .zero(zero_EX),
        .branch_taken(branch_taken),
        .mem_read_ex (mem_read_ex),
        .forward_AL(forward_AL),
        .forward_BL(forward_BL),
        .ResultSrc_MEM(ResultSrc_MEM) 
    );

     
    data_memory_hazard forward_unit(
        .EX_MEM_regwrite(RegWrite_MEM),
        .EX_MEM_rd(rd_MEM),
        .MEM_WB_regwrite(RegWrite_WB),
        .MEM_WB_rd(rd_WB_d),
        .rs1(rs1_EX),
        .rs2(rs2_EX),
        .clk(clk),
        .forward_A(forward_A),
        .forward_B(forward_B),
        .forward_AL(forward_AL),
        .forward_BL(forward_BL),
        .ResultSrc_MEM(ResultSrc_MEM)
    );


    reg [2:0] rd_MEM_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            rd_MEM_reg <= 0;
        else
            rd_MEM_reg <= rd_EX;
    end

    assign rd_MEM = rd_MEM_reg;

    stage_MEM mem_stage(
        .clk(clk),
        .reset(reset),
        .MemRead_MEM(MemRead_MEM),
        .MemWrite_MEM(MemWrite_MEM),
        .ResultSrc_MEM(ResultSrc_MEM),
        .RegWrite_MEM(RegWrite_MEM),
        .rd_MEM(rd_MEM),
        .alu_result_MEM(alu_result_EX),
        .write_data_MEM(read_data2_ID),
        .mem_data_out(mem_data_WB),
        .alu_result_out(alu_result_MEM),
        .ResultSrc_WB(ResultSrc_WB),
        .Regwrite_WB(Regwrite_WB),
        .rd_WB(rd_WB),
        .rd_WB_d(rd_WB_d),
        .forward_B(forward_B),
       .mem_read_ex(mem_read_ex)
    );


    stage_WB writeback_stage(
        .clk(clk),
        .reset(reset),
        .RegWrite_WB(Regwrite_WB),
        .ResultSrc_WB(ResultSrc_WB),
        .alu_result_WB(alu_result_MEM),
        .mem_data_WB(mem_data_WB),
        .rd_WB(rd_WB),
           .RegWrite_final(RegWrite_final),
        .write_data_WB(write_data_WB),
        .rd_final(rd_final)
    );

endmodule
