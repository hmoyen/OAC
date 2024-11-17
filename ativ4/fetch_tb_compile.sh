iverilog fetch_tb.v stages/IF/instruction_fetch.v stages/IF/pc.v  register/if_id_register.v  mux/mux_2.v memory/memory_inst.v

vvp a.out

gtkwave fetch_tb.vcd