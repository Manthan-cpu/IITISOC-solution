`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg reset;

    top_microprocessor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        #300;
        $display("=== Simulation Timeout ===");
        $finish;
    end

    always @(posedge clk) begin
        $display("Time=%0t ns", $time);
        $display("================ PIPELINE STATE ================");
  
        $display("[FETCH]   PC=%0h | Instr=%h | Opcode=%b",
            uut.datapath.fetch_stage.PC_out,
            uut.datapath.fetch_stage.instruction,
            uut.datapath.fetch_stage.instruction[15:12]);

        $display("          read_data1=%0d | read_data2=%0d | imm_out=%0d",
            uut.datapath.decode_stage.rf_read_data1,
            uut.datapath.decode_stage.rf_read_data2,
            uut.datapath.decode_stage.imm_out);


        $display("[EXECUTE] ALU Result=%0d | Zero=%b | branch_taken=%b",
            uut.datapath.execute_stage.alu_result,
            uut.datapath.execute_stage.zero,
            uut.datapath.execute_stage.branch_taken);

 
        $display("[MEM]     Mem[0]=%0d | Mem[1]=%0d | Mem[2]=%0d | Mem[100]=%0d | Mem[104]=%0d | Mem[108]=%0d",
            uut.datapath.mem_stage.data_mem.data_memory[0],
            uut.datapath.mem_stage.data_mem.data_memory[1],
            uut.datapath.mem_stage.data_mem.data_memory[2],
            uut.datapath.mem_stage.data_mem.data_memory[100],
            uut.datapath.mem_stage.data_mem.data_memory[104],
            uut.datapath.mem_stage.data_mem.data_memory[108]);


        $display("[WB]      write_data=%0d | RegWrite=%b | rd=%0d",
            uut.datapath.writeback_stage.write_data_WB,
            uut.datapath.writeback_stage.RegWrite_final,
            uut.datapath.writeback_stage.rd_final);

 
        $display("[REGS]    R0:%0d R1:%0d R2:%0d R3:%0d R4:%0d R5:%0d R6:%0d R7:%0d",
            uut.datapath.decode_stage.reg_file.regfile[0],
            uut.datapath.decode_stage.reg_file.regfile[1],
            uut.datapath.decode_stage.reg_file.regfile[2],
            uut.datapath.decode_stage.reg_file.regfile[3],
            uut.datapath.decode_stage.reg_file.regfile[4],
            uut.datapath.decode_stage.reg_file.regfile[5],
            uut.datapath.decode_stage.reg_file.regfile[6],
            uut.datapath.decode_stage.reg_file.regfile[7]);


        $display("[CTRL]    RegWrite_MEM=%b | MemRead_MEM=%b | MemWrite_MEM=%b | ResultSrc_MEM=%b | ALUSrc=%b | ImmSrc=%b",
            uut.RegWrite_MEM_reg,
            uut.MemRead_MEM_reg,
            uut.MemWrite_MEM_reg,
            uut.ResultSrc_MEM_reg,
            uut.ALUsrc_reg,
            uut.ImmSrc_reg);


        $display("[CTRL]    STALL=%b | HALT=%b",
            uut.datapath.stall,
            uut.datapath.halt);

        $display("--------------------------------------------------");

        if (uut.datapath.halt) begin
            $display("HALT detected at time %0t. Stopping simulation.", $time);
            $finish;
        end
    end

endmodule
