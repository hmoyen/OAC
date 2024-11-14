`timescale 1ns/100ps

module riscv_tb();
    reg clk, reset;
    riscv riscv (.reset(reset), .clk(clk));
    initial begin
        $dumpfile("riscv_tb.vcd");
        $dumpvars(0, riscv_tb);
        clk <= 1'b0;
        reset <= 1'b1;
        #100
        reset <= 1'b0;
        #40000 $finish;
    end
    always #50 clk = ~clk;
endmodule