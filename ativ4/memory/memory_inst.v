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

        // Instrução: add x10, x1, x0
        // Binário: 0000000_00000_00001_000_01010_0110011
        memory[1] = 32'b0000000_00000_00001_000_01010_0110011; // add x10, x1, x0

        // // Instrução: sw x10, 9(x0)
        // // Binário: 0000000_00011_00000_010_01001_0100011
        memory[2] = 32'b0000000_01010_00000_010_01001_0100011; // sw x10, 9(x0)

        // // Instrução: lw x2, 5(x0)
        // // Binário: 000000000101_00000_010_00010_0000011
        // memory[1] = 32'b000000000101_00000_010_00010_0000011; // lw x2, 5(x0)

        // // Instrução: lw x3, 7(x0)
        // // Binário: 000000000111_00000_010_00011_0000011
        // memory[2] = 32'b000000000111_00000_010_00011_0000011; // lw x3, 7(x0)

        // // Instrução: lw x4, 4(x0)
        // // Binário: 000000000100_00000_010_00100_0000011
        // memory[3] = 32'b000000000100_00000_010_00100_0000011; // lw x4, 4(x0)

        // // Instrução: add x10, x1, x0
        // // Binário: 0000000_00000_00001_000_01010_0110011
        // memory[4] = 32'b0000000_00000_00001_000_01010_0110011; // add x10, x1, x0

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