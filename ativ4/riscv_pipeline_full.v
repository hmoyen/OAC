module add_sub32 (
    input             op,
    input   [31:0]    A,
    input   [31:0]    B,
    output  [31:0]    R,
    output            carryOut
);
    wire [32:0] result;

    // op = 0 > adder
    // op = 1 > subtractor 2's complement

    assign result = !op ? A + B : A + ((~B) + 1); 

    assign R = result[31:0];

    // there isn't carry in subtraction
    assign carryOut = op ? result[32] : 1'b0;

endmodule

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
        .funct7e3_out(funct7e3_out),
        .mux3_selector(select_mux_3_out_mem),
        .branch_address(add_pc_out_ex)
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
        .add_pc_out()
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
        .select_mux_3_out(),
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
module mod_and (
    input   [31:0]    A,
    input   [31:0]    B,
    output  [31:0]    R
);
    assign R = A & B;
endmodule

module comparator (
    input   [31:0]    A,
    input   [31:0]    B,
    output            eq,
    output            lt,
    output            gt
);
    assign eq = ( A == B ); 
    assign lt = ( A <  B ); 
    assign gt = ( A >  B ); 
endmodule

module mod_or (
    input   [31:0]    A,
    input   [31:0]    B,
    output  [31:0]    R
);
    assign R = A | B;
endmodule

module mod_xor (
    input   [31:0]    A,
    input   [31:0]    B,
    output  [31:0]    R
);
    assign R = A ^ B;
endmodule

