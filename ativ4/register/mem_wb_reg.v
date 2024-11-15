module mem_wb_reg (
    input               clk,
    input               reset,
    input               branch_in,
    input               pc_load_in,
    input               pc_reset_in,
    input               reg_file_write_in,
    input       [31:0]  add_pc_in,
    input       [31:0]  add_in,
    input       [31:0]  mem_in,
    input       [31:0]  alu_result_in,
    input       [1:0]   select_mux_2_in,

    output reg          branch_out,
    output reg          pc_load_out,
    output reg          pc_reset_out,
    output reg          reg_file_write_out,
    output reg  [31:0]  add_pc_out,
    output reg  [31:0]  add_out,
    output reg  [31:0]  mem_out,
    output reg  [31:0]  alu_result_out,
    output reg  [1:0]   select_mux_2_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin

            branch_out          <= 1'b0;
            pc_load_out         <= 1'b0;
            pc_reset_out        <= 1'b0;
            reg_file_write_out  <= 1'b0;
            select_mux_2_out    <= 2'b0;

            add_pc_out          <= 32'b0;
            add_out             <= 32'b0;
            mem_out             <= 32'b0;
            alu_result_out      <= 32'b0;
        end else begin
            branch_out          <= branch_in;
            pc_load_out         <= pc_load_in;
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
