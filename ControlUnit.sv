`include "defines.sv"
module ControlUnit(
    output reg RegWrite,
    output reg Memread,
    output reg Memwrite,
    output reg [1:0]MemToReg,
    output reg [2:0] ALUOp,
    output reg ALUsrcA,
    output reg  ALUsrcB,
    output reg Branch,
    output reg Jalr,
    output reg Jump,
    output reg [2:0] sel,
    input wire [6:0] opcode
);
    always_comb begin 
        case (opcode)
            `INST_OP_R: begin
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b010;
                ALUsrcB = 1'b0;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = 3'b111;
            end 
            `INST_OP_I: begin
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b011;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `I_type;
            end
            `INST_OP_LOAD: begin
                RegWrite = 1'b1;
                Memread = 1'b1;
                Memwrite = 1'b0;
                MemToReg = 2'b01;
                ALUOp = 3'b000;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `I_type;
            end 
            `INST_OP_STORE: begin
                RegWrite = 1'b0;
                Memread = 1'b0;
                Memwrite = 1'b1;
                MemToReg = 2'b00;
                ALUOp = 3'b000;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `S_type;
            end 
            `INST_OP_BRANCH: begin
                RegWrite = 1'b0;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b001;
                ALUsrcB = 1'b0;
                ALUsrcA = 1'b0;
                Branch = 1'b1;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `B_type;
            end  
            `INST_OP_JAL: begin
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b10;
                ALUOp = 3'b000;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b1;
                sel = `J_type;
            end 
            `INST_OP_JALR: begin
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b10;
                ALUOp = 3'b000;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b1;
                Jump = 1'b0;
                sel = `I_type;
            end
            `INST_OP_LUI: begin 
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b100;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `U_type;
            end
            `INST_OP_AUIPC: begin
                RegWrite = 1'b1;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b000;
                ALUsrcB = 1'b1;
                ALUsrcA = 1'b1;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `U_type;
            end
            `INST_OP_ECALL: begin //implemented as NOP
                RegWrite = 1'b0;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b000;
                ALUsrcB = 1'b0;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `I_type;
            end
            `INST_OP_FENCE: begin //implemented as NOP
                RegWrite = 1'b0;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b000;
                ALUsrcB = 1'b0;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = `I_type;
            end
            default: begin
                RegWrite = 1'b0;
                Memread = 1'b0;
                Memwrite = 1'b0;
                MemToReg = 2'b00;
                ALUOp = 3'b000;
                ALUsrcB = 1'b0;
                ALUsrcA = 1'b0;
                Branch = 1'b0;
                Jalr = 1'b0;
                Jump = 1'b0;
                sel = 3'b111;
            end
        endcase
        
    end
endmodule