module if_id_register(
    input clock,
    input reset,
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
    end else begin
        instruction <= instruction_in;
        pc <= pc_in;
    end
end

assign instruction_out = instruction;
assign pc_out = pc;

endmodule