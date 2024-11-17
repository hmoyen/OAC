module instruction_decode(
    input clock,
    input reset,
    input write_enable,
    input branch_instruction_id_ex,
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
    output  [6:0]   funct7e3_out
);

wire [4:0] s_ra, s_rb, s_rd;
wire [31:0] s_out_a, s_out_b, s_immediate;
wire s_pc_load, s_if_id_load, s_mux5_selector;
wire mem_re_int, mem_we_int, reg_file_write_int, branch_instruction_int;
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
    .select_mux_2_in(ss_mux5_selector ? 2'b0  : elect_mux_2_int),
    .select_mux_4_in(s_mux5_selector ? 2'b0  : select_mux_4_int),
    .reg_a_in(s_out_a),
    .reg_b_in(s_out_b),
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
    .funct7e3_out(funct7e3_out)
);

assign s_ra = instruction[19:15];
assign s_rb = instruction[24:20];
assign s_rd = instruction[11:7];
assign pc_load = s_pc_load;
assign if_id_load = s_if_id_load;
assign branch_instruction = branch_instruction_int;

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

    always @(posedge clock or posedge reset) begin
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
                SBTYPE = 7'b1100011;


wire data_hazard;
assign data_hazard = ((opcode == RTYPE) || (opcode == STYPE) || (opcode == SBTYPE)) && 
                     (((rs1 != 0) && ((rs1 == rd_ex_mem) || (rs1 == rd_mem_wb))) ||
                     ((rs2 != 0) && ((rs2 == rd_ex_mem) || (rs2 == rd_mem_wb))));

assign pc_load = ~(branch_instruction_controller || branch_instruction_id_ex || data_hazard);
assign if_id_load = ~(data_hazard || branch_instruction_controller || branch_instruction_id_ex);
assign mux5_selector = data_hazard || branch_instruction_id_ex;

endmodule
module id_ex_reg (
    input               clk,
    input               reset,
    input               mem_re_in,
    input               mem_we_in,
    input               reg_file_write_in,
    input       [1:0]   alu_op_in,
    input       [1:0]   select_mux_1_in,
    input       [1:0]   select_mux_2_in,
    input       [1:0]   select_mux_4_in,
    input       [31:0]  reg_a_in,
    input       [31:0]  reg_b_in,
    input       [31:0]  immediate_in,
    input       [31:0]  pc_in,            
    input       [6:0]   funct7e3_in,

    output reg          mem_re_out,
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
            
            reg_a_out           <= 32'b0;
            reg_b_out           <= 32'b0;
            immediate_out       <= 32'b0;
            pc_out              <= 32'b0;   
            funct7e3_out        <= 7'b0;
        end else begin
            mem_re_out          <= mem_re_in;
            mem_we_out          <= mem_we_in;
            reg_file_write_out  <= reg_file_write_in;
            alu_op_out          <= alu_op_in;
            select_mux_1_out    <= select_mux_1_in;
            select_mux_2_out    <= select_mux_2_in;
            select_mux_4_out    <= select_mux_4_in;
            
            reg_a_out           <= reg_a_in;
            reg_b_out           <= reg_b_in;
            immediate_out       <= immediate_in;
            pc_out              <= pc_in;     
            funct7e3_out        <= funct7e3_in;
        end
    end

endmodule
module immediateG(
    input   [31:0]      instruction,
    output  [31:0]      immediate 
);

    assign immediate =  ( instruction[6:0] == 7'b0000011 ) ? {{20{instruction[31]}}, instruction[31:20]                                     } : // Type I 
                        ( instruction[6:0] == 7'b1100011 ) ? {{20{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:7] } : // Type SB
                        ( instruction[6:0] == 7'b0100011 ) ? {20'b0, instruction[31:25], instruction[11:7]                                  } : // Type S 
                        32'b0; // no use
endmodule              module mod_reg(
        input [31:0] in, 
        input clk, 
        input load, 
        input reset,
        output reg [31:0] out
        );

    always @(posedge clk) begin
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
            mod_reg xI (.in(Din), .clk(clk), .load(we_reg[i]), .out(r_out[i]), .reset(1'b0)); // xI
        end
    endgenerate
    
    assign DoutA = r_out[ra];
    assign DoutB = r_out[rb];

endmodule