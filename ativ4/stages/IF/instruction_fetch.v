module instruction_fetch(
    input clock,
    input reset,
    input stall,
    input mux3_selector,
    input [31:0] pc_branch_in,
    output [31:0] pc_out,
    output [31:0] instruction_out
);

parameter WIDTH_PC = 32;

wire [WIDTH_PC - 1:0] s_pc_out, s_pc_in, s_instruction_out;

mux_2 #(
    .WIDTH(32)
) MUX3 (
    .select(mux3_selector),
    .D0(s_pc_out + 32'd1),
    .D1(pc_branch_in),
    .out(s_pc_in)
);

pc PC(
    .clock(clock),
    .reset(reset),
    .stall(stall),
    .pc_in(s_pc_in),
    .pc_out(s_pc_out)
);

memory_inst MEM_INSTRUCION (
    .addr(s_pc_out),
    .Din(32'b0),
    .we(1'b0),
    .re(1'b1),
    .clk(clock),
    .out(s_instruction_out)
);

if_id_register IF_ID (
    .clock(clock),
    .reset(reset),
    .instruction_in(s_instruction_out),
    .pc_in(s_pc_out),
    .instruction_out(instruction_out),
    .pc_out(pc_out)
);

endmodule