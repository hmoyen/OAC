module mod_reg(
        input [31:0] in, 
        input clk, 
        input load, 
        output reg [31:0] out
        );

    always @(posedge clk) begin
        if(load == 1'b1) out = in; 
    end
endmodule