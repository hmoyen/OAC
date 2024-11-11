# Atividade 4 - Implementação de RISC-V multiciclo com pipelining e detecção de hazards

## Projeto
Para essa atividade, decidiu-se criar um RISC-V 32 bit para atender à ativade de criar uma versão em pipeline do processador. Devido à possível complexidade que uma implementação de RISC-V pode haver, serão implementadas apenas um conjunto específico e fechado de instruções, para otimizar o tempo do trabalho.
Serão implementadas as seguintes intruções:

- Lógica e Aritmética:
  - [ ] add
  - [ ] addi
  - [ ] sub
  - [ ] or
  - [ ] and
  - [ ] xor
- Branch:
  - [ ] beq
  - [ ] blt
  - [ ] bge
- Store:
  - [ ] sw
  - [ ] sb
- Load:
  - [ ] lw
  - [ ] sw
 
## Passo a passo

Primeiramente, para a realização do projeto, precisa-se criar uma implementação do RISC-V com multiciclo. Para isso, buscou-se como referência o projeto de RISC-V 64 bit criado em [SD2](https://github.com/henriquegreg/PCS3225---Sistemas-Digitais-II-2023-/). 

Serão implementadas então:
  - [X] ALU:
    - [X] Fluxo de dados
      - [X] Lógica
      - [X] Aritimética
    - [X] Unidade de controle
  - [ ] Unidade de controle principal
  - [-] Memória de dados
  - [-] Memória de instruções
  - [X] Banco de registradores
  - [X] Registrador de instruções
  - [X] Mux genérico
  - [X] Gerador de imediato
  
   