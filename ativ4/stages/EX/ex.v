module ex (
    input               clk,
    input               reset,
    input               mem_re_in,
    input               mem_we_in,
    input               branch_instruction_in,
    input               reg_file_write_in,
    input       [6:0]   funct7e3,
    input       [1:0]   alu_op,
    input       [4:0]   addr_rd_in,
    input       [1:0]   select_mux_1,
    input       [1:0]   select_mux_2_in,
    input       [1:0]   select_mux_4_in,
    input       [31:0]  reg_in_a,
    input       [31:0]  reg_in_b,
    input       [31:0]  immediate_in,
    input       [31:0]  pc_in,
    output              mem_re_out,
    output              mem_we_out,
    output              reg_file_write_out,
    output              branch_out,
    output      [1:0]   select_mux_2_out,
    output      [1:0]   select_mux_4_out,
    output      [4:0]   addr_rd_out,
    output      [31:0]  reg_b_out,
    output      [31:0]  alu_out,
    output              branch_instruction_out,
    output      [31:0]  add_pc_out
    );

    wire [3:0] flags;
    wire [2:0] op;
    wire branch_in;
    wire [31:0] alu_in, add_pc_in;
    wire [31:0] mux_1_out;

    // Instantiating mux1
    mux_4 MUX_1 (
        .select     (select_mux_1),
        .D0         (reg_in_b),
        .D1         (immediate_in),
        .D2         (32'b0), // Unused inputs can be grounded
        .D3         (32'b0),
        .out        (mux_1_out)
    );

    // Instantiating alu_uc
    alu_uc ALU_UC (
        .clk        (clk),
        .funct7e3   (funct7e3),
        .aluOp      (alu_op),
        .op         (op),
        .branch     (branch_in),
        .flags      (flags)
    );

    // Instantiating alu_dp
    alu_dp ALU_DP (
        .op         (op),
        .A          (reg_in_a),
        .B          (mux_1_out),
        .flags      (flags),
        .R          (alu_in)
    );

    add_sub32 ADD_BRANCH (
    .op         ( 1'b0             ),
    .A          ( immediate_in    ),
    .B          ( pc_in           ),
    .R          ( add_pc_in       ),
    .carryOut   (                  )
);

    // Instantiating ex_mem_reg
    ex_mem_reg EX_MEM_REG (
        .clk                (clk),
        .reset              (reset),
        .mem_re_in          (mem_re_in),
        .mem_we_in          (mem_we_in),
        .addr_rd_in         (addr_rd_in),
        .addr_rd_out        (addr_rd_out),
        .branch_instruction_in (branch_instruction_in),
        .branch_instruction_out (branch_instruction_out),
        .reg_file_write_in  (reg_file_write_in),
        .branch_in          (branch_in),
        .select_mux_2_in    (select_mux_2_in),
        .select_mux_4_in    (select_mux_4_in),
        .reg_b_in           (reg_in_b),
        .alu_in             (alu_in),
        .add_pc_in          (add_pc_in),
        .mem_re_out         (mem_re_out),
        .mem_we_out         (mem_we_out),
        .reg_file_write_out (reg_file_write_out),
        .branch_out         (branch_out),
        .select_mux_2_out   (select_mux_2_out),
        .select_mux_4_out   (select_mux_4_out),
        .reg_b_out          (reg_b_out),
        .alu_out            (alu_out),
        .add_pc_out         (add_pc_out)
    );

endmodule
