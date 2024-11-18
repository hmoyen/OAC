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