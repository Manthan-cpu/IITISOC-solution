`timescale 1ns / 1ps

module decode(
    input wire clk,
    input wire reset,
    input wire flush,  
    input wire [15:0] instruction,
    input wire RegWrite,
    input wire [2:0] write_reg,
    input wire [7:0] write_data,  
    input wire [1:0] ImmSrc,

    output reg signed [7:0] read_data1,
    output reg signed [7:0] read_data2,
    output reg signed [7:0] imm_out,
    output reg [2:0] rs1, rs2, rd
);

    
    wire [15:0] instr_in;
    assign instr_in = flush ? 16'b1110000000000000 : instruction;

    wire [3:0] opcode;
    assign opcode = instr_in[15:12];


    reg [2:0] rs1_w, rs2_w, rd_w;
    reg signed [7:0] imm_w;
    wire signed [7:0] imm_gen_out;
    wire signed [7:0] rf_read_data1, rf_read_data2;
    reg signed [7:0] rf_read_data1_d, rf_read_data2_d ;
 
always@(*)begin
if(reset || flush) begin
rf_read_data1_d = 8'sb0 ;
rf_read_data2_d = 8'sb0 ;
end
else begin
rf_read_data1_d = rf_read_data1 ;
rf_read_data2_d = rf_read_data2 ;
end
end

    always @(*) begin
        rs1_w = 3'b0;
        rs2_w = 3'b0;
        rd_w  = 3'b0;
        case (opcode)
            4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: begin
                rs1_w = instr_in[11:9];
                rs2_w = instr_in[8:6];
                rd_w  = instr_in[5:3];
            end
            4'b0110, 4'b0111, 4'b1001: begin
                rs1_w = instr_in[8:6];
                rd_w  = instr_in[11:9];
            end
            4'b1000: begin
                rs1_w = instr_in[8:6];
                rs2_w = instr_in[11:9];
            end
            4'b1010: begin
                rd_w = instr_in[11:9];
            end
            4'b1011, 4'b1100: begin
                rs1_w = instr_in[11:9];
                rs2_w = instr_in[8:6];
            end
        endcase
    end

    
    wire [2:0] rf_rs1 = rs1_w;
    wire [2:0] rf_rs2 = rs2_w;
    
    
always@(posedge clk or posedge reset) begin
 if (reset || flush) begin
  read_data1<= 8'sb0;
   read_data2 <= 8'sb0;
end
end
   
    always @(*) begin
        if (reset || flush) begin
            rs1 = 3'b0;
            rs2 = 3'b0;
            rd  = 3'b0;
            imm_out = 8'sb0;
            end
            end
            
            always@(posedge clk or posedge reset) begin
              if (~reset && ~ flush) 
            rs1 <= rs1_w;
            rs2 <= rs2_w;
            rd  <= rd_w;
            read_data1 <= rf_read_data1_d;
           read_data2 <= rf_read_data2_d;
            imm_out <= imm_gen_out;
        end
 
  
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .read_reg1(rf_rs1),
        .read_reg2(rf_rs2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(rf_read_data1),
        .read_data2(rf_read_data2)
    );

    immediate_generator imm_gen(
        .instruction(instr_in),
        .ImmSrc(ImmSrc),
        .imm_out(imm_gen_out)
    );

endmodule
