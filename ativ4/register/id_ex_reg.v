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
