`include "defines.sv"
module ImmGen(
    input wire[31:0] ins,
    input wire[2:0] sel,
    output reg[31:0] imm32
);
    always @(*) begin
        case (sel)
            `I_type: begin  //check special cases SLLI SRLI SRAI
                imm32 = {{(32-12){ins[31]}},ins[31:20]};
            end
            `S_type: begin
                imm32 = {{(32-12){ins[31]}},ins[31:25],ins[11:7]};
            end
            `B_type: begin
                imm32 = {{(32-13){ins[31]}},ins[31],ins[7],ins[30:25],ins[11:8],1'b0};
            end
            `U_type: begin
                imm32 = {ins[31:12],12'b0};
            end
            `J_type: begin
                imm32 = {{(32-11){ins[31]}},ins[31],ins[19:12],ins[20],ins[30:21],1'b0};
            end
            default: begin
                imm32 = 32'b0;
            end
        endcase
        //$display("imm32 = %h from instruction %h", imm32, ins);
    end
    

endmodule