module add_sub32 (
    input             op,
    input   [31:0]    A,
    input   [31:0]    B,
    output  [31:0]    R,
    output            carryOut
);
    wire [32:0] result;

    // op = 0 > adder
    // op = 1 > subtractor 2's complement

    assign result = !op ? A + B : A + ((~B) + 1); 

    assign R = result[31:0];

    // there isn't carry in subtraction
    assign carryOut = op ? result[32] : 1'b0;

endmodule