module ref_file (
    input   [4:0]   ra,     
    input   [4:0]   rb,         
    input           we,     // write enable             
    input   [63:0]  Din,       
    input   [4: 0]  rw,     // register write        
    input           clk,              
    output  [63:0]  DoutA, 
    output  [63:0]  DoutB  
);

    wire [31:0] r_out [31:0];   // 32x 32 bit registers
    reg [31:0] we_reg;          // write enable for all registers 
    integer j;
    
    initial begin
        we_reg <= 32'b0;        // start the WE's 
    end

    always @ (*) begin
        for(j = 0; j < 32; j = j + 1)
            we_reg[j] <= 1'b0;              // reset the WE for all registers
        if(we == 1'b1) we_reg[rw] <= 1'b1;  // case for WE in a selected register
    end

    mod_reg x0 (.in(32'b0), .clk(clk), .load(1'b1), .out(r_out[0]));    // x0

    genvar i;       // creating all the registers
    generate    
        for(i = 1; i < 32; i = i+1) begin
            mod_reg xI (.in(Din), .clk(clk), .load(we_reg[i]), .out(r_out[i])); // xI
        end
    endgenerate
    
    assign doutA = r_out[ra];
    assign doutB = r_out[rb];

endmodule