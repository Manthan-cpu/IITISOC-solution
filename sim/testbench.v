`timescale 1ns / 1ps

module tb_top_module;

    reg clk;
    reg reset;

    // Memory snapshot for detecting changes
    reg [7:0] mem_snapshot [0:255];
    integer i;

    // Instantiate the top-level module
    top uut (
        .clk(clk),
        .reset(reset)
        // Add connections if needed
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Simulation setup
    initial begin
        clk = 0;
        reset = 1;

        // Apply reset for 20 ns
        #20;
        reset = 0;

        // Wait a little and take initial snapshot
        #1;
        for (i = 0; i < 256; i = i + 1) begin
            mem_snapshot[i] = uut.dp.mem_stage.data_memory[i];
        end
    end

    // Monitor internal states + control signals
    always @(posedge clk) begin
        $display("Time=%0t | PC=%02h | Instr=%04h | R0=%02h | R1=%02h | R2=%02h | R3=%02h | R4=%02h | R5=%02h | R6=%02h | R7=%02h | ALU=%02h | Mem[0]=%02h | Mem[1]=%02h", 
            $time,
            uut.dp.PC_out,
            uut.dp.instruction,
            uut.dp.reg_file.regfile[0],
            uut.dp.reg_file.regfile[1],
            uut.dp.reg_file.regfile[2],
            uut.dp.reg_file.regfile[3],
            uut.dp.reg_file.regfile[4],
            uut.dp.reg_file.regfile[5],
            uut.dp.reg_file.regfile[6],
            uut.dp.reg_file.regfile[7],
            uut.dp.alu_result,
            uut.dp.mem_stage.data_memory[0],
            uut.dp.mem_stage.data_memory[1]
        );

        // Show control signals
        $display("CTRL => ResultSrc: %b | MemRead: %b | MemWrite: %b | ALUSrc: %b | ImmSrc: %b | RegWrite: %b | Branch: %b | Jump: %b | PCSrc: %b | Opcode: %b\n",
            uut.ResultSrc,
            uut.MemRead,
            uut.MemWrite,
            uut.ALUSrc,
            uut.ImmSrc,
            uut.RegWrite,
            uut.Branch,
            uut.Jump,
            uut.PCSrc,
            uut.opcode
        );

        if (uut.dp.instruction[15:12] == 4'b1111) begin
            $display("\nHALT instruction executed at time %0t. Stopping simulation.", $time);
            $display("Simulation complete.");
            $finish;
        end
    end

    // Detect memory content changes
    always @(posedge clk) begin
        for (i = 0; i < 256; i = i + 1) begin
            if (uut.dp.mem_stage.data_memory[i] !== mem_snapshot[i]) begin
                $display("Time=%0t | Mem[%0d] changed: %02h -> %02h", 
                         $time, i, mem_snapshot[i], uut.dp.mem_stage.data_memory[i]);
                mem_snapshot[i] = uut.dp.mem_stage.data_memory[i];
            end
        end
    end

  
    always @(posedge clk) begin
        if (uut.dp.instruction[15:12] == 4'b0111) begin  // LOAD
            $display("\n--- LOAD Instruction Debug @ %0t ns ---", $time);
            $display("Dest Reg       : R%0d", uut.dp.instruction[11:9]);
            $display("Base Reg (R%0d): %0h", uut.dp.instruction[8:6], uut.dp.reg_file.regfile[uut.dp.instruction[8:6]]);
            $display("Offset         : %0d", uut.dp.instruction[5:0]);
            $display("Effective Addr : %0d", uut.dp.alu_result);
            $display("Mem[EA]        : %0h", uut.dp.mem_stage.data_memory[uut.dp.alu_result]);
            $display("RegWrite       : %b", uut.dp.RegWrite);
            $display("ResultSrc      : %b", uut.dp.ResultSrc);
            $display("WriteData      : %0h", uut.dp.WriteData);  // What will go into Rdest
            $display("----------------------------------------\n");
        end
    end

endmodule
