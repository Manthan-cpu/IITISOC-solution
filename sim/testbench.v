`timescale 1ns / 1ps

module top_tb;

    reg clk;
    reg reset;

    // Instantiate the DUT
    top_microprocessor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        #2000;
        $display("=== Simulation Timeout ===");
        $finish;
    end

    always @(posedge clk) begin
        $display("Time=%0t ns", $time);

        // Instruction and PC from fetch stage
        $display("PC     = %0h", uut.datapath.fetch_stage.PC_out);
        $display("Instr  = %h", uut.datapath.fetch_stage.instruction);
        $display("Opcode = %b", uut.datapath.fetch_stage.instruction[15:12]);

        // Register file contents
        $display("Regs   = R0:%0h R1:%0h R2:%0h R3:%0h R4:%0h R5:%0h R6:%0h R7:%0h",
            uut.datapath.decode_stage.reg_file.regfile[0],
            uut.datapath.decode_stage.reg_file.regfile[1],
            uut.datapath.decode_stage.reg_file.regfile[2],
            uut.datapath.decode_stage.reg_file.regfile[3],
            uut.datapath.decode_stage.reg_file.regfile[4],
            uut.datapath.decode_stage.reg_file.regfile[5],
            uut.datapath.decode_stage.reg_file.regfile[6],
            uut.datapath.decode_stage.reg_file.regfile[7]
        );

        // ALU result and memory
        $display("ALU Result = %0h", uut.datapath.execute_stage.alu_result);
        $display("Mem[0] = %0h | Mem[1] = %0h | Mem[10] = %0h",
            uut.datapath.mem_stage.data_mem.data_memory[0],
            uut.datapath.mem_stage.data_mem.data_memory[1],
            uut.datapath.mem_stage.data_mem.data_memory[10]
        );

        // Control signals latched in MEM pipeline register
        $display("Control Signals => RegWrite_MEM=%b | MemRead_MEM=%b | MemWrite_MEM=%b | ResultSrc_MEM=%b | ALUSrc=%b | ImmSrc=%b",
            uut.RegWrite_MEM_reg,
            uut.MemRead_MEM_reg,
            uut.MemWrite_MEM_reg,
            uut.ResultSrc_MEM_reg,
            uut.ALUsrc_reg,
            uut.ImmSrc_reg
        );

        // Stall and halt
        $display("STALL=%b | HALT=%b",
            uut.datapath.stall,
            uut.datapath.halt
        );

        $display("--------------------------------------------------");

        if (uut.datapath.halt) begin
            $display("HALT detected at time %0t. Stopping simulation.", $time);
            $finish;
        end
    end

endmodule
