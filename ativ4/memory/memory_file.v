module memory_file(
    input   [31:0]  addr,       // address
    input   [31:0]  Din,        // data input
    input           we,         // write enable
    input           re,         // read enable
    input           clk,
    output  [31:0]  out  
);

    integer i;
    parameter size = 256;

    reg [size - 1:0][31:0] memory;   // memory = 256 positions array for 32 bits 

    initial begin                   // starting memory positions
        for(i = 0; i < size; i = i + 1) begin
            memory[i] = 32'b0; 
        end   

        memory[3] = 32'd17;   
    end

    always@(posedge clk) begin
        if(we == 1'b1) begin
            memory[addr] <= Din;
        end
    end

assign out = re ? memory[addr] : out;
endmodule