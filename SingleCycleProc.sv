
module SingleCycleProc(
    input reset,
    input [31:0] startPC,
    output reg [31:0] currentPC,
    input Clk,
    output[31:0] MemtoRegOut
    
);
    //next pc connections
    wire[31:0] nextpc;

    //instruction memory
    wire[31:0] instruction;
    reg[31:0] inst_reg;

    //parts of instruction
    wire[6:0] funct7;
    wire[4:0] rs2;
    wire[4:0] rs1;
    wire[4:0] rd;
    wire[2:0] funct3;
    wire[6:0] opcode;

    //control signals
    wire RegWrite,Memread,Memwrite,MemToReg,ALUsrc,Branch,Jalr,Jump;
    wire [2:0] ALUOp;
    wire[2:0] sel;

    //regfile connections
    wire[31:0] rA,rB;

    //Alu connections
    wire[31:0] ALUResult;
    wire zero;
    wire[3:0] ALUCtrl;

    //immediategenerator
    wire[31:0] imm32;

    //output from Dmem
    wire[31:0] readData;

    //PC update logic
    always_ff @(posedge Clk) begin
        if(reset) 
            currentPC <=  startPC;
        else 
            currentPC <=  nextpc;
    end

    

    //branchTaken Logic
    reg branchTaken;
    always_comb begin
        case (funct3)
            3'h0: branchTaken = (Branch && zero);
            3'h1: branchTaken = (Branch && !zero);
            3'h4: branchTaken = (Branch && ALUResult);
            3'h5: branchTaken = (Branch && !ALUResult);
            3'h6: branchTaken = (Branch && ALUResult);
            3'h7: branchTaken = (Branch && !ALUResult);
            default: branchTaken = 1'b0;
        endcase
    end

    assign funct7 = instruction[31:25];
    assign rs2 = instruction[24:20];
    assign rs1 = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd = instruction[11:7];
    assign opcode = instruction[6:0];
    
    /*always @(posedge Clk) begin //debug for opcode and instruction
    $display("CTRL @ PC=%h | instr=%h | opcode=%b | funct3=%b | funct7=%b || RegWrite=%b MemRead=%b MemWrite=%b MemToReg=%b ALUsrc=%b Branch=%b Jalr=%b Jump=%b ALUOp=%b sel=%b",
         currentPC, instruction, opcode, funct3, funct7,
         RegWrite, Memread, Memwrite, MemToReg, ALUsrc, Branch, Jalr, Jump, ALUOp, sel);
end
    always @(posedge Clk)begin
        $display("zero = %h, aluout = %h,funct3=%h",zero,ALUResult,funct3);
    end*/

imem InstructionMemory(
    .PC(currentPC),
    .instruction(instruction)
);

ControlUnit control(
    .RegWrite(RegWrite),
    .Memread(Memread),
    .Memwrite(Memwrite),
    .MemToReg(MemToReg),
    .ALUOp(ALUOp),
    .ALUsrc(ALUsrc),
    .Branch(Branch),
    .Jalr(Jalr),
    .Jump(Jump),
    .opcode(opcode),
    .sel(sel)
);
dmem DataMemory(
    .Clk(Clk),
    .funct3(funct3),
    .addr(ALUResult),
    .wri_data(rB),
    .read_data(readData),
    .Memread(Memread),
    .Memwrite(Memwrite)
);
RegisterFile RegFile(
    .rA(rA),
    .rB(rB),
    .rD(MemtoRegOut),
    .rAi(rs1),
    .rBi(rs2),
    .rDi(rd),
    .WriE(RegWrite),
    .Clk(Clk)
);
ImmGen ImmediateGenerator(
    .ins(instruction),
    .sel(sel),
    .imm32(imm32)
);
ALUControl ALUC(
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .ALUCtrl(ALUCtrl)
);
ALU alu(
    .A(rA),
    .B(ALUsrc ? imm32:rB),
    .ALUCtrl(ALUCtrl),
    .ALUResult(ALUResult),
    .zero(zero)
);
ProgramCounter nextPC(
    .inPC(currentPC),
    .imm32(imm32),
    .rs1(rA),
    .outPC(nextpc),
    .Branch(Branch),
    .Jump(Jump),
    .Jalr(Jalr),
    .BranchTaken(branchTaken)
);

assign MemtoRegOut = MemToReg ? readData:ALUResult;
endmodule