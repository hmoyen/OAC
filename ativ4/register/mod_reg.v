module mod_reg(
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