# Atividade 4 - Implementação de RISC-V multiciclo com pipelining e detecção de hazards

## Projeto
Para essa atividade, decidiu-se criar um RISC-V 32 bit para atender à atividade de criar uma versão em pipeline do processador. Devido à possível complexidade que uma implementação de RISC-V pode haver, serão implementadas apenas um conjunto específico e fechado de instruções, para otimizar o tempo do trabalho.  
O projeto no [Canva](https://www.canva.com/design/DAGWMdZUrac/1541PILC9_Dn8_2RG12VUg/edit?utm_content=DAGWMdZUrac&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) da abstração do processador também foi criado.  
Serão implementadas as seguintes instruções:
- [X] Diagrama Alto-nível
- Lógica e Aritmética (R):
  - [X] add
  - [X] sub
  - [X] or
  - [X] and
- Branch (SB):
  - [X] beq
- Store (S):
  - [X] sw
- Load (I):
  - [X] lw
 
## Passo a passo

Primeiramente, para a realização do projeto, precisa-se criar uma implementação do RISC-V com multiciclo. Para isso, buscou-se como referência o projeto de RISC-V 64 bit criado em [SD2](https://github.com/henriquegreg/PCS3225---Sistemas-Digitais-II-2023-/). 

Serão implementadas então:
  - [X] ALU:
    - [X] Fluxo de dados
      - [X] Lógica
      - [X] Aritimética
    - [X] Unidade de controle
  - [X] Unidade de controle principal
  - [X] Memória de dados
  - [X] Memória de instruções
  - [X] Banco de registradores
  - [X] Registrador de instruções
  - [X] Mux genérico
  - [X] Gerador de imediato

## O que já foi implementado (ainda sujeito a testes e melhorias)

- **Registros intermediários da pipeline**:
  - [X] ID/EX Register
  - [X] EX/MEM Register
  - [X] MEM/WB Register

## O que ainda precisa ser feito

- [ ] **Hazards**:
  - Implementação de detecção de hazards (data, control, e structural hazards).
  - Estratégias de forward (data forwarding) e stalling (atraso) para lidar com os hazards.
- [ ] **Integração no datapath**:
  - Integração dos novos registros intermediários no caminho de dados.
  - Configuração das interconexões entre os estágios.
- [ ] **Módulo do estágio IF (Instruction Fetch)**:
  - Implementação do estágio de busca de instruções, incluindo a manipulação do PC e a leitura da memória de instruções.
- [ ] **Módulo do estágio ID (Instruction Decode)**:
  - Decodificação das instruções e controle de leitura dos registradores.
- [ ] **Módulo do estágio EX (Execute)**:
  - Implementação da execução da ALU, cálculo do endereço para as instruções de load/store, e controle de branch.
- [ ] **Módulo do estágio MEM (Memory)**:
  - Implementação de operações de memória (load/store).
  - Controle de acesso à memória de dados.
- [ ] **Módulo do estágio WB (Writeback)**:
  - Implementação de escrita no banco de registradores após a execução de instruções.
 
## Testbench
  
Para compilar, com o Ícarus Verilog, digitar:
```bash
iverilog -c riscv_compile.txt
vvp a.out
gtkwave riscv_tb.vcd -a .\wave.gtkw
