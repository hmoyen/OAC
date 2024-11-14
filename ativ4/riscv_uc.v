module riscv_uc (
    input               clk,
    input               reset,
    input       [6 :0]  opcode,
    input               branch,
    output reg          pc_load,
    output reg          pc_reset,
    output reg          mem_re,
    output reg          mem_we,
    output reg          reg_file_write,
    output reg  [1 :0]  alu_op,
    output reg  [1 :0]  select_mux_1,
    output reg  [1 :0]  select_mux_2,
    output reg  [1 :0]  select_mux_3,
    output reg  [1 :0]  select_mux_4
);

    reg [4:0] currentState;
    reg [4:0] nextState;

    parameter IDLE = 5'd0,
              IF   = 5'd1,
              ID   = 5'd2,
              EX   = 5'd3,
              MEM  = 5'd4,
              WB   = 5'd5,
              DONE = 5'd6;
    
    initial begin
        pc_load         <= 1'b0;
        pc_reset        <= 1'b0;
        mem_re          <= 1'b0;
        mem_we          <= 1'b0;
        reg_file_write  <= 1'b0;
        alu_op          <= 2'b0;
        select_mux_1    <= 2'b0;
        select_mux_2    <= 2'b0;
        select_mux_3    <= 2'b0;
        select_mux_4    <= 2'b0;
    end

    always @(posedge clk or posedge reset ) begin
        if  ( reset ) begin
            currentState <= IDLE;
        end else begin
            currentState <= nextState;

        end
    end

    always @ * begin
        case (currentState) 
            IDLE:       nextState <= IF;
            IF:         nextState <= ID;
            ID:         nextState <= EX;
            EX:         nextState <= MEM;
            MEM:        nextState <= WB;
            WB:         nextState <= IF;
            DONE:       nextState <= DONE;
            default:    nextState <= IDLE;
        endcase
    end

    always @ * begin
        case (currentState)
            IDLE: begin             // IDLE state: does nothing
                pc_reset <= 1'b1;
            end
            IF: begin               // Instruction Fetch: disables reset and resets all the outputs
                        pc_load         <= 1'b0;
                        pc_reset        <= 1'b0;
                        mem_re          <= 1'b0;
                        mem_we          <= 1'b0;
                        reg_file_write  <= 1'b0;
                        alu_op          <= 2'b0;
                        select_mux_1    <= 2'b0;
                        select_mux_2    <= 2'b0;
                        select_mux_3    <= 2'b0;
                        select_mux_4    <= 2'b0;
            end
            ID: begin               // Instruction Decode: views the instruction
                
            end
            EX: begin               // Exectue: change some MUX's selects and branch cases
                case (opcode)
                    7'b0110011: begin   // R-type
                        select_mux_1    <= 2'b0;    // ALU recieves RS2
                        select_mux_2    <= 2'b1;    // Din recieves ALU output
                        alu_op          <= 2'b10;   // R-type
                        select_mux_3    <= 2'b0;
                        select_mux_4    <= 2'b0;
                    end    
                    7'b0000011: begin   // I-type
                        select_mux_1    <= 2'b1;    // ALU recieves Immediate
                        select_mux_2    <= 2'b0;    // Din recieves MEM output
                        alu_op          <= 2'b01;   // I-type
                        select_mux_3    <= 2'b0;
                        select_mux_4    <= 2'b0;
                    end    
                    7'b0100011: begin   // S-type
                        select_mux_1    <= 2'b1;    // ALU recieves Immediate
                        select_mux_2    <= 2'b0;    // Din neutral
                        alu_op          <= 2'b00;   // S-type
                        select_mux_3    <= 2'b0;
                        select_mux_4    <= 2'b01;
                    end    
                    7'b1100011: begin   // SB-type
                        select_mux_1    <= 2'b0;    // ALU recieves Immediate
                        select_mux_2    <= 2'b0;    // Din neutral
                        alu_op          <= 2'b00;   // S-type
                        case (branch) 
                            1'b1: select_mux_3    <= 2'b01;
                            1'b0: select_mux_3    <= 2'b00;
                        endcase
                        select_mux_4    <= 2'b00;  
                    end   
                endcase
            end
            MEM: begin              // Memory: writes or reads memory
                case (opcode)
                    7'b0110011: begin   // R-type
                        mem_we          <= 1'b0;    // Only changes in MEM
                        mem_re          <= 1'b0;    // Only changes in MEM
                    end    
                    7'b0000011: begin   // I-type
                        mem_we          <= 1'b0;    // Only changes in MEM
                        mem_re          <= 1'b1;    // Only changes in MEM
                    end    
                    7'b0100011: begin   // S-type
                        mem_we          <= 1'b1;    // Only changes in MEM
                        mem_re          <= 1'b0;    // Only changes in MEM
                    end    
                    7'b1100011: begin   // SB-type
                        mem_we          <= 1'b0;    // Only changes in MEM
                        mem_re          <= 1'b0;    // Only changes in MEM
                    end   
                endcase
            end
            WB: begin               // Write Back: writes the registers in use
                pc_load         <= 1'b1;    
                case (opcode)
                    7'b0110011: begin   // R-type
                        reg_file_write  <= 1'b1;    // Only changes in WB stage
                    end    
                    7'b0000011: begin   // I-type
                        reg_file_write  <= 1'b1;    // Only changes in WB stage
                    end    
                    7'b0100011: begin   // S-type
                        reg_file_write  <= 1'b0;    // Only changes in WB stage
                    end    
                    7'b1100011: begin   // SB-type
                        reg_file_write  <= 1'b0;    // Only changes in WB stage
                    end   
                endcase
            end
            default: begin          // DONE: resets all the outputs
                        pc_load         <= 1'b0;
                        pc_reset        <= 1'b0;
                        mem_re          <= 1'b0;
                        mem_we          <= 1'b0;
                        reg_file_write  <= 1'b0;
                        alu_op          <= 2'b0;
                        select_mux_1    <= 2'b0;
                        select_mux_2    <= 2'b0;
                        select_mux_3    <= 2'b0;
                        select_mux_4    <= 2'b0;
            end
        endcase
    end
    

endmodule