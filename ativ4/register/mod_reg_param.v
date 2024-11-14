module mod_reg_param #(
    parameter N = 32
) (
        input [N-1:0] in, 
        input clk, 
        input load, 
        output reg [N-1:0] out
        );

    always @(posedge clk) begin
        if(load == 1'b1) out = in; 
    end

endmodule