`timescale 1ns/100ps

module riscv_pipeline_tb();
    reg clk, reset;
    riscv_pipeline riscv (.reset(reset), .clock(clk));
    initial begin
        $dumpfile("riscv_pipeline_tb.vcd");
        $dumpvars(0, riscv_pipeline_tb);
        clk <= 1'b0;
        reset <= 1'b1;
        #100
        reset <= 1'b0;
        #40000 $finish;
    end
    always #50 clk = ~clk;
endmodule