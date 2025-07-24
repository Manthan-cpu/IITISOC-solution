`timescale 1ns / 1ps

module datapath_pipelined(
    input wire clk,
    input wire reset,
    output wire stall,
    input wire flush,
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

    output wire [7:0] PC_out_IF,
    output wire [15:0] instruction_IF,
    output wire predict_taken,
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
    wire [2:0] rd_EX, rd_MEM, rd_WB, rd_final;
    wire [7:0] write_data_WB;
    wire RegWrite_final;
    wire ResultSrc_WB;
    wire [1:0] forward_A, forward_B;
    wire valid_IF;

    wire stall_internal;
    wire halt_fetch;

    assign stall = stall_internal;
    assign halt = halt_fetch;

    hazard_detection_unit hazard_unit (
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),
        .rd_EX(rd_EX),
        .MemRead_EX(MemRead_MEM),
        .stall(stall_internal)
    );

    fetch789 fetch_stage (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall_internal),
        .branch_target(branch_target),
        .jump(jump),
        .PC_sel(PC_sel),
        .predict_taken(predict_taken),
        .instruction(instruction_IF),
        .PC_out(PC_out_IF),
        .valid(valid_IF),
        .update(update),
        .halt(halt_fetch)     
    );

    control_hazard control_hazard_unit (
        .branch_target(branch_target),
        .clk(clk),
        .reset(reset),
        .instruction_memory(instruction_IF),
        .update(update),
        .actual_taken(branch_taken_EX),
        .PC_out(PC_out_IF),
        .predict_taken(predict_taken),
        .flush(flush_out)
    );

    // Pipeline register for WB outputs to align register file write
    reg RegWrite_RF;
    reg [2:0] write_reg_RF;
    reg [7:0] write_data_RF;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_RF <= 0;
            write_reg_RF <= 0;
            write_data_RF <= 0;
        end else begin
            RegWrite_RF <= RegWrite_final;
            write_reg_RF <= rd_final;
            write_data_RF <= write_data_WB;
        end
    end

    decode decode_stage (
        .clk(clk),
        .reset(reset),
        .flush(flush_out),
        .instruction(instruction_IF),
        .RegWrite(RegWrite_RF),
        .write_reg(write_reg_RF),
        .write_data(write_data_RF),
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
        if (reset || flush_out) begin
            reg1_EX <= 0;
            reg2_EX <= 0;
            imm_EX <= 0;
            rs1_EX <= 0;
            rs2_EX <= 0;
            rd_EX_reg <= 0;
            opcode_EX <= 0;
            ALUsrc_EX <= 0;
            dir_EX <= 0;
            is_unsigned_EX <= 0;
        end else if (!stall_internal) begin
            reg1_EX <= read_data1_ID;
            reg2_EX <= read_data2_ID;
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

    Execute execute_stage (
        .clk(clk),
        .reset(reset),
        .flush(flush_out),
        .reg1(reg1_EX),
        .reg2(reg2_EX),
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
        .branch_taken(branch_taken_EX)
    );

    data_memory_hazard forward_unit (
        .EX_MEM_regwrite(RegWrite_MEM),
        .EX_MEM_rd(rd_MEM),
        .MEM_WB_regwrite(RegWrite_WB),
        .MEM_WB_rd(rd_WB),
        .rs1(rs1_EX),
        .rs2(rs2_EX),
        .clk(clk),
        .forward_A(forward_A),
        .forward_B(forward_B)
    );

    reg [2:0] rd_MEM_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)
            rd_MEM_reg <= 0;
        else
            rd_MEM_reg <= rd_EX;
    end

    assign rd_MEM = rd_MEM_reg;

    stage_MEM mem_stage (
        .clk(clk),
        .reset(reset),
        .MemRead_MEM(MemRead_MEM),
        .MemWrite_MEM(MemWrite_MEM),
        .ResultSrc_MEM(ResultSrc_MEM),
        .RegWrite_MEM(RegWrite_MEM),
        .rd_MEM(rd_MEM),
        .alu_result_MEM(alu_result_EX),
        .write_data_MEM(reg2_EX),
        .mem_data_out(mem_data_WB),
        .alu_result_out(alu_result_MEM),
        .ResultSrc_WB(ResultSrc_WB),
        .RegWrite_WB(RegWrite_WB),
        .rd_WB(rd_WB)
    );

    stage_WB writeback_stage (
        .clk(clk),
        .reset(reset),
        .RegWrite_WB(RegWrite_WB),
        .ResultSrc_WB(ResultSrc_WB),
        .alu_result_WB(alu_result_MEM),
        .mem_data_WB(mem_data_WB),
        .rd_WB(rd_WB),
           .RegWrite_final(RegWrite_final),
        .write_data_WB(write_data_WB),
        .rd_final(rd_final)
    );

endmodule
