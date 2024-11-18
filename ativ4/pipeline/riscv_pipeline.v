module riscv_pipeline(
    input               clock,
    input               reset
    );

    wire pc_load, if_id_load;
    wire mem_re_out_id, mem_we_out_id, reg_file_write_out_id, branch_instruction_id, branch_instruction_ex;
    wire [1:0] alu_op_out, select_mux_1_out, select_mux_2_out_id, select_mux_4_out_id;
    wire [31:0] reg_a_out, reg_b_out_id, immediate_out, pc_out_if, pc_out_id, instruction_out, alu_out_ex, add_pc_out_ex;
    wire [6:0] funct7e3_out;
    wire branch_out_ex, mem_re_out_ex, mem_we_out_ex, reg_file_write_out_ex;
    wire [1:0] select_mux_2_out_ex, select_mux_4_out_ex;
    wire [31:0] reg_b_out_ex;
    wire [31:0] alu_result_out_mem, mem_out, add_pc_out_mem;
    wire [1:0] select_mux_2_out_mem;
    wire select_mux_3_out_mem;
    wire select_mux_3_out_wb;
    wire [4:0] addr_rd, addr_rd_out_ID, addr_rd_out_EX, addr_rd_out_MEM, addr_rd_out_WB;

    // WB wires
    wire reg_file_write_wb_in, reg_file_write_wb_out; // WE do banco de registradores
    wire [31:0] wb_out; // Dado de saída para Din do banco de registradores

    // Instruction Fetch
    instruction_fetch IF (
        .clock(clock),
        .reset(reset),
        .pc_load(pc_load),
        .if_id_load(if_id_load),
        .mux3_selector(select_mux_3_out_mem), // Sinal de seleção do MUX 3 pelo AND da branch instruction com resultado ZERO da ULA
        .pc_branch_in(add_pc_out_ex), // Entrada do valor pc + imm da instrução de branch
        .pc_out(pc_out_if),
        .instruction_out(instruction_out)
    );

    // Instruction Decode
    instruction_decode ID (
        .clock(clock),
        .reset(reset),
        .select_mux_3(select_mux_3_out_mem),
        .select_mux_3_wb(select_mux_3_out_wb),
        .write_enable(reg_file_write_wb_out), // WE do write back
        .instruction(instruction_out),
        .pc(pc_out_if),
        .Din(wb_out),
        .rw(addr_rd_out_WB),
        .rd_ex_mem(addr_rd_out_ID), // Forwarding addresses
        .rd_mem_wb(addr_rd_out_EX),
        .pc_load(pc_load),
        .if_id_load(if_id_load),
        .mem_re_out(mem_re_out_id),
        .mem_we_out(mem_we_out_id),
        .reg_file_write_out(reg_file_write_out_id),
        .branch_instruction(branch_instruction_id),
        .alu_op_out(alu_op_out),
        .select_mux_1_out(select_mux_1_out),
        .select_mux_2_out(select_mux_2_out_id),
        .select_mux_4_out(select_mux_4_out_id),
        .reg_a_out(reg_a_out),
        .reg_b_out(reg_b_out_id),
        .addr_rd_out(addr_rd_out_ID),
        .immediate_out(immediate_out),
        .pc_out(pc_out_id),
        .funct7e3_out(funct7e3_out)
    );

    // Execute
    ex EX (
        .clk(clock),
        .reset(reset),
        .addr_rd_in(addr_rd_out_ID),
        .branch_instruction_in(branch_instruction_id),
        .branch_instruction_out(branch_instruction_ex),
        .mem_re_in(mem_re_out_id),
        .mem_we_in(mem_we_out_id),
        .reg_file_write_in(reg_file_write_out_id),
        .funct7e3(funct7e3_out),
        .alu_op(alu_op_out),
        .select_mux_1(select_mux_1_out),
        .select_mux_2_in(select_mux_2_out_id),
        .select_mux_4_in(select_mux_4_out_id),
        .reg_in_a(reg_a_out),
        .reg_in_b(reg_b_out_id),
        .immediate_in(immediate_out),
        .pc_in(pc_out_id),
        .mem_re_out(mem_re_out_ex),
        .mem_we_out(mem_we_out_ex),
        .reg_file_write_out(reg_file_write_out_ex),
        .branch_out(branch_out_ex),
        .select_mux_2_out(select_mux_2_out_ex),
        .select_mux_4_out(select_mux_4_out_ex),
        .reg_b_out(reg_b_out_ex),
        .alu_out(alu_out_ex),
        .addr_rd_out(addr_rd_out_EX),
        .add_pc_out(add_pc_out_ex)
    );

    // Memory
    mem MEM (
        .clk(clock),
        .reset(reset),
        .addr_rd_in(addr_rd_out_EX),
        .mem_we(mem_we_out_ex),
        .mem_re(mem_re_out_ex),
        .branch_instruction(branch_instruction_ex),
        .branch_in(branch_out_ex),
        .reg_file_write_in(reg_file_write_out_ex),
        .alu_out(alu_out_ex),
        .reg_out_b(reg_b_out_ex),
        .select_mux_4_in(select_mux_4_out_ex),
        .select_mux_2_in(select_mux_2_out_ex),
        .reg_file_write_out(reg_file_write_wb_in),
        .mem_out(mem_out),
        .addr_rd_out(addr_rd_out_MEM),
        .alu_result_out(alu_result_out_mem),
        .select_mux_2_out(select_mux_2_out_mem),
        .select_mux_3_out(select_mux_3_out_mem),
        .select_mux_3_out_wb(select_mux_3_out_wb)
    );

    // Write Back
    wb WB (
        
        .addr_rd(addr_rd_out_MEM),
        .reg_file_write_in(reg_file_write_wb_in),
        .reg_file_write_out(reg_file_write_wb_out),
        .select_mux_2(select_mux_2_out_mem),
        .mem_out(mem_out),
        .alu_out(alu_result_out_mem),
        .mux_2_out(wb_out),
        .addr_out(addr_rd_out_WB)
    );

endmodule
