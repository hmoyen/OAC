module immediateG(
    input   [31:0]      instruction,
    output  [31:0]      immediate 
);

    assign immediate =  ( instruction[6:0] == 7'b0000011 ) ? {{20{instruction[31]}}, instruction[31:20]                                     } : // Type I 
                        ( instruction[6:0] == 7'b1100011 ) ? {{20{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:7] } : // Type SB
                        ( instruction[6:0] == 7'b0100011 ) ? {20'b0, instruction[31:25], instruction[11:7]                                  } : // Type S 
                        32'b0; // no use
endmodule              