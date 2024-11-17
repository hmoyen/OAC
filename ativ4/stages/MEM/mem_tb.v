`timescale 1ns/100ps

module mem_tb();
    // Clock and reset signals
    reg clk, reset;

    // Input signals
    reg mem_we, mem_re, branch_instruction, branch_in, reg_file_write_in;
    reg [31:0] alu_out, reg_out_b, add_pc_in;
    reg [1:0] select_mux_4_in, select_mux_2_in;

    // Output signals
    wire reg_file_write_out;
    wire [31:0] mem_out, add_pc_out, alu_result_out;
    wire [1:0] select_mux_2_out, select_mux_3_out;

    // Instantiate the mem module
    mem uut (
        .clk(clk),
        .reset(reset),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .branch_instruction(branch_instruction),
        .branch_in(branch_in),
        .reg_file_write_in(reg_file_write_in),
        .alu_out(alu_out),
        .reg_out_b(reg_out_b),
        .add_pc_in(add_pc_in),
        .select_mux_4_in(select_mux_4_in),
        .select_mux_2_in(select_mux_2_in),
        .reg_file_write_out(reg_file_write_out),
        .mem_out(mem_out),
        .add_pc_out(add_pc_out),
        .alu_result_out(alu_result_out),
        .select_mux_2_out(select_mux_2_out),
        .select_mux_3_out(select_mux_3_out)
    );

    // Generate GTKWave file
    initial begin
        $dumpfile("mem_tb.vcd");
        $dumpvars(0, mem_tb);

        // Initialize signals
        clk = 0;
        reset = 1;
        mem_we = 0;
        mem_re = 0;
        branch_instruction = 0;
        branch_in = 0;
        reg_file_write_in = 0;
        alu_out = 32'h0;
        reg_out_b = 32'h0;
        add_pc_in = 32'h0;
        select_mux_4_in = 2'b0;
        select_mux_2_in = 2'b0;

        // Reset pulse
        #50 reset = 0;

        // Test Case 1: Write to memory
        #100 mem_we = 1; 
        alu_out = 32'h100; 
        reg_out_b = 32'hDEADBEEF; 
        select_mux_4_in = 2'b01;

        // Test Case 2: Read from memory
        #100 mem_we = 0; mem_re = 1; alu_out = 32'd3;

        // Test Case 3: Branching logic
        #100 branch_instruction = 1; branch_in = 0; 

                // Test Case 3: Branching logic
        #100 branch_instruction = 1; branch_in = 1; 


        // Test Case 4: Pass-through without memory interaction
        #100 mem_re = 0; mem_we = 0; reg_file_write_in = 1; alu_out = 32'h300; add_pc_in = 32'h4000;

        // Test Case 5: Select inputs for mux_4
        #100 select_mux_4_in = 2'b00; // alu_out to mux_4
        #100 select_mux_4_in = 2'b01; // reg_out_b to mux_4

        // End simulation
        #500 $finish;
    end

    // Clock generation
    always #25 clk = ~clk;

endmodule
