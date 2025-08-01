`timescale 1ns / 1ps



module memory_stage(
    input wire        clk,
    input wire        reset,
    input wire        MemRead,
    input wire        MemWrite,
    input wire [7:0]  alu_result,   
    input wire [1:0]  forward_B,        
    input wire [7:0]  write_data,        
    output reg [7:0]  read_data
);

    reg [7:0] data_memory [0:255];
    reg  MemWrite_d;
    reg[7:0] alu_result_dd;
    reg[7:0] alu_result_d;
    reg  MemWrite_dd;
    reg [7:0] write_data_r;
    reg[7:0] write_data_r_d;
    integer i;
    reg[1:0] forward_Bd;
    reg[7:0] alu_result_e;

    always@(posedge clk or posedge reset)begin
    if(reset) begin
        alu_result_d <= 0;
        forward_Bd <= 0;
        alu_result_dd <= 8'b0;
    end

    else begin  
        alu_result_d <=  alu_result ; 
        forward_Bd <= forward_B ;
        alu_result_dd <=  alu_result_d ; 
    end
    end


    always @(*) begin
    case(forward_Bd)
        2'b10: begin write_data_r = alu_result_dd ;end
        default: begin write_data_r = write_data; end
    endcase
    end

    always @(posedge clk or posedge reset) begin
       if(reset) begin
         MemWrite_d <= 0;
        MemWrite_dd <=0;
       end
       
       else begin
       MemWrite_d <= MemWrite;
        MemWrite_dd <= MemWrite_d;
       end
    end

    initial begin
        for (i = 0; i < 256; i = i + 1)
            data_memory[i] = 8'h00;
    end
    
    always @(posedge clk) begin
    write_data_r_d<=write_data_r;
        if (MemWrite_dd)
            data_memory[alu_result_d] <= write_data_r;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            read_data <= 8'b0;
        else if (MemRead)
            read_data <= data_memory[alu_result];
    end

endmodule
