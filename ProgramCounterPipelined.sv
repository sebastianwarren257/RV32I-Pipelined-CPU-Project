`define j_ins    3'b000
`define jal_ins
`define jalr_ins
`define b_ins
module PipelinedCounter(
    input wire [31:0] inPC,
    input wire [31:0] redirect_target,
    output reg [31:0] outPC,
    input wire redirect_valid,
    input wire stall
);
    /*always @(*)begin
        $display("Branch = %h, BranchTaken = %h, outpc = %h,imm32 = %h",Branch,BranchTaken,outPC,imm32);
    end*/
    always_comb begin 
        if(redirect_valid) begin
            outPC = redirect_target;
        end
        else if(stall) begin
            outPC = inPC;
        end
        else begin
            outPC = inPC + 32'h4;
        end
    end 
        
endmodule