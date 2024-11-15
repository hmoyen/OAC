module riscv (
    input clk,
    input reset
);
    
    wire [6 :0] opcode;
    wire branch, pc_load, pc_reset, mem_re, mem_we, reg_file_write;
    wire [1 :0] alu_op, select_mux_1, select_mux_2, select_mux_3, select_mux_4;

riscv_uc UC(
    .clk                ( clk               ),
    .reset              ( reset             ),
    .opcode             ( opcode            ),
    .pc_load            ( pc_load           ),
    .pc_reset           ( pc_reset          ),
    .mem_re             ( mem_re            ),
    .mem_we             ( mem_we            ),
    .reg_file_write     ( reg_file_write    ),
    .alu_op             ( alu_op            ),
    .select_mux_1       ( select_mux_1      ),
    .select_mux_2       ( select_mux_2      ),
    .select_mux_4       ( select_mux_4      )
);  

riscv_dp DP(    
    .clk                ( clk               ),
    .reset              ( reset             ),
    .opcode             ( opcode            ),
    .branch             ( branch            ),
    .pc_load            ( pc_load           ),
    .pc_reset           ( pc_reset          ),
    .mem_re             ( mem_re            ),
    .mem_we             ( mem_we            ),
    .reg_file_write     ( reg_file_write    ),
    .alu_op             ( alu_op            ),
    .select_mux_1       ( select_mux_1      ),
    .select_mux_2       ( select_mux_2      ),
    .select_mux_3       ( select_mux_3      ),
    .select_mux_4       ( select_mux_4      )
);


endmodule