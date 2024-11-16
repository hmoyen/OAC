module mem (
    input               clk,
    input               reset,
    input               mem_we,
    input               mem_re,
    input               branch_instruction,
    input               branch_in,
    input               reg_file_write_in,
    input       [31:0]  alu_out,
    input       [31:0]  reg_out_b,
    input       [31:0]  add_pc_in,
    input       [1:0]   select_mux_4_in,
    input       [1:0]   select_mux_2_in,

    output              reg_file_write_out,
    output      [31:0]  mem_out,
    output      [31:0]  add_pc_out,
    output      [31:0]  alu_result_out,
    output      [1:0]   select_mux_2_out,
    output      [1:0]   select_mux_3_out
);

    // Wire declarations
    wire [31:0] mem_data_out, mux_4_out;

    assign select_mux_3_out = {1'b0,branch_instruction & branch_in};

    mux_4 MUX_4 (
            .select     ( select_mux_4_in  ),
            .D0         ( alu_out       ),
            .D1         ( reg_out_b     ),
            .D2         (               ),
            .D3         (               ),
            .out        ( mux_4_out     )
    );

    // Instantiate memory_file module
    memory_file MEM (
        .addr       ( alu_out   ),       
        .Din        ( mux_4_out ),        
        .we         ( mem_we    ),         
        .re         ( mem_re    ),       
        .clk        ( clk       ),
        .out        ( mem_data_out )  
    );

    // Instantiate mem_wb_reg module
    mem_wb_reg MEM_WB (
        .clk                ( clk                ),
        .reset              ( reset              ),
        .reg_file_write_in  ( reg_file_write_in  ),
        .add_pc_in          ( add_pc_in          ),
        .mem_in             ( mem_data_out       ),
        .alu_result_in      ( alu_out            ),
        .select_mux_2_in    ( select_mux_2_in    ),

        .reg_file_write_out ( reg_file_write_out ),
        .add_pc_out         ( add_pc_out         ),
        .mem_out            ( mem_out            ),
        .alu_result_out     ( alu_result_out     ),
        .select_mux_2_out   ( select_mux_2_out   )
    );

endmodule
