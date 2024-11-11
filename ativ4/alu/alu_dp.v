module alu_dp (
    input   [2: 0]    op,
    input   [31:0]    A,
    input   [31:0]    B,
    output  [3: 0]    flags,
    output  [31:0]    R,
);

    wire eq, lt, gt;

    wire opAddSub = op[1];
    wire [31:0] resultAddSub;

    wire [31:0] resultOr;
    wire [31:0] resultXor;
    wire [31:0] resultAnd;

    comparator LOGIC (
            .A      ( A     ),
            .B      ( B     ),
            .eq     ( eq    ),
            .lt     ( lt    ),
            .gt     ( gt    )
    );

    // flags[0]: A != B
    // flags[1]: A == B
    // flags[2]: A < B
    // flags[3]: A > B

    assign flags[0] = !(eq);
    assign flags[1] = eq;
    assign flags[2] = lt;
    assign flags[3] = gt;

    add_sub32 ARITHMETIC (
            .op         ( opAddSub      ),
            .A          ( A             ),
            .B          ( B             ),
            .R          ( resultAddSub  ),
            .carryOut   (               )
    );

    mod_or OR (
        .A ( A          ),
        .B ( B          ),
        .R ( resultOr   )
    );

    mod_xor XOR (
        .A ( A          ),
        .B ( B          ),
        .R ( resultXor  )
    );

    mod_and AND (
        .A ( A          ),
        .B ( B          ),
        .R ( resultAnd  )
    );


    assign R =  ( (op ==  3'd0) || (op ==  3'd1) ) ? resultAddSub : // add or subtract
                (  op ==  3'd2 ) ? resultAnd :                      // and
                (  op ==  3'd3 ) ? resultOr  :                      // or
                (  op ==  3'd4 ) ? resultXor :                      // xor
                32'b0;                              
endmodule