`timescale 1ns / 1ps

module control_unit(
    input [3:0] opcode,
    output reg PCSrc,
    output reg ResultSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg RegWrite,
    output reg Branch,
    output reg Jump
    );
    
    always@(*) begin
        PCSrc = 0; ResultSrc = 0; MemRead = 0;
        MemWrite = 0; ALUSrc = 0; ImmSrc = 2'b11;
        RegWrite = 0; Branch = 0; Jump = 0;
        
        case (opcode)
        
            4'b0000, 4'b0001, 4'b0010,
            4'b0011, 4'b0100, 4'b0101: RegWrite = 1;
            
            4'b0110: begin
                ImmSrc = 2'b10; RegWrite = 1; ALUSrc = 1;
            end
            
            4'b0111: begin
                ResultSrc = 1; MemRead = 1; ALUSrc = 1;
                ImmSrc = 2'b01; RegWrite = 1;
            end
            
            4'b1000: begin
                MemWrite = 1; ALUSrc = 1; ImmSrc = 2'b01;
            end
            
            4'b1001, 4'b1010: begin
                ALUSrc = 1; ImmSrc = 2'b01; RegWrite = 1;
           end
           
           4'b1011, 4'b1100: begin
                ImmSrc = 2'b01; Branch = 1;
           end
           
           4'b1101: begin
                PCSrc = 1; ImmSrc = 2'b00; Jump = 1;
           end
           
           4'b1110, 4'b1111: begin
           end
        
        endcase
    end  
endmodule
