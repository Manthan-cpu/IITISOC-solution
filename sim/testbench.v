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
    always #2 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        reset = 1;
        #8;
        reset = 0;

        #2000;
        $display("=== Simulation Timeout ===");
        $finish;
    end

    always @(posedge clk) begin
        $display("Time=%0t ns", $time);
        $display("================ PIPELINE STATE ================");
        // FETCH STAGE
        $display("[FETCH]   PC=%0h | Instr=%h | Opcode=%b",
            uut.datapath.fetch_stage.PC_out,
            uut.datapath.fetch_stage.instruction,
            uut.datapath.fetch_stage.instruction[15:12]);

        // DECODE STAGE
        // $display("[DECODE]  PC=%0h | Instr=%h | Opcode=%b | rs1=%0d | rs2=%0d | rd=%0d",
        //     uut.datapath.decode_stage.PC_out, // If available
        //     uut.datapath.decode_stage.instruction, // If available
        //     uut.datapath.decode_stage.instruction[15:12], // If available
        //     uut.datapath.decode_stage.rs1,
        //     uut.datapath.decode_stage.rs2,
        //     uut.datapath.decode_stage.rd);
        $display("          read_data1=%0d | read_data2=%0d | imm_out=%0d",
            uut.datapath.decode_stage.rf_read_data1,
            uut.datapath.decode_stage.rf_read_data2,
            uut.datapath.decode_stage.imm_out);

        // EXECUTE STAGE
        $display("[EXECUTE] ALU Result=%0d | Zero=%b | branch_taken=%b",
            uut.datapath.execute_stage.alu_result,
            uut.datapath.execute_stage.zero,
            uut.datapath.execute_stage.branch_taken);

        // MEMORY STAGE
        $display("[MEM]     Mem[0]=%0d | Mem[1]=%0d | Mem[2]=%0d |Mem[108]=%0d",
            uut.datapath.mem_stage.data_mem.data_memory[0],
            uut.datapath.mem_stage.data_mem.data_memory[1],
            uut.datapath.mem_stage.data_mem.data_memory[2],
             uut.datapath.mem_stage.data_mem.data_memory[108]);

        // WRITE-BACK STAGE
        $display("[WB]      write_data=%0d | RegWrite=%b | rd=%0d",
            uut.datapath.writeback_stage.write_data_WB,
            uut.datapath.writeback_stage.RegWrite_final,
            uut.datapath.writeback_stage.rd_final);

        // Register file contents
        $display("[REGS]    R0:%0d R1:%0d R2:%0d R3:%0d R4:%0d R5:%0d R6:%0d R7:%0d",
            uut.datapath.decode_stage.reg_file.regfile[0],
            uut.datapath.decode_stage.reg_file.regfile[1],
            uut.datapath.decode_stage.reg_file.regfile[2],
            uut.datapath.decode_stage.reg_file.regfile[3],
            uut.datapath.decode_stage.reg_file.regfile[4],
            uut.datapath.decode_stage.reg_file.regfile[5],
            uut.datapath.decode_stage.reg_file.regfile[6],
            uut.datapath.decode_stage.reg_file.regfile[7]);

        // Control signals (example: MEM stage)
        $display("[CTRL]    RegWrite_MEM=%b | MemRead_MEM=%b | MemWrite_MEM=%b | ResultSrc_MEM=%b | ALUSrc=%b | ImmSrc=%b",
            uut.RegWrite_MEM_reg,
            uut.MemRead_MEM_reg,
            uut.MemWrite_MEM_reg,
            uut.ResultSrc_MEM_reg,
            uut.ALUsrc_reg,
            uut.ImmSrc_reg);

        // Stall and halt
        $display("[CTRL]    STALL=%b | HALT=%b",
            uut.datapath.stall,
            uut.datapath.halt);

        $display("--------------------------------------------------");

//        if (uut.datapath.halt) begin
//            $display("HALT detected at time %0t. Stopping simulation.", $time);
//            $finish;
        end
    

endmodule



