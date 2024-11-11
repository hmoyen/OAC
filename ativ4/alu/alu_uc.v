module alu_uc (
    input               clk,
    input       [6:0]   funct7e3, 
    input       [1:0]   aluOp,
    input       [3:0]   flags,
    output              branch,
    output reg  [2:0]   op
);

parameter   add     = 3'd0,
            sub     = 3'd1,
            _and    = 3'd2,
            _or     = 3'd3,
            _xor    = 3'd4;

always @(*) begin
    
    case(aluOp)
        2'b00: begin
            op <= add;
        end
        2'b01: begin                // Type I
            casex(funct7e3)
                7'bxxxx000: begin   // addi
                    op <= add;
                end
            endcase
        end
        2'b10: begin                // Type R
            casex(funct7e3)
                7'b0000000: begin   // add
                    op <= add;
                end
                7'b0100000: begin   // sub
                    op <= _sub;
                end
                7'bxxxx111: begin   // and
                    op <= _and;
                end
                7'bxxxx110: begin   // or
                    op <= _or;
                end
                7'bxxxx100: begin   // xor
                    op <= _xor;
                end
                default: begin
                    op <= add;
                end
            endcase
        end
        default: begin
            op <= add;
        end
    endcase

end

    // flags[0]: A != B
    // flags[1]: A == B
    // flags[2]: A < B
    // flags[3]: A > B

    assign branch = funct7e3[2:0] == 3'b001 ? flags[0]:  // bne (A != B)
                    funct7e3[2:0] == 3'b000 ? flags[1]:  // beq (A == B)
                    funct7e3[2:0] == 3'b100 ? flags[2]:  // blt (A <  B)
                    funct7e3[2:0] == 3'b101 ? flags[3]:  // bgt (A >  B)

endmodule