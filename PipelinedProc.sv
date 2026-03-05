module PipelinedProc(
    input reset,
    input [31:0] startPC,
    input Clk,
    output logic [31:0] MemToRegOut
);

    


    //hazard control signals
    reg IFID_flush,IDEX_flush;
    reg stall;
    reg [31:0] forwardedA, forwardedB, forwarded_store_data; // wire these values in

    //stage 1 connections (Instruction Fetch)
    reg [31:0] IF_currentPC;
    wire[31:0] IF_instruction;
    wire[31:0] IF_currentPCPlus4;
    wire[31:0] nextPC;
    wire[4:0] IF_rs2;
    wire[4:0] IF_rs1;

    //stage 2 connections (Instruction decode and register read)
    //parts of instruction
    reg[31:0] ID_instruction;
    wire[6:0] ID_funct7;
    reg[4:0] ID_rs2;
    reg[4:0] ID_rs1;
    wire[4:0] ID_rD;
    wire[2:0] ID_funct3;
    wire[6:0] opcode;
    //regfile connections
    wire[31:0] ID_rA,ID_rB;
    //immediategenerator
    wire[31:0] ID_imm32;
    //control signals
    wire [1:0]ID_MemToReg;
    wire ID_RegWrite,ID_Memread,ID_MemWrite,ID_ALUsrc,ID_Branch,ID_Jalr,ID_Jump;
    wire [2:0] ID_ALUOp;
    wire[2:0] sel;
    //pc
    reg [31:0] ID_currentPC;
    reg[31:0] ID_currentPCPlus4;

    //stage 3 (Execute)
    //pipelined stuff
    reg[4:0] EX_rD;
    reg [31:0] EX_currentPC;
    reg[31:0] EX_currentPCPlus4;
    reg [1:0] EX_MemToReg;
    reg EX_RegWrite,EX_Memread,EX_MemWrite,EX_ALUsrc,EX_Branch,EX_Jalr,EX_Jump;
    //Alu connections
    wire[31:0] EX_ALUResult;
    wire zero;
    wire[3:0] ALUCtrl;
    //ALU inputs
    reg[31:0] EX_rA,EX_rB;
    reg[4:0] EX_rs2;
    reg[4:0] EX_rs1;
    //ALU Control
    wire [2:0] EX_ALUOp;
    wire[6:0] EX_funct7;
    wire[2:0] EX_funct3;
    //imm
    reg[31:0] EX_imm32;
    //pc logic
    logic redirect_valid;
    logic[31:0] redirect_target;
    reg branchTaken;
    

    //Stage 4 (MemAccess)
    reg[31:0] MEM_ALUResult;
    wire[2:0] MEM_funct3;
    reg [1:0] MEM_MemToReg;
    reg MEM_Memread,MEM_MemWrite,MEM_RegWrite;
    wire[31:0] MEM_rB;
    wire[31:0] MEM_memOut;
    reg [31:0] MEM_currentPC;
    reg[31:0] MEM_currentPCPlus4;
    reg[4:0] MEM_rD;
    reg[4:0] MEM_rs2;
    reg[4:0] MEM_rs1;
    
    //Stage 5 (Write Back)
    reg[31:0] WB_memOut;
    reg[31:0] WB_ALUResult;
    reg[4:0] WB_rD;
    reg [1:0] WB_MemToReg;
    reg WB_RegWrite;
    reg[31:0] WB_currentPCPlus4;
    reg[31:0] WB_currentPC;
    

    //Stage 1 Logic
    always_ff @(posedge Clk) begin
        if(reset) 
            IF_currentPC <=  startPC;
        else 
            IF_currentPC <=  nextPC;
    end
    assign IF_currentPCPlus4 = IF_currentPC + 32'h4;
    PipelinedCounter PCLogic(
        .inPC(IF_currentPC),
        .redirect_target(redirect_target),
        .outPC(nextPC),
        .redirect_valid(redirect_valid),
        .stall(stall)
    );
    imem InstructionMemory(
        .PC(IF_currentPC),
        .instruction(IF_instruction)
    );
    assign IF_rs2 = IF_instruction[24:20]; //need values for load-use hazard detection
    assign IF_rs1 = IF_instruction[19:15];
    //IFID pipeline wiring
    IFID pipeline1(
        .Clk(Clk),
        .reset(reset),
        .IFID_flush(IFID_flush),
        .instruction1(IF_instruction),
        .pc1(IF_currentPC),
        .pc1Plus4(IF_currentPCPlus4),
        .instruction2(ID_instruction),
        .pc2(ID_currentPC),
        .pc2Plus4(ID_currentPCPlus4),
        .stall(stall),
        .rs1_in(IF_rs1),
        .rs1_out(ID_rs1),
        .rs2_in(IF_rs2),
        .rs2_out(ID_rs2)
    );

    //Stage 2 Logic
    assign ID_funct7 = ID_instruction[31:25];
    assign ID_funct3 = ID_instruction[14:12];
    assign ID_rD = ID_instruction[11:7];
    assign opcode = ID_instruction[6:0];
    ControlUnit control(
        .RegWrite(ID_RegWrite),
        .Memread(ID_Memread),
        .Memwrite(ID_MemWrite),
        .MemToReg(ID_MemToReg),
        .ALUOp(ID_ALUOp),
        .ALUsrc(ID_ALUsrc),
        .Branch(ID_Branch),
        .Jalr(ID_Jalr),
        .Jump(ID_Jump),
        .sel(sel),
        .opcode(opcode)
    );
    ImmGen ImmediateGenerator(
        .ins(ID_instruction),
        .sel(sel),
        .imm32(ID_imm32)
    );
    RegisterFile RegFile(
        .rA(ID_rA),
        .rB(ID_rB),
        .rD(MemToRegOut),
        .rAi(ID_rs1),
        .rBi(ID_rs2),
        .rDi(WB_rD),
        .WriE(WB_RegWrite),
        .Clk(Clk)
    );
    HazardDetection Hazard(
        .redirect_valid(redirect_valid),
        .IFID_flush(IFID_flush),
        .IDEX_flush(IDEX_flush),
        .stall(stall),
        .IDEX_rs1(EX_rs1),
        .IDEX_rs2(EX_rs2),
        .EXMEM_rs2(MEM_rs2),
        .IFID_rs1(ID_rs1),
        .IFID_rs2(ID_rs2),
        .MEM_rs1(MEM_rs1),
        .EXMEM_rD(MEM_rD),
        .MEMWB_rD(WB_rD),
        .IDEX_rD(EX_rD),
        .EXMEM_RegWrite(MEM_RegWrite),
        .MEMWB_RegWrite(WB_RegWrite),
        .MEM_MemWrite(MEM_MemWrite),
        .IDEX_MemRead(EX_Memread),
        .forwardedA(forwardedA),
        .forwardedB(forwardedB),
        .forwarded_store_data(forwarded_store_data),
        .EXMEM_ALUResult(MEM_ALUResult),
        .EXMEM_rB(MEM_rB),
        .MemToRegOut(MemToRegOut),
        .EX_rA(EX_rA),
        .EX_rB(EX_rB),
        .MEM_rB(MEM_rB)
    );
    //IDEX pipeline
    IDEX pipeline2(
        .Clk(Clk),
        .reset(reset),
        .IDEX_flush(IDEX_flush),
        .pc2Plus4(ID_currentPCPlus4),
        .pc3Plus4(EX_currentPCPlus4),
        .pc2(ID_currentPC),
        .pc3(EX_currentPC),
        .rA2(ID_rA),
        .rB2(ID_rB),
        .rA3(EX_rA),
        .rB3(EX_rB),
        .RegWrite_in(ID_RegWrite),
        .RegWrite_out(EX_RegWrite),
        .Memread_in(ID_Memread),
        .Memread_out(EX_Memread),
        .Memwrite_in(ID_MemWrite),
        .Memwrite_out(EX_MemWrite),
        .MemToReg_in(ID_MemToReg),
        .MemToReg_out(EX_MemToReg),
        .ALUsrc2(ID_ALUsrc),
        .ALUsrc3(EX_ALUsrc),
        .Branch2(ID_Branch),
        .Branch3(EX_Branch),
        .Jalr2(ID_Jalr),
        .Jalr3(EX_Jalr),
        .Jump2(ID_Jump),
        .Jump3(EX_Jump),
        .ALUOp2(ID_ALUOp),
        .ALUOp3(EX_ALUOp),
        .imm32_2(ID_imm32),
        .imm32_3(EX_imm32),
        .rWR_in(ID_rD),
        .rWR_out(EX_rD),
        .funct7_2(ID_funct7),
        .funct7_3(EX_funct7),
        .funct3_2(ID_funct3),
        .funct3_3(EX_funct3),
        .rs1_in(ID_rs1),
        .rs1_out(EX_rs1),
        .rs2_in(ID_rs2),
        .rs2_out(EX_rs2),
        .stall(stall)
    );

    //stage 3 logic
    ALUControl ALUC(
        .ALUOp(EX_ALUOp),
        .funct3(EX_funct3),
        .funct7(EX_funct7),
        .ALUCtrl(ALUCtrl)
    );
    ALU alu(
        .A(forwardedA),
        .B(EX_ALUsrc ? EX_imm32 : forwardedB),
        .ALUCtrl(ALUCtrl),
        .ALUResult(EX_ALUResult),
        .zero(zero)
    );
    //redirect logic
    always @(*) begin
        case (EX_funct3)
            3'h0: branchTaken = (EX_Branch && zero);
            3'h1: branchTaken = (EX_Branch && !zero);
            3'h4: branchTaken = (EX_Branch &&  EX_ALUResult[0]);
            3'h5: branchTaken = (EX_Branch && !EX_ALUResult[0]);
            3'h6: branchTaken = (EX_Branch &&  EX_ALUResult[0]);
            3'h7: branchTaken = (EX_Branch && !EX_ALUResult[0]);
            default: branchTaken = 1'b0;
        endcase
    end
    always_comb begin 
        if(EX_Jalr) begin
            redirect_target = (EX_rA + EX_imm32) & ~32'd1;
            redirect_valid = 1;
        end
        else if(EX_Jump) begin
            redirect_target = EX_currentPC + EX_imm32;
            redirect_valid = 1;
        end
        else if(EX_Branch&&branchTaken) begin
            redirect_target = EX_currentPC + EX_imm32;
            redirect_valid = 1;
        end
        else begin
            redirect_valid = 0;
        end
    end

    //EXMEM pipeline 
    EXMEM pipeline3(
        .Clk(Clk),
        .reset(reset),
        .ALUResult3(EX_ALUResult),
        .ALUResult4(MEM_ALUResult),
        .nextPC_in(EX_currentPC),
        .nextPC_out(MEM_currentPC),
        .pc3Plus4(EX_currentPCPlus4),
        .pc4Plus4(MEM_currentPCPlus4),
        .funct3_3(EX_funct3),
        .funct3_4(MEM_funct3),
        .rB3(forwardedB),
        .rB4(MEM_rB),
        .RegWrite_in(EX_RegWrite),
        .RegWrite_out(MEM_RegWrite),
        .Memread3(EX_Memread),
        .Memread4(MEM_Memread),
        .Memwrite3(EX_MemWrite),
        .Memwrite4(MEM_MemWrite),
        .MemToReg_in(EX_MemToReg),
        .MemToReg_out(MEM_MemToReg),
        .rWR_in(EX_rD),
        .rWR_out(MEM_rD),
        .rs1_in(EX_rs1),
        .rs2_in(EX_rs2),
        .rs1_out(MEM_rs1),
        .rs2_out(MEM_rs2)
    );

    //stage 4 logic
    dmem DataMemory(
        .Clk(Clk),
        .funct3(MEM_funct3),
        .addr(MEM_ALUResult),
        .wri_data(forwarded_store_data),
        .read_data(MEM_memOut),//memout filling with XXX 
        .Memread(MEM_Memread),
        .Memwrite(MEM_MemWrite)
    );

    //MEMWB pipeline
    MEMWB pipeline4(
        .Clk(Clk),
        .reset(reset),
        .readData4(MEM_memOut),
        .readData5(WB_memOut),
        .ALUResult4(MEM_ALUResult),
        .ALUResult5(WB_ALUResult),
        .RegWrite4(MEM_RegWrite),
        .RegWrite5(WB_RegWrite),
        .MemToReg4(MEM_MemToReg),
        .MemToReg5(WB_MemToReg),
        .rWR4(MEM_rD),
        .rWR5(WB_rD),
        .pc4Plus4(MEM_currentPCPlus4),
        .pc5Plus4(WB_currentPCPlus4),
        .pc4(MEM_currentPC),
        .pc5(WB_currentPC)
    );

    //stage 5 logic
    always_comb begin
        case(WB_MemToReg)
            2'b00:  MemToRegOut = WB_ALUResult;
            2'b01:  MemToRegOut = WB_memOut;
            2'b10:  MemToRegOut = WB_currentPCPlus4;
            default: MemToRegOut = 32'b0;
        endcase
    end
    
endmodule