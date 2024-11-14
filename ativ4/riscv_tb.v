`timescale 1ns/1ns
module riscv_tb;
    
    reg clk;
    reg reset;
    always #2 clk = ~clk;

    riscv CPU (.reset(reset), .clk(clk));
    initial begin
        $dumpfile("riscv_tb.vcd");
        $dumpvars(0, riscv_tb);
        clk <= 1'b0;
        reset <= 1'b1;
        #100
        reset <= 1'b0;
        #40000 $finish;
    end

endmodule