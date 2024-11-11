module instruction_reg(
        input [31:0] in, 
        input clk, 
        input load, 
        output reg [31:0] out
        );

    always @(negedge clk) begin     // the only difference is in the clock edge logic, that waits for the negedge instead of posedge
        if(load == 1'b1) out <= in; // instruction register load when load enable
    end

endmodule