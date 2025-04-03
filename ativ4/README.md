# Activity 4 - Implementation of a Multi-Cycle RISC-V with Pipelining and Hazard Detection  

## Project  
For this activity, we decided to develop a 32-bit RISC-V processor to create a pipelined version of the processor. Due to the potential complexity of a full RISC-V implementation, only a specific and limited set of instructions will be implemented to optimize development time.  
A [Canva](https://www.canva.com/design/DAGWMdZUrac/1541PILC9_Dn8_2RG12VUg/edit?utm_content=DAGWMdZUrac&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) project was also created to visualize the processor's abstraction.  

The following instructions will be implemented:  
- [X] High-level diagram  
- **Logic and Arithmetic (R-type):**  
  - [X] add  
  - [X] sub  
  - [X] or  
  - [X] and  
- **Branch (SB-type):**  
  - [X] beq  
- **Store (S-type):**  
  - [X] sw  
- **Load (I-type):**  
  - [X] lw  

## Step-by-Step  

First, to carry out the project, a multi-cycle RISC-V implementation must be created. As a reference, we used the 64-bit RISC-V project developed in [SD2](https://github.com/henriquegreg/PCS3225---Sistemas-Digitais-II-2023-/).  

The following components will be implemented:  
- [X] **ALU:**  
  - [X] Data flow  
    - [X] Logic  
    - [X] Arithmetic  
  - [X] Control unit  
- [X] **Main control unit**  
- [X] **Data memory**  
- [X] **Instruction memory**  
- [X] **Register file**  
- [X] **Instruction register**  
- [X] **Generic multiplexer (MUX)**  
- [X] **Immediate generator**  

## What Has Been Implemented (Still Subject to Testing and Improvements)  

- **Pipeline Intermediate Registers:**  
  - [X] ID/EX Register  
  - [X] EX/MEM Register  
  - [X] MEM/WB Register  

## What Still Needs to Be Done  

- [ ] **Hazards:**  
  - Implement hazard detection (data, control, and structural hazards).  
  - Implement forwarding (data forwarding) and stalling strategies to handle hazards.  
- [ ] **Datapath Integration:**  
  - Integrate the new pipeline registers into the datapath.  
  - Set up interconnections between stages.  
- [ ] **IF Stage (Instruction Fetch) Module:**  
  - Implement the instruction fetch stage, including PC manipulation and instruction memory access.  
- [ ] **ID Stage (Instruction Decode) Module:**  
  - Implement instruction decoding and register read control.  
- [ ] **EX Stage (Execute) Module:**  
  - Implement ALU execution, address calculation for load/store instructions, and branch control.  
- [ ] **MEM Stage (Memory) Module:**  
  - Implement memory operations (load/store).  
  - Control access to data memory.  
- [ ] **WB Stage (Writeback) Module:**  
  - Implement writing back to the register file after instruction execution.  

## Testbench  

To compile with Icarus Verilog, run the following commands:  
```bash
iverilog -c riscv_compile.txt
vvp a.out
gtkwave riscv_tb.vcd -a .\wave.gtkw
``
