module pc(
    input clock,
    input reset,
    input stall,
    input [31:0] pc_in,
    output [31:0] pc_out
);

reg [31:0] pc;
    always @(posedge clock) begin
        if(reset) begin
            pc <= 32'b0;
        end else if(~stall) begin
            pc <= pc_in;
        end else begin
            pc <= pc;
        end
    end

assign pc_out = pc;

endmodule