`timescale 1ns / 1ps

module wb_tb;

    // Inputs
    reg reg_file_write_in;     // Input write enable
    reg [4:0] addr_rd;         // 5-bit address input
    reg [1:0] select_mux_2;    // 2-bit select input for mux_4
    reg [31:0] mem_out;        // 32-bit input to mux_4
    reg [31:0] alu_out;        // 32-bit input to mux_4

    // Outputs
    wire [31:0] mux_2_out;     // 32-bit output from mux_4
    wire [4:0] addr_out;       // 5-bit address output
    wire reg_file_write_out;   // Output write enable

    // Instantiate the wb module
    wb utt (
        .reg_file_write_in(reg_file_write_in),
        .addr_rd(addr_rd),
        .select_mux_2(select_mux_2),
        .mem_out(mem_out),
        .alu_out(alu_out),
        .mux_2_out(mux_2_out),
        .addr_out(addr_out),
        .reg_file_write_out(reg_file_write_out)
    );

    // Testbench logic
    initial begin

        $dumpfile("wb_tb.vcd");
        $dumpvars(0, wb_tb);
        
        // Initialize inputs
        addr_rd = 5'b00000;
        select_mux_2 = 2'b00;
        mem_out = 32'hAAAAAAAA; // Example value for mem_out
        alu_out = 32'h55555555; // Example value for alu_out
        reg_file_write_in = 1'b0;

        // Apply test cases
        $display("Starting Testbench...");
        
        // Test case 1: select_mux_2 = 00 (select mem_out), reg_file_write_in = 1
        #10;
        reg_file_write_in = 1'b1;
        select_mux_2 = 2'b00;
        addr_rd = 5'b10101;  // Example address value
        #10;
        $display("Test 1: select_mux_2=00, mux_2_out=%h, addr_out=%b, reg_file_write_out=%b", 
                 mux_2_out, addr_out, reg_file_write_out);

        // Test case 2: select_mux_2 = 01 (select alu_out), reg_file_write_in = 0
        #10;
        reg_file_write_in = 1'b0;
        select_mux_2 = 2'b01;
        addr_rd = 5'b11011;
        #10;
        $display("Test 2: select_mux_2=01, mux_2_out=%h, addr_out=%b, reg_file_write_out=%b", 
                 mux_2_out, addr_out, reg_file_write_out);

        // Test case 3: select_mux_2 = 10 (select D2, unused, expect 0), reg_file_write_in = 1
        #10;
        reg_file_write_in = 1'b1;
        select_mux_2 = 2'b10;
        addr_rd = 5'b11100;
        #10;
        $display("Test 3: select_mux_2=10, mux_2_out=%h, addr_out=%b, reg_file_write_out=%b", 
                 mux_2_out, addr_out, reg_file_write_out);

        // Test case 4: select_mux_2 = 11 (select D3, unused, expect 0), reg_file_write_in = 0
        #10;
        reg_file_write_in = 1'b0;
        select_mux_2 = 2'b11;
        addr_rd = 5'b00001;
        #10;
        $display("Test 4: select_mux_2=11, mux_2_out=%h, addr_out=%b, reg_file_write_out=%b", 
                 mux_2_out, addr_out, reg_file_write_out);

        $display("Testbench completed.");
        $stop;
        #500 $finish;
    end

endmodule