module alu_dp (
    input   [2: 0]    op,
    input   [31:0]    A,
    input   [31:0]    B,
    output  [3: 0]    flags,
    output  [31:0]    R
);

    wire eq, lt, gt;

    wire opAddSub = op[0];
    wire [31:0] resultAddSub;

    wire [31:0] resultOr;
    wire [31:0] resultXor;
    wire [31:0] resultAnd;

    comparator LOGIC (
            .A      ( A     ),
            .B      ( B     ),
            .eq     ( eq    ),
            .lt     ( lt    ),
            .gt     ( gt    )
    );

    // flags[0]: A != B
    // flags[1]: A == B
    // flags[2]: A < B
    // flags[3]: A > B

    assign flags[0] = !(eq);
    assign flags[1] = eq;
    assign flags[2] = lt;
    assign flags[3] = gt;

    add_sub32 ARITHMETIC (
            .op         ( opAddSub      ),
            .A          ( A             ),
            .B          ( B             ),
            .R          ( resultAddSub  ),
            .carryOut   (               )
    );

    mod_or OR (
        .A ( A          ),
        .B ( B          ),
        .R ( resultOr   )
    );

    mod_xor XOR (
        .A ( A          ),
        .B ( B          ),
        .R ( resultXor  )
    );

    mod_and AND (
        .A ( A          ),
        .B ( B          ),
        .R ( resultAnd  )
    );


    assign R =  ( (op ==  3'd0) || (op ==  3'd1) ) ? resultAddSub : // add or subtract
                (  op ==  3'd2 ) ? resultAnd :                      // and
                (  op ==  3'd3 ) ? resultOr  :                      // or
                (  op ==  3'd4 ) ? resultXor :                      // xor
                32'b0;                              
endmodule

module alu_uc (
    input               clk,
    input       [6:0]   funct7e3, 
    input       [1:0]   aluOp,
    input       [3:0]   flags,
    output              branch,
    output reg  [2:0]   op
);

parameter   add     = 3'd0,
            sub     = 3'd1,
            _and    = 3'd2,
            _or     = 3'd3,
            _xor    = 3'd4;

always @(*) begin
    
    case(aluOp)
        2'b00: begin
            op <= add;
        end
        2'b01: begin                // Type I
            casex(funct7e3)
                7'bxxxx000: begin   // addi
                    op <= add;
                end
            endcase
        end
        2'b10: begin                // Type R
            casex(funct7e3)
                7'b0000000: begin   // add
                    op <= add;
                end
                7'b0100000: begin   // sub
                    op <= sub;
                end
                7'bxxxx111: begin   // and
                    op <= _and;
                end
                7'bxxxx110: begin   // or
                    op <= _or;
                end
                7'bxxxx100: begin   // xor
                    op <= _xor;
                end
                default: begin
                    op <= add;
                end
            endcase
        end
        default: begin
            op <= add;
        end
    endcase

end

    // flags[0]: A != B
    // flags[1]: A == B
    // flags[2]: A < B
    // flags[3]: A > B

    assign branch = funct7e3[2:0] == 3'b001 ? flags[0]:  // bne (A != B)
                    (funct7e3[2:0] == 3'b000 ? flags[1]:  // beq (A == B)
                    (funct7e3[2:0] == 3'b100 ? flags[2]:  // blt (A <  B)
                    (funct7e3[2:0] == 3'b101 ? flags[3]:  // bgt (A >  B)
                    1'b0)));

endmodule

module immediateG(
    input   [31:0]      instruction,
    output  [31:0]      immediate 
);

    assign immediate =  ( instruction[6:0] == 7'b0000011 ) ? {{20{instruction[31]}}, instruction[31:20]                                     } : // Type I 
                        ( instruction[6:0] == 7'b1100011 ) ? {{20{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:7] } : // Type SB
                        ( instruction[6:0] == 7'b0100011 ) ? {20'b0, instruction[31:25], instruction[11:7]                                  } : // Type S 
                        32'b0; // no use
endmodule              module memory_file(
    input   [31:0]  addr,       // address
    input   [31:0]  Din,        // data input
    input           we,         // write enable
    input           re,         // read enable
    input           clk,
    output  [31:0]  out  
);

    integer i;
    parameter size = 256;

    reg [size - 1:0][31:0] memory;   // memory = 256 positions array for 32 bits 

    initial begin                   // starting memory positions
        for(i = 0; i < size; i = i + 1) begin
            memory[i] = 32'b0; 
        end   

        // memory[3] = 32'd17;  
        // memory[7] = 32'd5;
        // memory[18] = 32'd99;
        memory[3] = 32'd3;
        memory[4] = 32'd4;
        memory[5] = 32'd5;
        memory[6] = 32'd6;
        memory[7] = 32'd7;
        memory[18] = 32'd99;
    end

    always@(negedge clk) begin
        if(we == 1'b1) begin
            memory[addr] <= Din;
        end
    end

assign out = re ? memory[addr] : out;
endmodule

module memory_inst(
    input   [31:0]  addr,       // address
    input   [31:0]  Din,        // data input
    input           we,         // write enable
    input           re,         // read enable
    input           clk,
    output  [31:0]  out  
);

    integer i;
    parameter size = 256;

    reg [31:0] memory [size - 1:0];   // memory = 256 positions array for 32 bits 

    initial begin                   // starting memory positions
        for(i = 0; i < size; i = i + 1) begin
            memory[i] = 32'b0; 
        end      
        // //LW
        // //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[3] = Mem[3] = 17
        // memory[0] = 32'b000000000011_00000_010_00011_0000011;
        // //LW
        // //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[4] = Mem[7] = 5
        // memory[1] = 32'b000000000111_00000_010_00100_0000011;
        // //LW
        // //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[4] = Mem[Reg(3) + 1] = Mem[17 + 1] = 99
        // memory[2] = 32'b000000000001_00011_010_00100_0000011;
        // //SW 
        // //Estrutura da instrução = {offset[11:5], rs2, rs1, 010, offset[4:0], 0100011}
        // //salva o valor de reg[3] (= 17) em memory[100 = reg[4](= 99) + 1] 
        // memory[3] = 32'b0000000_00011_00100_010_00001_0100011;

        // //Operação: typeR
        // //Estrutura da instrução = {funct7, rs2, rs1, funct3, rd, opcode} = {funct7, Rb, Ra, funct3, rw, opcode}   
        // //ADD
        // //reg[15] = reg[3] + reg[4] = 99 + 17 = 116
        // memory[4] = 32'b0000000_00011_00100_000_01111_0110011;
        // //LW
        // //Estrutura da instrução de load = {imm[11:0], rs1, 010, rd, 0000011} -> RF[4] = Mem[7] = 5
        // memory[5] = 32'b000000000111_00000_010_00100_0000011;
        // //SUB
        // //reg[14] = reg[4] - reg[15] = 5 - 116 = -111
        // memory[6] = 32'b0100000_01111_00100_000_01110_0110011;
        // //SUB
        // //reg[14] = reg[4] - reg[15] = 116 - 5 = 111
        // memory[7] = 32'b0100000_00100_01111_000_01110_0110011;

        // //AND
        // //reg[6] = reg[14] (111) & reg[4] (5)
        // memory[8] = 32'b0000000_00100_01110_111_00110_0110011;
        // //OR
        // //reg[6] = reg[14] (-17) | reg[4] (5)
        // memory[9] = 32'b0000000_00100_01110_110_00111_0110011;

        // //TIPO SB        
        // //Estrutura da instrução = {{imm[12], imm[10:5]}, rs2, rs1, 3'b000, {imm[4:1], imm[11]}, 7'b1100011}
        // //BEQ
        // //if(reg[15] (116) == reg[6] (5)): então faz branch (OBS: nesse caso não ocorre) imm = 16
        // memory[10] = 32'b0_000000_01111_00110_000_1000_0_1100011;
        // //BEQ
        // //if(reg[4] (5) == reg[6] (5)): então faz branch (OBS: nesse caso ocorre) imm = 16 
        // memory[11] = 32'b0_000000_00100_00110_000_1000_0_1100011;


        // Instrução: lw x1, 3(x0)
        // Binário: 000000000011_00000_010_00001_0000011
        memory[0] = 32'b000000000011_00000_010_00001_0000011; // lw x1, 3(x0)

        // // Instrução: add x10, x1, x0
        // // Binário: 0000000_00000_00001_000_01010_0110011
        // memory[1] = 32'b0000000_00000_00001_000_01010_0110011; // add x10, x1, x0

        // // // Instrução: sw x10, 9(x0)
        // // // Binário: 0000000_00011_00000_010_01001_0100011
        // memory[2] = 32'b0000000_01010_00000_010_01001_0100011; // sw x10, 9(x0)

        // Instrução: lw x2, 3(x0)
        // Binário: 000000000101_00000_010_00010_0000011
        memory[1] = 32'b000000000011_00000_010_00010_0000011; //

        // Instrução: lw x3, 7(x0)
        // Binário: 000000000111_00000_010_00011_0000011
        memory[2] = 32'b000000000111_00000_010_00011_0000011; //

        // Instrução: lw x4, 4(x0)
        // Binário: 000000000100_00000_010_00100_0000011
        memory[3] = 32'b000000000100_00000_010_00100_0000011; //

        // Instrução: lw x5, 3(x0)
        // Binário: 000000000100_00000_010_00100_0000011
        memory[4] = 32'b000000000011_00000_010_00101_0000011; //

        // // Instrução: lw x5, 3(x0)
        // // Binário: 000000000100_00000_010_00100_0000011
        // memory[5] = 32'b000000000011_00000_010_00101_0000011; //

        // Instrução: add x10, x1, x5
        // Binário: 0000000_00000_00001_000_01010_0110011
        memory[5] = 32'b0000000_00101_00001_000_01010_0110011; // add x10, x1, x0

        //BEQ
        //if(reg[1] == reg[10]): então faz branch (OBS: nesse caso ocorre) imm = 16 
        memory[6] = 32'b0_000000_00001_00001_000_1000_0_1100011;

        // Instrução: lw x5, 3(x0)
        // Binário: 000000000100_00000_010_00100_0000011
        memory[7] = 32'b000000000011_00000_010_00101_0000011; //

        // // Instrução: add x10, x3, x0
        // // Binário: 0000000_00000_00001_000_01010_0110011
        // memory[7] = 32'b0000000_00000_00011_000_01010_0110011; // add x10, x1, x0

        memory[22] = 32'b0000000_00010_00010_000_01011_0110011; // add x11, x2, x2


        // // Instrução: add x11, x2, x1
        // // Binário: 0000000_00001_00010_000_01011_0110011
        // memory[5] = 32'b0000000_00001_00010_000_01011_0110011; // add x11, x2, x1

        // // Instrução: sw x3, 9(x0)
        // // Binário: 0000000_00011_00000_010_01001_0100011
        // memory[6] = 32'b0000000_00011_00000_010_01001_0100011; // sw x3, 9(x0)

        
    end

    always@(posedge clk) begin
        if(we == 1'b1) begin
            memory[addr] <= Din;
        end
    end

assign out = re ? memory[addr] : out;
endmodule

module mux_4 (
    input  [1 :0]    select,
    input  [31:0]    D0,
    input  [31:0]    D1,
    input  [31:0]   D2,
    input  [31:0]   D3,
    output [31:0]   out
);

assign out = ( select == 2'd0   ) ? D0 : 
             ( select == 2'd1   ) ? D1 : 
             ( select == 2'd2   ) ? D2 :
                                    D3 ;
             
endmodule

module mux_2 #(
    parameter WIDTH = 32
) (
    input  select,
    input  [WIDTH-1:0]    D0,
    input  [WIDTH-1:0]    D1,
    output [WIDTH-1:0]    out
);

assign out = ( select == 1'b0   ) ? D0 : D1;
             
endmodule

module instruction_reg(
        input [31:0] in, 
        input clk, 
        input load, 
        output reg [31:0] out
        );

    always @(negedge clk) begin     // the only difference is in the clock edge logic, that waits for the negedge instead of posedge
        if(load == 1'b1) out <= in; // instruction register load when load enable
    end

endmodule

module mod_reg_param #(
    parameter N = 32
) (
        input [N-1:0] in, 
        input clk, 
        input load, 
        output reg [N-1:0] out
        );

    always @(posedge clk) begin
        if(load == 1'b1) out = in; 
    end

endmodule

module mod_reg(
        input [31:0] in, 
        input clk, 
        input load, 
        input reset,
        output reg [31:0] out
        );

    always @(negedge clk) begin
        if(reset) begin
            out = 1'b0;
        end else begin
            if(load == 1'b1) out = in; 
        end
    end
endmodule

module reg_file (
    input   [4:0]   ra,     
    input   [4:0]   rb,         
    input           we,     // write enable             
    input   [31:0]  Din,       
    input   [4: 0]  rw,     // register write        
    input           clk,
    input reset,              
    output  [31:0]  DoutA, 
    output  [31:0]  DoutB  
);

    wire [31:0] r_out [31:0];   // 32x 32 bit registers
    reg [31:0] we_reg;          // write enable for all registers 
    integer j;
    
    initial begin
        we_reg <= 32'b0;        // start the WE's 
    end

    always @ (*) begin
        for(j = 0; j < 32; j = j + 1)
            we_reg[j] <= 1'b0;              // reset the WE for all registers
        if(we == 1'b1) we_reg[rw] <= 1'b1;  // case for WE in a selected register
    end

    mod_reg x0 (.in(32'b0), .clk(clk), .load(1'b1), .out(r_out[0]), .reset(1'b0));    // x0

    genvar i;       // creating all the registers
    generate    
        for(i = 1; i < 32; i = i+1) begin
            mod_reg xI (.in(Din), .clk(clk), .load(we_reg[i]), .out(r_out[i]), .reset(reset)); // xI
        end
    endgenerate
    
    assign DoutA = r_out[ra];
    assign DoutB = r_out[rb];

endmodule

module ex_mem_reg (
    input               clk,
    input               reset,
    input               branch_instruction_in,
    input               mem_re_in,
    input               mem_we_in,
    input               reg_file_write_in,
    input               branch_in,
    input       [1:0]   select_mux_2_in,
    input       [1:0]   select_mux_4_in,
    input       [31:0]  reg_b_in,
    input       [4:0]   addr_rd_in,
    input       [31:0]  alu_in,
    input       [31:0]  add_pc_in,
    output reg          mem_re_out,
    output reg          mem_we_out,
    output reg          reg_file_write_out,
    output reg          branch_out,
    output reg  [1:0]   select_mux_2_out,
    output reg  [1:0]   select_mux_4_out,
    output reg  [31:0]  reg_b_out,
    output reg  [31:0]  alu_out,
    output reg          branch_instruction_out,
    output reg [4:0]    addr_rd_out,
    output reg  [31:0]  add_pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin

            mem_re_out          <= 1'b0;
            mem_we_out          <= 1'b0;
            branch_instruction_out <= 1'b0;
            reg_file_write_out  <= 1'b0;
            branch_out          <= 1'b0;
            select_mux_2_out    <= 2'b0;
            select_mux_4_out    <= 2'b0;
            addr_rd_out         <= 5'b0;
            reg_b_out           <= 32'b0;
            alu_out             <= 32'b0;
            add_pc_out          <= 32'b0;
        end else begin

            mem_re_out          <= mem_re_in;
            mem_we_out          <= mem_we_in;
            reg_file_write_out  <= reg_file_write_in;
            branch_out          <= branch_in;
            select_mux_2_out    <= select_mux_2_in;
            select_mux_4_out    <= select_mux_4_in;
            branch_instruction_out <= branch_instruction_in;

            addr_rd_out         <= addr_rd_in;
            reg_b_out           <= reg_b_in;
            alu_out             <= alu_in;
            add_pc_out          <= add_pc_in;
        end
    end

endmodule
module id_ex_reg (
    input               clk,
    input               reset,
    input               mem_re_in,
    input               mem_we_in,
    input               branch_instruction_in,
    input               reg_file_write_in,
    input       [1:0]   alu_op_in,
    input       [4:0]   addr_rd_in,
    input       [1:0]   select_mux_1_in,
    input       [1:0]   select_mux_2_in,
    input       [1:0]   select_mux_4_in,
    input       [31:0]  reg_a_in,
    input       [31:0]  reg_b_in,
    input       [31:0]  immediate_in,
    input       [31:0]  pc_in,            
    input       [6:0]   funct7e3_in,

    output reg          mem_re_out,
    output reg          branch_instruction_out,
    output reg          mem_we_out,
    output reg          reg_file_write_out,
    output reg  [1:0]   alu_op_out,
    output reg  [1:0]   select_mux_1_out,
    output reg  [1:0]   select_mux_2_out,
    output reg  [1:0]   select_mux_4_out,
    output reg  [31:0]  reg_a_out,
    output reg  [31:0]  reg_b_out,
    output reg  [31:0]  immediate_out,
    output reg  [31:0]  pc_out,    
    output reg  [4:0]   addr_rd_out,       
    output reg  [6:0]   funct7e3_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_re_out          <= 1'b0;
            mem_we_out          <= 1'b0;
            reg_file_write_out  <= 1'b0;
            alu_op_out          <= 2'b0;
            select_mux_1_out    <= 2'b0;
            select_mux_2_out    <= 2'b0;
            select_mux_4_out    <= 2'b0;
            branch_instruction_out <= 1'b0;
            
            reg_a_out           <= 32'b0;
            addr_rd_out         <= 5'b0;
            reg_b_out           <= 32'b0;
            immediate_out       <= 32'b0;
            pc_out              <= 32'b0;   
            funct7e3_out        <= 7'b0;
        end else begin
            mem_re_out          <= mem_re_in;
            branch_instruction_out <= branch_instruction_in;
            mem_we_out          <= mem_we_in;
            reg_file_write_out  <= reg_file_write_in;
            alu_op_out          <= alu_op_in;
            select_mux_1_out    <= select_mux_1_in;
            select_mux_2_out    <= select_mux_2_in;
            select_mux_4_out    <= select_mux_4_in;

            addr_rd_out         <= addr_rd_in;            
            reg_a_out           <= reg_a_in;
            reg_b_out           <= reg_b_in;
            immediate_out       <= immediate_in;
            pc_out              <= pc_in;     
            funct7e3_out        <= funct7e3_in;
        end
    end

endmodule
module mem_wb_reg (
    input               clk,
    input               reset,
    input               select_mux_3_in,
    input               pc_load_in,
    input        [4:0]  addr_rd_in,
    input               pc_reset_in,
    input               reg_file_write_in,
    input       [31:0]  add_pc_in,
    input       [31:0]  add_in,
    input       [31:0]  mem_in,
    input       [31:0]  alu_result_in,
    input       [1:0]   select_mux_2_in,

    output reg          branch_out,
    output reg          select_mux_3_out,
    output reg          pc_load_out,
    output reg          pc_reset_out,
    output reg          reg_file_write_out,
    output reg  [4:0]   addr_rd_out,
    output reg  [31:0]  add_pc_out,
    output reg  [31:0]  add_out,
    output reg  [31:0]  mem_out,
    output reg  [31:0]  alu_result_out,
    output reg  [1:0]   select_mux_2_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin

            select_mux_3_out          <= 1'b0;
            pc_load_out         <= 1'b0;
            pc_reset_out        <= 1'b0;
            reg_file_write_out  <= 1'b0;
            select_mux_2_out    <= 2'b0;
            addr_rd_out         <= 5'b0;

            add_pc_out          <= 32'b0;
            add_out             <= 32'b0;
            mem_out             <= 32'b0;
            alu_result_out      <= 32'b0;
        end else begin
            select_mux_3_out          <= select_mux_3_in;
            pc_load_out         <= pc_load_in;
            addr_rd_out          <= addr_rd_in;
            pc_reset_out        <= pc_reset_in;
            reg_file_write_out  <= reg_file_write_in;
            select_mux_2_out    <= select_mux_2_in;

            add_pc_out          <= add_pc_in;
            add_out             <= add_in;
            mem_out             <= mem_in;
            alu_result_out      <= alu_result_in;
        end
    end

endmodule
module if_id_register(
    input clock,
    input reset,
    input load,
    input [31:0] instruction_in,
    input [31:0] pc_in,
    output [31:0] instruction_out,
    output [31:0] pc_out
);

reg [31:0] instruction, pc;

always @(posedge clock) begin
    if(reset) begin
        instruction <= 32'b0;
        pc <= 32'b0;
    end else if (load) begin
        instruction <= instruction_in;
        pc <= pc_in;
    end else begin
        instruction <= instruction;
        pc <= pc;
    end
end

assign instruction_out = instruction;
assign pc_out = pc;

endmodule

module controller (
    input               clock,
    input               reset,
    input       [6 :0]  opcode,
    output reg          mem_re,
    output reg          mem_we,
    output reg          reg_file_write,
    output reg          branch_instruction,
    output reg  [1 :0]  alu_op,
    output reg  [1 :0]  select_mux_1,
    output reg  [1 :0]  select_mux_2,
    output reg  [1 :0]  select_mux_4
);

    always @(negedge clock or posedge reset) begin
        if (reset) begin

            mem_re          <= 1'b0;
            mem_we          <= 1'b0;
            reg_file_write  <= 1'b0;
            alu_op          <= 2'b0;
            select_mux_1    <= 2'b0;
            select_mux_2    <= 2'b0;
            select_mux_4    <= 2'b0;
            branch_instruction <= 1'b0;

        end else begin
            case (opcode)
                7'b0110011: begin   // R-type
                    mem_re          <= 1'b0;
                    mem_we          <= 1'b0;
                    reg_file_write  <= 1'b1;
                    alu_op          <= 2'b10;
                    select_mux_1    <= 2'b0;
                    select_mux_2    <= 2'b1;
                    select_mux_4    <= 2'b0;
                    branch_instruction <= 1'b0;
                end    
                7'b0000011: begin   // I-type
                    mem_re          <= 1'b1;
                    mem_we          <= 1'b0;
                    reg_file_write  <= 1'b1;
                    alu_op          <= 2'b01;
                    select_mux_1    <= 2'b1;
                    select_mux_2    <= 2'b0;
                    select_mux_4    <= 2'b0;
                    branch_instruction <= 1'b0;
                end    
                7'b0100011: begin   // S-type
                    mem_re          <= 1'b0;
                    mem_we          <= 1'b1;
                    reg_file_write  <= 1'b0;
                    alu_op          <= 2'b00;
                    select_mux_1    <= 2'b1;
                    select_mux_2    <= 2'b0;
                    select_mux_4    <= 2'b01;
                    branch_instruction <= 1'b0;
                end
                7'b1100011: begin   // SB-type (branch)
                    mem_re          <= 1'b0;
                    mem_we          <= 1'b0;
                    reg_file_write  <= 1'b0;
                    alu_op          <= 2'b00;
                    select_mux_1    <= 2'b0;
                    select_mux_2    <= 2'b0;
                    select_mux_4    <= 2'b0;
                    branch_instruction <= 1'b1;
                end
                default: begin      // Default case: reset all outputs
                    mem_re          <= 1'b0;
                    mem_we          <= 1'b0;
                    reg_file_write  <= 1'b0;
                    alu_op          <= 2'b0;
                    select_mux_1    <= 2'b0;
                    select_mux_2    <= 2'b0;
                    select_mux_4    <= 2'b0;
                    branch_instruction <= 1'b0;
                end
            endcase
        end
    end

endmodule

module hazard(
    input clock,
    input reset,
    input select_mux_3,
    input select_mux_3_wb,
    input [6:0] opcode,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_ex_mem,
    input [4:0] rd_mem_wb,
    input branch_instruction_controller,
    input branch_instruction_id_ex,
    output pc_load,
    output if_id_load,
    output mux5_selector
);

parameter [6:0] RTYPE = 7'b0110011,
                STYPE = 7'b0100011,
                SBTYPE = 7'b1100011,
                ITYPE =  7'b0000011;


wire data_hazard;
assign data_hazard = (((opcode == RTYPE) || (opcode == STYPE) || (opcode == SBTYPE) || (opcode == ITYPE)) && 
                     (((rs1 != 0) && ((rs1 == rd_ex_mem) || (rs1 == rd_mem_wb))))) ||
                     (((opcode == RTYPE) || (opcode == STYPE) || (opcode == SBTYPE)) && 
                     ((rs2 != 0) && ((rs2 == rd_ex_mem) || (rs2 == rd_mem_wb))));

assign pc_load = ~(data_hazard || ((opcode == SBTYPE) && !branch_instruction_id_ex));
assign if_id_load = ~(data_hazard);
assign mux5_selector = data_hazard ;

endmodule
module instruction_decode(
    input clock,
    input reset,
    input write_enable,
    input select_mux_3,
    input select_mux_3_wb,
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
    output  [6:0]   funct7e3_out,
    output          mux3_selector,
    output  [31:0]   branch_address
);

parameter [6:0] RTYPE = 7'b0110011,
                STYPE = 7'b0100011,
                SBTYPE = 7'b1100011,
                ITYPE =  7'b0000011;

wire [4:0] s_ra, s_rb, s_rd;
wire [31:0] s_out_a, s_out_b, s_immediate, s_branch_address;
wire s_pc_load, s_if_id_load, s_mux5_selector;
wire s_do_branch;
wire mem_re_int, mem_we_int, reg_file_write_int, branch_instruction_int, branch_instruction_id_ex;
wire [1:0] alu_op_int, select_mux_1_int, select_mux_2_int, select_mux_4_int;

hazard HAZARD(
    .clock(clock),
    .reset(reset),
    .rs1(s_ra),
    .select_mux_3(select_mux_3),
    .select_mux_3_wb(select_mux_3_wb),
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
    .addr_rd_in(s_mux5_selector ? 5'b0 : s_rd),
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
    .branch_instruction_in(s_mux5_selector ? 1'b0 : branch_instruction_int),
    .branch_instruction_out(branch_instruction_id_ex),
    .funct7e3_out(funct7e3_out)
);

assign s_ra = instruction[19:15];
assign s_rb = instruction[24:20];
assign s_rd = instruction[11:7];
assign pc_load = s_pc_load;
assign if_id_load = s_if_id_load;
assign branch_instruction = branch_instruction_id_ex;

assign branch_address = pc + s_immediate;
assign mux3_selector = (s_out_a == s_out_b) && (instruction[6:0] == SBTYPE);


endmodule

module instruction_fetch(
    input clock,
    input reset,
    input pc_load,
    input if_id_load,
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
    .load(pc_load),
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
    .load(if_id_load),
    .reset(reset),
    .instruction_in(s_instruction_out),
    .pc_in(s_pc_out),
    .instruction_out(instruction_out),
    .pc_out(pc_out)
);

endmodule

module pc(
    input clock,
    input reset,
    input load,
    input [31:0] pc_in,
    output [31:0] pc_out
);

reg [31:0] pc;
    always @(negedge clock) begin
        if(reset) begin
            pc <= 32'b0;
        end else if(load) begin
            pc <= pc_in;
        end else begin
            pc <= pc;
        end
    end

assign pc_out = pc;

endmodule

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
module mem (
    input               clk,
    input               reset,
    input               mem_we,
    input               mem_re,
    input   [4:0]       addr_rd_in,
    input               branch_instruction,
    input               branch_in,
    input               reg_file_write_in,
    input       [31:0]  alu_out,
    input       [31:0]  reg_out_b,
    input       [1:0]   select_mux_4_in,
    input       [1:0]   select_mux_2_in,
    output              reg_file_write_out,
    output      [4:0]   addr_rd_out,
    output      [31:0]  mem_out,
    output      [31:0]  alu_result_out,
    output      [1:0]   select_mux_2_out,
    output              select_mux_3_out,
    output             select_mux_3_out_wb
);

    // Wire declarations
    wire [31:0] mem_data_out, mux_4_out;

    assign select_mux_3_out = branch_instruction & branch_in;

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
        .addr_rd_in         (addr_rd_in),
        .select_mux_3_in    (select_mux_3_out),
        .add_pc_in          (           ),
        .mem_in             ( mem_data_out       ),
        .alu_result_in      ( alu_out            ),
        .select_mux_2_in    ( select_mux_2_in    ),

        .reg_file_write_out ( reg_file_write_out ),
        .add_pc_out         (       ),
        .mem_out            ( mem_out            ),
        .select_mux_3_out   (select_mux_3_out_wb),
        .addr_rd_out        (addr_rd_out),
        .alu_result_out     ( alu_result_out     ),
        .select_mux_2_out   ( select_mux_2_out   )
    );

endmodule
module wb (
    input wire reg_file_write_in,
    input  wire [4:0] addr_rd,   // 5-bit input
    input  wire [1:0] select_mux_2, // Select input for mux_4
    input  wire [31:0] mem_out,  // 32-bit input to mux_4
    input  wire [31:0] alu_out,  // 32-bit input to mux_4
    output wire [31:0] mux_2_out, // 32-bit output from mux_4
    output wire [4:0] addr_out,   // 5-bit output (same as addr_rd)
    output wire reg_file_write_out
);

    assign addr_out = addr_rd;
    assign reg_file_write_out = reg_file_write_in;

    // Instantiate mux_4
    mux_4 MUX_2 (
        .select (select_mux_2),
        .D0     (mem_out),
        .D1     (alu_out),
        .D2     (32'b0),       // Unused inputs are tied to 0
        .D3     (32'b0),       // Unused inputs are tied to 0
        .out    (mux_2_out)
    );

endmodule
