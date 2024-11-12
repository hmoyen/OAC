module riscv_dp (
    input             clk,
    input             reset,
    input             pc_load,
    input             mem_re,
    input             mem_we,
    input   [1 :0]    alu_op,
    input   [1 :0]    select_mux_1,
    input   [1 :0]    select_mux_2,
    input   [1 :0]    select_mux_3,
    input   [1 :0]    select_mux_4,
    input   [1 :0]    select_mux_5,
    input   [1 :0]    select_mux_6,
    output  [6 :0]    opcode
);

wire [31:0] pc_out, 
            add_out, 
            mem_out,
            mux_1_out, 
            mux_2_out, 
            mux_3_out, 
            mux_4_out, 
            mux_5_out, 
            alu_out, 
            inst_out, 
            immediate_out,
            reg_out_a,
            reg_out_b;

wire branch;
wire [1 :0] alu_op;
wire [2 :0] op;
wire [3 :0] flags;
wire [4 :0] addr_ra, addr_rb, addr_rd;
wire [6 :0] funct7e3;

add_sub32 ADD (
    .op         ( 1'b0    ),
    .A          ( 1'b1    ),
    .B          ( pc_out  ),
    .R          ( add_out ),
    .carryOut   (         )
);

mux_4 MUX_5 (
        .select     ( select_mux_5  ),
        .D0         ( add_out       ),
        .D1         ( alu_out       ),
        .D2         (               ),
        .D3         (               ),
        .out        ( mux_5_out     )
);

mod_reg PC (
        .in         ( mux_5_out ),
        .clk        ( clk       ),
        .load       ( pc_load   ),
        .out        ( pc_out    )
);

memory_inst INST (
        .addr       ( pc_out    ),       
        .Din        (           ),        
        .we         (           ),         
        .re         ( 1'b1      ),         
        .clk        ( clk       ),
        .out        ( inst_out  )  
);

immediateG IMM(
    .instruction    ( inst_out      ),
    .immediate      ( immediate_out )
);
    
assign addr_ra = inst_out[19:15];
assign addr_rb = inst_out[24:20];
assign addr_rd = inst_out[11: 7];

mux_4 MUX_4 (
        .select     ( select_mux_4  ),
        .D0         ( alu_out       ),
        .D1         ( mem_out       ),
        .D2         (               ),
        .D3         (               ),
        .out        ( mux_4_out     )
);

ref_file REG(
    ra          ( addr_ra           ),     
    rb          ( addr_rb           ),         
    we          ( reg_file_write    ),                
    Din         ( mux_4_out         ),       
    rw          ( addr_rd           ),             
    clk         ( clk               ),              
    DoutA       ( reg_out_a         ), 
    DoutB       ( reg_out_b         )  
);

mux_4 MUX_1 (
        .select     ( select_mux_1  ),
        .D0         ( pc_out        ),
        .D1         ( reg_out_a     ),
        .D2         (               ),
        .D3         (               ),
        .out        ( mux_1_out     )
);

mux_4 MUX_2 (
        .select     ( select_mux_2  ),
        .D0         ( immediate_out ),
        .D1         ( reg_out_b     ),
        .D2         (               ),
        .D3         (               ),
        .out        ( mux_2_out     )
);

assign funct7e3 = {inst_out[31:28], inst_out[14:12]};

alu_uc ALU_UC (
    .clk            ( clk       ),
    .funct7e3       ( funct7e3  ), 
    .aluOp          ( alu_op    ),
    .flags          ( flags     ),
    .branch         ( branch    ),
    .op             ( op        )
);


alu_dp ALU_DP (
    .op       ( op        ),
    .A        ( mux_1_out ),
    .B        ( mux_2_out ),
    .flags    ( flags     ),
    .R        ( alu_out   ),
);

mux_4 MUX_3 (
        .select     ( select_mux_3  ),
        .D0         ( alu_out       ),
        .D1         ( reg_out_a     ),
        .D2         ( immediate_out ),
        .D3         (               ),
        .out        ( mux_3_out     )
);

mux_4 MUX_6 (
        .select     ( select_mux_6  ),
        .D0         ( mux_3_out     ),
        .D1         ( reg_out_b     ),
        .D2         (               ),
        .D3         (               ),
        .out        ( mux_6_out     )
);

memory_file MEM(
    .addr       ( mux_3_out ),       
    .Din        ( mux_6_out ),        
    .we         ( mem_we    ),         
    .re         ( mem_re    ),       
    .clk        ( clk       ),
    .out        ( mem_out   )  
);


endmodule