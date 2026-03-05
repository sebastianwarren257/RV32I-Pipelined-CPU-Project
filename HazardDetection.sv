module HazardDetection(
    input redirect_valid,
    output reg IFID_flush, IDEX_flush,
    output reg stall,
    input [4:0] IDEX_rs1,IDEX_rs2,EXMEM_rs2,IFID_rs1,IFID_rs2, MEM_rs1, //values in decode to check if we need to forward // look into cases where rs2 not used or immediate
    input [4:0] EXMEM_rD,MEMWB_rD,IDEX_rD, //values to match to decode value
    input EXMEM_RegWrite,MEMWB_RegWrite, MEM_MemWrite, IDEX_MemRead,
    output reg [31:0] forwardedA,
    output reg [31:0] forwardedB,
    output reg [31:0] forwarded_store_data,
    input [31:0] EXMEM_ALUResult, EXMEM_rB, MemToRegOut, EX_rA, EX_rB, MEM_rB
);
    always_comb begin
        //control hazards (Jump/branch flush)
        if(redirect_valid) begin
            IFID_flush = 1'b1;
            IDEX_flush = 1'b1;
        end
        else begin
            IFID_flush = 1'b0;
            IDEX_flush = 1'b0;
        end
        if((IDEX_rs1==EXMEM_rD && EXMEM_RegWrite==1 && EXMEM_rD!=5'b0)) begin //MEM to EX forwarding
            forwardedA = EXMEM_ALUResult;
        end
        else if((IDEX_rs1==MEMWB_rD && MEMWB_RegWrite==1 && MEMWB_rD!=5'b0)) begin //WB to EX forwarding
            forwardedA = MemToRegOut;
        end
        else begin
            forwardedA = EX_rA;
        end
        if((IDEX_rs2==EXMEM_rD && EXMEM_RegWrite==1 && EXMEM_rD!=5'b0)) begin //MEM to EX forwarding
            forwardedB = EXMEM_ALUResult;
        end
        else if((IDEX_rs2==MEMWB_rD && MEMWB_RegWrite==1 && MEMWB_rD!=5'b0)) begin //WB to EX forwarding
            forwardedB = MemToRegOut;
        end
        else begin
            forwardedB = EX_rB;
        end
        if(MEM_MemWrite==1) begin // forwarding into mem unit from diff instruction
            if((MEMWB_RegWrite==1 && EXMEM_rs2==MEMWB_rD && MEMWB_rD!=5'b0)) begin
                forwarded_store_data = MemToRegOut;
            end
            else begin
                forwarded_store_data = MEM_rB;
            end
        end
        if(IDEX_MemRead==1 && IDEX_rD!=5'b0 && ((IDEX_rD == IFID_rs1) || (IDEX_rD == IFID_rs2))) begin //load-use stall detection
            stall = 1'b1;
        end
        else begin
            stall = 1'b0;
        end

    end
endmodule