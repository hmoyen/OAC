module hazard(
    input clock,
    input reset,
    input select_mux_3,
    input select_mux_3_wb,
    input [6:0] opcode,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_ex_mem,
    input [4:0] rd_mem_wb,
    input branch_instruction_controller,
    input branch_instruction_id_ex,
    output pc_load,
    output if_id_load,
    output mux5_selector
);

parameter [6:0] RTYPE = 7'b0110011,
                STYPE = 7'b0100011,
                SBTYPE = 7'b1100011,
                ITYPE =  7'b0000011;


wire data_hazard;
assign data_hazard = (((opcode == RTYPE) || (opcode == STYPE) || (opcode == SBTYPE) || (opcode == ITYPE)) && 
                     (((rs1 != 0) && ((rs1 == rd_ex_mem) || (rs1 == rd_mem_wb))))) ||
                     (((opcode == RTYPE) || (opcode == STYPE) || (opcode == SBTYPE)) && 
                     ((rs2 != 0) && ((rs2 == rd_ex_mem) || (rs2 == rd_mem_wb))));

assign pc_load = ~(branch_instruction_controller || branch_instruction_id_ex || data_hazard);
assign if_id_load = ~(data_hazard || branch_instruction_id_ex);
assign mux5_selector = data_hazard || branch_instruction_id_ex || select_mux_3 || select_mux_3_wb;

endmodule
