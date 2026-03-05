`define j_ins    3'b000
`define jal_ins
`define jalr_ins
`define b_ins
module ProgramCounter(
    input wire [31:0] inPC,
    input wire [31:0] imm32,
    input wire [31:0] rs1,
    output reg [31:0] outPC,
    input wire Branch,
    input wire Jump,
    input wire Jalr,
    input wire BranchTaken
);
    /*always @(*)begin
        $display("Branch = %h, BranchTaken = %h, outpc = %h,imm32 = %h",Branch,BranchTaken,outPC,imm32);
    end*/
    always_comb begin 
        if(Jalr) begin
            outPC = rs1 + imm32 & ~1;
        end
        else if(Jump) begin
            outPC = inPC + imm32;
        end
        else if(Branch&&BranchTaken) begin
            outPC = inPC + imm32;
        end
        else begin
            outPC = inPC + 32'h4;
        end
    end 
        
endmodule