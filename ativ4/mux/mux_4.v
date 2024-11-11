module mux_4 (
    input [1:0]     select,
    input           D0,
    input           D1,
    input           D2,
    input           D3,
    output          out
);

assign out = ( select == 2'd0   ) ? D0 : 
             ( select == 2'd1   ) ? D1 : 
             ( select == 2'd2   ) ? D2 :
                                    D3 ;
             
endmodule