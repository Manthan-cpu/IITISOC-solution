module tb_top_module;

    reg clk;
    reg reset;
  
    top uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #20;
        reset = 0;

        #500;

        $display("Simulation complete.");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | R0=%h | R1=%h | R2=%h | R3=%h | R4=%h | R5=%h | R6=%h | R7=%h | ALU=%h | Mem[0]=%h | Mem[1]=%h", 
            $time,
            uut.dp.PC_out,                        
            uut.dp.instruction,                   // Fetched instruction
            uut.dp.reg_file.regfile[0],           // Register 0
            uut.dp.reg_file.regfile[1],           // Register 1
            uut.dp.reg_file.regfile[2],           // Register 2
            uut.dp.reg_file.regfile[3],           // Register 3
            uut.dp.reg_file.regfile[4],           // Register 4
            uut.dp.reg_file.regfile[5],           // Register 5
            uut.dp.reg_file.regfile[6],           // Register 6
            uut.dp.reg_file.regfile[7],           // Register 7
            uut.dp.alu_result,                    // ALU output
            uut.dp.mem_stage.data_memory[0],
            uut.dp.mem_stage.data_memory[1]
        );
    end

endmodule
