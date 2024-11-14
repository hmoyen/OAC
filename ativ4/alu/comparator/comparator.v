module comparator (
    input   [31:0]    A,
    input   [31:0]    B,
    output            eq,
    output            lt,
    output            gt
);
    assign eq = ( A == B ); 
    assign lt = ( A <  B ); 
    assign gt = ( A >  B ); 
endmodule