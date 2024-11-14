module mux_4 (
    input  [1 :0]    select,
    input  [31:0]    D0,
    input  [31:0]    D1,
    input  [31:0]   D2,
    input  [31:0]   D3,
    output [31:0]   out
);

assign out = ( select == 2'd0   ) ? D0 : 
             ( select == 2'd1   ) ? D1 : 
             ( select == 2'd2   ) ? D2 :
                                    D3 ;
             
endmodule