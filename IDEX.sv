module IDEX(
    input Clk,
    input reset,
    input IDEX_flush,
    input [31:0] pc2Plus4,
    output reg [31:0] pc3Plus4,
    input [31:0] pc2,
    output reg [31:0] pc3,
    input [31:0] rA2,rB2,
    output reg [31:0] rA3,rB3,
    input [1:0] MemToReg_in,
    output reg [1:0] MemToReg_out,
    input RegWrite_in,Memread_in,Memwrite_in,ALUsrcB2,Branch2,Jalr2,Jump2,ALUsrcA2,
    output reg RegWrite_out,Memread_out,Memwrite_out,ALUsrcB3,Branch3,Jalr3,Jump3,ALUsrcA3,
    input [2:0] ALUOp2,
    output reg [2:0] ALUOp3,
    input [31:0] imm32_2,
    output reg [31:0] imm32_3,
    input [4:0] rWR_in,
    output reg [4:0] rWR_out,
    input [6:0] funct7_2,
    output reg [6:0] funct7_3,
    input [2:0] funct3_2,
    output reg[2:0] funct3_3,
    input [4:0] rs1_in,
    output reg [4:0] rs1_out,
    input [4:0] rs2_in,
    output reg [4:0] rs2_out,
    input stall
);
    always_ff @(posedge Clk) begin
            if(reset) begin
                pc3Plus4 <= 32'b0;
                pc3 <= 32'b0;
                rA3 <= 32'b0;
                rB3 <= 32'b0;
                RegWrite_out <= 1'b0;
                Memread_out <= 1'b0;
                Memwrite_out <= 1'b0;
                MemToReg_out <= 2'b00;
                ALUsrcB3 <= 1'b0;
                ALUsrcA3 <= 1'b0;
                Branch3 <= 1'b0;
                Jalr3 <= 1'b0;
                Jump3 <= 1'b0;
                ALUOp3 <= 3'b0;
                imm32_3 <= 32'b0;
                rWR_out <= 5'b0;
                funct7_3 <= 7'b0;
                funct3_3 <= 3'b0;
                rs1_out <=5'b0;
                rs2_out <=5'b0;
            end
            else if(IDEX_flush||stall) begin
                pc3Plus4 <= pc2Plus4;
                pc3 <= pc2;
                rA3 <= rA2;
                rB3 <= rB2;
                RegWrite_out <= 1'b0;
                Memread_out <= 1'b0;
                Memwrite_out <= 1'b0;
                MemToReg_out <= 2'b00;
                ALUsrcB3 <= 1'b0;
                ALUsrcA3 <= 1'b0;
                Branch3 <= 1'b0;
                Jalr3 <= 1'b0;
                Jump3 <= 1'b0;
                ALUOp3 <= 3'b0;
                imm32_3 <= 32'b0;      
                rWR_out <= 5'b0;       
                funct7_3 <= 7'b0;      
                funct3_3 <= 3'b0;      
                rs1_out <= 5'b0;       
                rs2_out <= 5'b0;       
            end

            else begin
                pc3Plus4 <= pc2Plus4;
                pc3 <= pc2;
                rA3 <= rA2;
                rB3 <= rB2;
                RegWrite_out <= RegWrite_in;
                Memread_out <= Memread_in;
                Memwrite_out <= Memwrite_in;
                MemToReg_out <= MemToReg_in;
                ALUsrcB3 <= ALUsrcB2;
                ALUsrcA3 <= ALUsrcA2;
                Branch3 <= Branch2;
                Jalr3 <= Jalr2;
                Jump3 <= Jump2;
                ALUOp3 <= ALUOp2;
                imm32_3 <= imm32_2;
                rWR_out <= rWR_in;
                funct7_3 <= funct7_2;
                funct3_3 <= funct3_2;
                rs1_out <=rs1_in;
                rs2_out <=rs2_in;
            end
        end
endmodule