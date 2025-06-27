module memory_stage(
    input wire clk,
    input wire reset,
    input wire MemRead,               // Not needed for read_data muxing
    input wire MemWrite,
    input wire [7:0] alu_result,      // Effective memory address
    input wire [7:0] write_data,      // Data to store (usually from rt)
    output wire [7:0] read_data       // Data loaded from memory
);
    reg [7:0] data_memory [0:255];
    integer i;
    
    initial begin
        for (i = 0; i < 256; i = i + 1)
            data_memory[i] = 8'h00;
    end

    // Write operation
    always @(posedge clk) begin
        if (MemWrite)
            data_memory[alu_result] <= write_data;
    end

    // Read is now always active, only for single cycle case, need to change for pipelined 
    assign read_data = data_memory[alu_result];

endmodule
