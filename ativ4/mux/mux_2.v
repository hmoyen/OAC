module mux_2 #(
    parameter WIDTH = 32
) (
    input  select,
    input  [WIDTH-1:0]    D0,
    input  [WIDTH-1:0]    D1,
    output [WIDTH-1:0]    out
);

assign out = ( select == 1'b0   ) ? D0 : D1;
             
endmodule