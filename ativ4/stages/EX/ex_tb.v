`timescale 1ns/100ps

module ex_tb();
    // Clock and reset signals
    reg clk, reset;

    // Input signals
    reg mem_re_in, mem_we_in, reg_file_write_in;
    reg [6:0] funct7e3;
    reg [1:0] alu_op, select_mux_1, select_mux_2_in, select_mux_4_in;
    reg [31:0] reg_in_a, reg_in_b, immediate_in, pc_in;

    // Output signals
    wire mem_re_out, mem_we_out, reg_file_write_out, branch_out;
    wire [1:0] select_mux_2_out, select_mux_4_out;
    wire [31:0] reg_b_out, alu_out, add_pc_out;

    // Instantiate the ex module
    ex uut (
        .clk(clk),
        .reset(reset),
        .mem_re_in(mem_re_in),
        .mem_we_in(mem_we_in),
        .reg_file_write_in(reg_file_write_in),
        .funct7e3(funct7e3),
        .alu_op(alu_op),
        .select_mux_1(select_mux_1),
        .select_mux_2_in(select_mux_2_in),
        .select_mux_4_in(select_mux_4_in),
        .reg_in_a(reg_in_a),
        .reg_in_b(reg_in_b),
        .immediate_in(immediate_in),
        .pc_in(pc_in),
        .mem_re_out(mem_re_out),
        .mem_we_out(mem_we_out),
        .reg_file_write_out(reg_file_write_out),
        .branch_out(branch_out),
        .select_mux_2_out(select_mux_2_out),
        .select_mux_4_out(select_mux_4_out),
        .reg_b_out(reg_b_out),
        .alu_out(alu_out),
        .add_pc_out(add_pc_out)
    );

    // Generate GTKWave file
    initial begin
        $dumpfile("ex_tb.vcd");
        $dumpvars(0, ex_tb);

        // Initialize signals
        clk = 0;
        reset = 1;
        mem_re_in = 0;
        mem_we_in = 0;
        reg_file_write_in = 0;
        funct7e3 = 7'b0;
        alu_op = 2'b0;
        select_mux_1 = 2'b0;
        select_mux_2_in = 2'b0;
        select_mux_4_in = 2'b0;
        reg_in_a = 32'b0;
        reg_in_b = 32'b0;
        immediate_in = 32'h4;
        pc_in = 32'h1000;

        // Reset pulse
        #100 reset = 0;

        // Test Case 1: aluOp = 00 (Add)
        alu_op = 2'b00;
        funct7e3 = 7'b0000000;  // No effect, always add
        reg_in_a = 32'd1;
        reg_in_b = 32'd2;
        #1000;

        // Test Case 2: aluOp = 01 (Type I)
        alu_op = 2'b01;
        select_mux_1 = 2'b01;
        funct7e3 = 7'bxxxx000;  // addi
        reg_in_a = 32'h15;
        immediate_in = 32'h10;
        #1000;

        // Test Case 3: aluOp = 10 (Type R - Subtraction)
        alu_op = 2'b10;
         select_mux_1 = 2'b00;
        funct7e3 = 7'b0100000;  // Sub
        reg_in_a = 32'h30;
        reg_in_b = 32'h10;
        #1000;

        // Test Case 4: aluOp = 10 (Type R - AND)
        funct7e3 = 7'bxxxx111;  // AND
        reg_in_a = 32'hF0F0F0F0;
        reg_in_b = 32'h0F0F0F0F;
        #1000;

        // Test Case 5: aluOp = 10 (Type R - OR)
        funct7e3 = 7'bxxxx110;  // OR
        reg_in_a = 32'hAA55AA55;
        reg_in_b = 32'h55AA55AA;
        #1000;

        // Test Case 6: aluOp = 10 (Type R - XOR)
        funct7e3 = 7'bxxxx100;  // XOR
        reg_in_a = 32'h12345678;
        reg_in_b = 32'h87654321;
        #1000;

        // Test Case 7: Branching Logic
        funct7e3 = 7'bxxxx001;  // BNE (branch on A != B)
        reg_in_a = 32'h1;
        reg_in_b = 32'h2;  // Flags should indicate A != B
        #1000;

        funct7e3 = 7'bxxxx000;  // BEQ (branch on A == B)
        reg_in_a = 32'h3;
        reg_in_b = 32'h3;  // Flags should indicate A == B
        #1000;

        // End simulation
        #500 $finish;
    end

    // Clock generation
    always #50 clk = ~clk;

endmodule
