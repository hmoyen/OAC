module wb (
    input  wire [4:0] addr_rd,   // 5-bit input
    input  wire [1:0] select_mux_2, // Select input for mux_4
    input  wire [31:0] mem_out,  // 32-bit input to mux_4
    input  wire [31:0] alu_out,  // 32-bit input to mux_4
    output wire [31:0] mux_2_out, // 32-bit output from mux_4
    output wire [4:0] addr_out   // 5-bit output (same as addr_rd)
);

    assign addr_out = addr_rd;

    // Instantiate mux_4
    mux_4 MUX_2 (
        .select (select_mux_2),
        .D0     (mem_out),
        .D1     (alu_out),
        .D2     (32'b0),       // Unused inputs are tied to 0
        .D3     (32'b0),       // Unused inputs are tied to 0
        .out    (mux_2_out)
    );

endmodule
