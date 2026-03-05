`include "defines.sv"
module ALUControl(
    input wire [2:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] ALUCtrl
);
    always @(*) begin 
        case (ALUOp)
            3'b000: ALUCtrl = `ADD;//loads/stores
            3'b001: begin
                case (funct3) //Branch
                    3'h0: ALUCtrl = `SUB;
                    3'h1: ALUCtrl = `SUB;
                    3'h4: ALUCtrl = `SLT;
                    3'h5: ALUCtrl = `SLT;
                    3'h6: ALUCtrl = `SLTU;
                    3'h7: ALUCtrl = `SLTU;
                    default: ALUCtrl = `SUB;
                endcase
            end
            3'b010: begin
                case (funct3) //for R type
                    3'h0: ALUCtrl = (funct7==7'h0) ? `ADD:`SUB;
                    3'h1: ALUCtrl = `SLL;
                    3'h2: ALUCtrl = `SLT;
                    3'h3: ALUCtrl = `SLTU;
                    3'h4: ALUCtrl = `XOR;
                    3'h5: ALUCtrl = (funct7==7'h0) ? `SRL:`SRA;
                    3'h6: ALUCtrl = `OR;
                    3'h7: ALUCtrl = `AND; 
                    default: ALUCtrl = `ADD;
                endcase
            end
            3'b011: begin
                case (funct3) //for I type
                    3'h0: ALUCtrl = `ADD;
                    3'h1: ALUCtrl = `SLL;
                    3'h2: ALUCtrl = `SLT;
                    3'h3: ALUCtrl = `SLTU;
                    3'h4: ALUCtrl = `XOR;
                    3'h5: ALUCtrl = (funct7[5]==1'b0) ? `SRL:`SRA;
                    3'h6: ALUCtrl = `OR;
                    3'h7: ALUCtrl = `AND;
                    default: ALUCtrl = `ADD;
                endcase
            end
            3'b100: ALUCtrl = `PASS_B;
        endcase
    end
endmodule