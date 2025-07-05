`timescale 1ns / 1ps

module top_branch_pipeline(
    input clk,
    input reset,
    input actual_taken
);

    // Fetch/Control wires
    wire [7:0] PC_out, branch_target;
    wire [15:0] instruction;
    wire flush, predict_taken, valid, update;

    // Decode wires
    wire [7:0] write_data;  
    wire [2:0] write_reg;   
    wire RegWrite = 0;            // Not used yet (set to 0)
    wire [1:0] ImmSrc = 2'b00;    // Example immediate source

    wire signed [7:0] read_data1, read_data2;
    wire signed [7:0] imm_out;
    wire [2:0] rs1, rs2, rd;

    
    fetch789 fetch (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(1'b0),  
        .branch_target(branch_target),
        .jump(1'b0),
        .PC_sel(1'b0),  // Static for now
        .predict_taken(predict_taken),
        .instruction(instruction),
        .PC_out(PC_out),
        .valid(valid),
        .update(update)
    );

   
    control_hazard ch (
        .clk(clk),
        .reset(reset),
        .instruction_memory(instruction),
        .branch_target(branch_target),
        .PC_out(PC_out),
        .actual_taken(actual_taken),
        .update(update),
        .predict_taken(predict_taken),
        .flush(flush)
    );

   
    decode decode_stage (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .instruction(instruction),
        .RegWrite(RegWrite),
        .write_reg(write_reg),
        .write_data(write_data),
        .ImmSrc(ImmSrc),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .imm_out(imm_out),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    
    
    wire signed [7:0] alu_result;
    wire zero, branch_taken;

    Execute exe_stage (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .reg1(read_data1),
        .reg2(read_data2),
        .immediate(imm_out),
        .ALUsrc(ALUsrc),  
        .dir(dir),        
        .opcode(instruction[15:12]),
        .forwardA(2'b00),
        .forwardB(2'b00),
        .alu_result_mem(8'b0),
        .write_data_wb(8'b0),
        .alu_result(alu_result),
        .zero(zero),
        .branch_taken(branch_taken)
    );
    

endmodule
