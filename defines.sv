`define INST_OP_R      7'b0110011  //opcode table
`define INST_OP_I      7'b0010011
`define INST_OP_LOAD   7'b0000011
`define INST_OP_STORE  7'b0100011
`define INST_OP_BRANCH 7'b1100011
`define INST_OP_JAL    7'b1101111
`define INST_OP_JALR   7'b1100111
`define INST_OP_LUI    7'b0110111
`define INST_OP_AUIPC  7'b0010111
`define INST_OP_FENCE  7'b0001111
`define INST_OP_ECALL  7'b1110011

`define ADD   4'b0000  // ALU control table
`define SUB   4'b0001
`define AND   4'b0010
`define OR    4'b0011
`define SLT   4'b0100
`define SLL   4'b0101
`define SRL   4'b0110
`define SRA   4'b0111
`define SLTU  4'b1000
`define XOR   4'b1001
`define PASS_B 4'b1010

`define I_type 3'b000 //immediate generator types
`define S_type 3'b001
`define B_type 3'b010
`define U_type 3'b011
`define J_type 3'b100