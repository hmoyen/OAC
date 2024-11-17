module instruction_decode(
    input clock,
    input reset,
    input write_enable,
    input [31:0] instruction,
    input [31:0] pc,
    input [31:0] Din,
    input [4:0]  rw,
    input [4:0]  rd_ex_mem,
    input [4:0]  rd_mem_wb,
    output pc_load,
    output if_id_load,
    output          mem_re_out,
    output          mem_we_out,
    output          reg_file_write_out,
    output          branch_instruction,
    output  [1:0]   alu_op_out,
    output  [1:0]   select_mux_1_out,
    output  [1:0]   select_mux_2_out,
    output  [1:0]   select_mux_4_out,
    output  [31:0]  reg_a_out,
    output  [31:0]  reg_b_out,
    output  [31:0]  immediate_out,
    output  [31:0]  pc_out,
    output  [4:0]   addr_rd_out,           
    output  [6:0]   funct7e3_out
);

wire [4:0] s_ra, s_rb, s_rd;
wire [31:0] s_out_a, s_out_b, s_immediate;
wire s_pc_load, s_if_id_load, s_mux5_selector;
wire mem_re_int, mem_we_int, reg_file_write_int, branch_instruction_int, branch_instruction_id_ex;
wire [1:0] alu_op_int, select_mux_1_int, select_mux_2_int, select_mux_4_int;

hazard HAZARD(
    .clock(clock),
    .reset(reset),
    .rs1(s_ra),
    .rs2(s_rb),
    .opcode(instruction[6:0]),
    .rd_ex_mem(rd_ex_mem),
    .rd_mem_wb(rd_mem_wb),
    .branch_instruction_controller(branch_instruction_int),
    .branch_instruction_id_ex(branch_instruction_id_ex),
    .pc_load(s_pc_load),
    .if_id_load(s_if_id_load),
    .mux5_selector(s_mux5_selector)
);

controller CONTROLLER(
    .clock(clock),
    .reset(reset),
    .opcode(instruction[6:0]),
    .mem_re(mem_re_int),
    .mem_we(mem_we_int),
    .reg_file_write(reg_file_write_int),
    .branch_instruction(branch_instruction_int),
    .alu_op(alu_op_int),
    .select_mux_1(select_mux_1_int),
    .select_mux_2(select_mux_2_int),
    .select_mux_4(select_mux_4_int)
);

reg_file REGISTER_FILE (
    .ra(s_ra),
    .rb(s_rb),
    .we(write_enable),
    .Din(Din),
    .rw(rw),
    .clk(clock),
    .DoutA(s_out_a),
    .DoutB(s_out_b)
);

immediateG IMMEDIATE(
    .instruction(instruction),
    .immediate(s_immediate)
);

id_ex_reg ID_EX_REGISTER(
    .clk(clock),
    .reset(reset), // BLOQUEIOS DO STALL (BOLHA)
    .mem_re_in(s_mux5_selector ? 1'b0 :  mem_re_int),
    .mem_we_in(s_mux5_selector ? 1'b0  : mem_we_int),
    .reg_file_write_in(s_mux5_selector ? 1'b0  : reg_file_write_int),
    .alu_op_in(s_mux5_selector ? 2'b0  : alu_op_int),
    .select_mux_1_in(s_mux5_selector ? 2'b0  : select_mux_1_int),
    .select_mux_2_in(s_mux5_selector ? 2'b0  : select_mux_2_int),
    .select_mux_4_in(s_mux5_selector ? 2'b0  : select_mux_4_int),
    .reg_a_in(s_out_a),
    .reg_b_in(s_out_b),
    .addr_rd_in(s_rd),
    .addr_rd_out(addr_rd_out),
    .immediate_in(s_immediate),
    .pc_in(pc),
    .funct7e3_in(instruction[31:25]),
    .mem_re_out(mem_re_out),
    .mem_we_out(mem_we_out),
    .reg_file_write_out(reg_file_write_out),
    .alu_op_out(alu_op_out),
    .select_mux_1_out(select_mux_1_out),
    .select_mux_2_out(select_mux_2_out),
    .select_mux_4_out(select_mux_4_out),
    .reg_a_out(reg_a_out),
    .reg_b_out(reg_b_out),
    .immediate_out(immediate_out),
    .pc_out(pc_out),
    .branch_instruction_in(branch_instruction_int),
    .branch_instruction_out(branch_instruction_id_ex),
    .funct7e3_out(funct7e3_out)
);

assign s_ra = instruction[19:15];
assign s_rb = instruction[24:20];
assign s_rd = instruction[11:7];
assign pc_load = s_pc_load;
assign if_id_load = s_if_id_load;
assign branch_instruction = branch_instruction_id_ex;

endmodule