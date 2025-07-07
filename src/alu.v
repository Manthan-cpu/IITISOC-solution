`timescale 1ns / 1ps

module alu (
  input  wire signed [7:0] a,             // Operand A (signed)
  input  wire signed [7:0] b,             // Operand B or Immediate (signed)
  input  wire [3:0]        opcode,        // 4-bit opcode
  input  wire              dir,           // Shift direction (0 = left, 1 = right)
  input  wire              is_unsigned,   // 1 = unsigned, 0 = signed
  output reg signed [7:0]  result,        // ALU Result
  output wire              zero,          // Zero flag
  output reg               branch_taken   // Branch control
);

  // Unsigned  operands
  wire [7:0] ua = a;
  wire [7:0] ub = b;

  // Zero flag
  assign zero = (result == 8'b00000000);

  always @(*) begin
    result = 8'b0;
    branch_taken = 1'b0;

    case (opcode)
      // ADD (signed or unsigned)
      4'b0000: result = is_unsigned ? (ua + ub) : (a + b);

      // SUB (signed or unsigned)
      4'b0001: result = is_unsigned ? (ua - ub) : (a - b);

      // AND
      4'b0010: result = a & b;

      // OR
      4'b0011: result = a | b;

      // XOR
      4'b0100: result = a ^ b;

      // SLT (signed or unsigned comparison)
      4'b0101: result = is_unsigned ? ((ua < ub) ? 8'd1 : 8'd0)
                                    : ((a  <  b) ? 8'd1 : 8'd0);

      // SHIFT (with dir and is_unsigned)
      4'b0110: begin
        if (dir == 1'b0)
          result = a << b[2:0];                     // Left shift (same for signed/unsigned)
        else
          result = is_unsigned ? (ua >> b[2:0])     // Logical right shift
                               : (a >>> b[2:0]);    // Arithmetic right shift
      end

      // LOAD  (always unsigned)
      4'b0111: result = ua + ub;

      // STORE  (always unsigned)
      4'b1000: result = ua + ub;

      // ADDI 
      4'b1001: result = is_unsigned ? (ua + ub) : (a + b);

      // LDI 
      4'b1010: result = b;

      // BEQ (signed comparison only)
      4'b1011: begin
        result = a - b;
        branch_taken = (result == 0);
      end

      // BNE (signed comparison only)
      4'b1100: begin
        result = a - b;
        branch_taken = (result != 0);
      end

      // JMP 
           4'b1101: result = ua + ub;

      // NOP/HLT
      default: result = 8'b00000000;
    endcase
  end
endmodule
