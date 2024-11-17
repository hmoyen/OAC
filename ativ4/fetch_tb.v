`timescale 1ps/1ps
module fetch_tb();

    reg clock;
    reg reset;
    reg pc_load;
    reg if_id_load;
    reg mux3_selector;
    reg [31:0] pc_branch_in;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    instruction_fetch   IF (
        .clock(clock),
        .reset(reset),
        .pc_load(pc_load),
        .if_id_load(if_id_load),
        .mux3_selector(mux3_selector),
        .pc_branch_in(pc_branch_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

parameter CLK_PERIOD = 10;

    initial begin
        $dumpfile("fetch.vcd");
        $dumpvars(0, fetch_tb);
        clock = 0;
        reset = 0;
        pc_load = 1;
        if_id_load = 1;
        mux3_selector = 0;
        pc_branch_in = 32;

        #(5*CLK_PERIOD) reset = 1;
        #(5*CLK_PERIOD) reset = 0;

        #(10*CLK_PERIOD);
        pc_load = 0;
        if_id_load = 0;
        #(10*CLK_PERIOD);
        pc_load = 1;
        if_id_load = 1;

        #(10*CLK_PERIOD) mux3_selector = 1;
        #(10*CLK_PERIOD) mux3_selector = 0;

        #(10*CLK_PERIOD) $finish;

    end
always #(CLK_PERIOD/2) clock = ~clock;
endmodule