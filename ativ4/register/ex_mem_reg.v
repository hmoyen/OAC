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
