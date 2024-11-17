`timescale 1ps/1ps
module instruction_decode_tb();

    reg clock;
    reg reset;
    reg write_enable;
    reg branch_instruction_id_ex;
    reg [31:0] instruction;
    reg [31:0] pc;
    reg [31:0] Din;
    reg [4:0]  rw;
    reg [4:0]  rd_ex_mem;
    reg [4:0]  rd_mem_wb;
    wire pc_load;
    wire if_id_load;
    wire          mem_re_out;
    wire          mem_we_out;
    wire          reg_file_write_out;
    wire          branch_instruction;
    wire  [1:0]   alu_op_out;
    wire  [1:0]   select_mux_1_out;
    wire  [1:0]   select_mux_2_out;
    wire  [1:0]   select_mux_4_out;
    wire  [31:0]  reg_a_out;
    wire  [31:0]  reg_b_out;
    wire  [31:0]  immediate_out;
    wire  [31:0]  pc_out;
    wire  [6:0]   funct7e3_out;

    instruction_decode ID (
    .clock(clock),
    .reset(reset),
    .write_enable(write_enable),
    .branch_instruction_id_ex(branch_instruction_id_ex),
    .instruction(instruction),
    .pc(pc),
    .Din(Din),
    .rw(rw),
    .rd_ex_mem(rd_ex_mem),
    .rd_mem_wb(rd_mem_wb),
    .pc_load(pc_load),
    .if_id_load(if_id_load),
    .mem_re_out(mem_re_out),
    .mem_we_out(mem_we_out),
    .reg_file_write_out(reg_file_write_out),
    .branch_instruction(branch_instruction),
    .alu_op_out(alu_op_out),
    .select_mux_1_out(select_mux_1_out),
    .select_mux_2_out(select_mux_2_out),
    .select_mux_4_out(select_mux_4_out),
    .reg_a_out(reg_a_out),
    .reg_b_out(reg_b_out),
    .immediate_out(immediate_out),
    .pc_out(pc_out),           
    .funct7e3_out(funct7e3_out)
    );

reg [31:0] instrucoes [0:11];
reg [4:0] caso;



parameter CLK_PERIOD = 10;

    initial begin
        $dumpfile("instruction_decode.vcd");
        $dumpvars(0, instruction_decode_tb);

        //LW
        //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[1] = Mem[3] = 17
        instrucoes[0] = 32'b000000000011_00000_010_00001_0000011;
        //LW
        //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[2] = Mem[7] = 5
        instrucoes[1] = 32'b000000000111_00000_010_00010_0000011;
        //LW
        //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[4] = Mem[Reg(3) + 1] = Mem[17 + 1] = 99
        instrucoes[2] = 32'b000000000001_00011_010_00100_0000011;
        //SW 
        //Estrutura da instrução = {offset[11:5], rs2, rs1, 010, offset[4:0], 0100011}
        //salva o valor de reg[3] (= 17) em instrucoes[100 = reg[4](= 99) + 1] 
        instrucoes[3] = 32'b0000000_00011_00100_010_00001_0100011;

        //Operação: typeR
        //Estrutura da instrução = {funct7, rs2, rs1, funct3, rd, opcode} = {funct7, Rb, Ra, funct3, rw, opcode}   
        //ADD
        //reg[15] = reg[3] + reg[4] = 99 + 17 = 116
        instrucoes[4] = 32'b0000000_00011_00100_000_01111_0110011;
        //LW
        //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[4] = Mem[7] = 5
        instrucoes[5] = 32'b000000000111_00000_010_00100_0000011;
        //SUB
        //reg[14] = reg[4] - reg[15] = 5 - 116 = -111
        instrucoes[6] = 32'b0100000_01111_00100_000_01110_0110011;
        //SUB
        //reg[14] = reg[4] - reg[15] = 116 - 5 = 111
        instrucoes[7] = 32'b0100000_00100_01111_000_01110_0110011;

        //AND
        //reg[6] = reg[14] (111) & reg[4] (5)
        instrucoes[8] = 32'b0000000_00100_01110_111_00110_0110011;
        //OR
        //reg[6] = reg[14] (-17) | reg[4] (5)
        instrucoes[9] = 32'b0000000_00100_01110_110_00111_0110011;

        //TIPO SB        
        //Estrutura da instrução = {{imm[12], imm[10:5]}, rs2, rs1, 3'b000, {imm[4:1], imm[11]}, 7'b1100011}
        //BEQ
        //if(reg[15] (116) == reg[6] (5)): então faz branch (OBS: nesse caso não ocorre) imm = 16
        instrucoes[10] = 32'b0_000000_01111_00110_000_1000_0_1100011;
        //BEQ
        //if(reg[4] (5) == reg[6] (5)): então faz branch (OBS: nesse caso ocorre) imm = 16 
        instrucoes[11] = 32'b0_000000_00100_00110_000_1000_0_1100011;

        // CASO 0: RESET
        caso = 0;
        clock = 0;
        reset = 0;
        write_enable = 0;
        branch_instruction_id_ex = 0;
        instruction = instrucoes[0];
        pc = 32'b0;
        Din = 32'b0;
        rw = 5'd1;
        rd_ex_mem = 5'd2;
        rd_mem_wb = 5'd3;

        #(CLK_PERIOD) reset = 1;
        #(1*CLK_PERIOD) reset = 0;

        // CASO 1: LW: RF[1] = Mem[3] = 17
        // SEM HAZARD DE DADOS NEM DE INTRUCOES DE BRANCH
        caso = 1;
        write_enable = 1;
        branch_instruction_id_ex = 0;
        pc = pc;
        Din = 32'd5;
        rw = 5'd1;
        rd_ex_mem = 5'd3;
        rd_mem_wb = 5'd4;

        #(CLK_PERIOD);

        // CASO 2: LW: RF[2] = Mem[7] = 5
        // SEM HAZARD DE DADOS NEM DE INTRUCOES DE BRANCH
        caso = 2;
        instruction = instrucoes[1];
        write_enable = 1;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd17;
        rw = 5'd2;
        rd_ex_mem = 5'd3;
        rd_mem_wb = 5'd4;

        #(CLK_PERIOD);

        // CASO 3: LW: RF[4] = Mem[Reg(3) + 1] = Mem[17 + 1] = 99
        // COM HAZARD DE DADOS DO EX_MEM
        caso = 3;
        instruction = instrucoes[2];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd99;
        rw = 5'd2;
        rd_ex_mem = 5'd3;
        rd_mem_wb = 5'd5;

        #(CLK_PERIOD);

        // CASO 4: SW: Mem[100] = 17
        // salva o valor de reg[3] (= 17) em instrucoes[100 = reg[4](= 99) + 1] 
        // SEM HAZARD DE DADOS NEM DE INTRUCOES DE BRANCH
        caso = 4;
        instruction = instrucoes[3];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd17;
        rw = 5'd3;
        rd_ex_mem = 5'd5;
        rd_mem_wb = 5'd6;

        #(CLK_PERIOD);

        // CASO 5: SW: Mem[100] = 17
        // salva o valor de reg[3] (= 17) em instrucoes[100 = reg[4](= 99) + 1] 
        // COM HAZARD DE DADOS DO MEM_WB
        caso = 5;
        instruction = instrucoes[3];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd17;
        rw = 5'd3;
        rd_ex_mem = 5'd5;
        rd_mem_wb = 5'd3;

        #(CLK_PERIOD);

        // CASO 6: ADD: RF[15] = RF[3] + RF[4] = 99 + 17 = 116
        // SEM HAZARD DE DADOS NEM DE INTRUCOES DE BRANCH
        caso = 6;
        instruction = instrucoes[4];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd0;
        rw = 5'd1;
        rd_ex_mem = 5'd5;
        rd_mem_wb = 5'd6;

        #(CLK_PERIOD);

        // CASO 7: ADD: RF[15] = RF[3] + RF[4] = 99 + 17 = 116
        // COM HAZARD DE DADOS DO EX_MEM
        caso = 7;
        instruction = instrucoes[4];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd0;
        rw = 5'd1;
        rd_ex_mem = 5'd3;
        rd_mem_wb = 5'd6;

        #(CLK_PERIOD);

        // CASO 8: ADD: RF[15] = RF[3] + RF[4] = 99 + 17 = 116
        // COM HAZARD DE INSTRUCAO DE BRANCH (SINAL DO ID_EX)
        caso = 8;
        instruction = instrucoes[4];
        write_enable = 0;
        branch_instruction_id_ex = 1;
        pc = pc + 32'd1;
        Din = 32'd0;
        rw = 5'd1;
        rd_ex_mem = 5'd5;
        rd_mem_wb = 5'd6;

        #(CLK_PERIOD);

        // CASO 9:
        //BEQ
        //if(reg[15] (116) == reg[6] (5)): então faz branch (OBS: nesse caso não ocorre) 

        caso = 9;
        instruction = instrucoes[10];
        write_enable = 0;
        branch_instruction_id_ex = 0;
        pc = pc + 32'd1;
        Din = 32'd0;
        rw = 5'd1;
        rd_ex_mem = 5'd5;
        rd_mem_wb = 5'd7;


        #(2*CLK_PERIOD);
        $finish;

    end
always #(CLK_PERIOD/2) clock = ~clock;
endmodule