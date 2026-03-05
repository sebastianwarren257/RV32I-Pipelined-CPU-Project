`include "defines.sv"

module ALU(
    input wire[31:0] A,
    input wire[31:0] B,
    input wire[3:0] ALUCtrl,
    output reg[31:0] ALUResult,
    output wire zero
);
    
    always @(*) begin
        case (ALUCtrl)
            `ADD: begin
                ALUResult = A+B;
            end
            `SUB: begin
                ALUResult = A-B;
            end
            `AND: begin
                ALUResult = A&B;
            end
            `OR: begin
                ALUResult = A|B;
            end
            `SLT: begin
                ALUResult = ($signed(A)<$signed(B)) ? 32'b1:32'b0;
            end
            `SLL: begin
                ALUResult = A<<B[4:0];
            end
            `SRL: begin
                ALUResult = A>>B[4:0];
            end
            `SRA: begin
                ALUResult = A>>>B[4:0];
            end
            `SLTU: begin
                ALUResult = (A<B) ? 32'b1:32'b0;
            end
            `XOR: begin
                ALUResult = A^B;
            end
            `PASS_B: begin
                ALUResult = B;
            end
            default: begin
                ALUResult = 32'b0;
            end
        endcase         
    end
    assign zero = (ALUResult == 32'b0);//assigns zero if Result is 0
endmodule
