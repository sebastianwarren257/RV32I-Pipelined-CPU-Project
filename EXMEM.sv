module EXMEM(
    input Clk,
    input reset,
    input [31:0] ALUResult3,
    output reg [31:0] ALUResult4,
    input [31:0] pc3Plus4,
    output reg [31:0] pc4Plus4,
    input [31:0] nextPC_in,
    output reg [31:0] nextPC_out,
    input [2:0] funct3_3,
    output reg [2:0] funct3_4,
    input [31:0] rB3,
    output reg [31:0] rB4,
    input [1:0] MemToReg_in,
    output reg [1:0] MemToReg_out,
    input RegWrite_in,Memread3,Memwrite3, //in and outs not being used in this next stage but being pipelined past to the stage after
    output reg RegWrite_out,Memread4,Memwrite4,
    input [4:0] rWR_in,
    output reg [4:0] rWR_out,
    input [4:0] rs1_in, rs2_in,
    output reg [4:0] rs1_out, rs2_out
);
    always_ff @(posedge Clk) begin
            if(reset) begin
                ALUResult4 <= 32'b0;
                nextPC_out <= 32'b0;
                pc4Plus4 <= 32'b0;
                rB4 <= 32'b0;
                RegWrite_out <= 1'b0;
                Memread4 <= 1'b0;
                Memwrite4 <= 1'b0;
                MemToReg_out <= 2'b00;
                funct3_4 <= 3'b0;
                rWR_out <= 5'b0;
                rs1_out <= 5'b0;
                rs2_out <= 5'b0;
            end
            else begin
                ALUResult4 <= ALUResult3;
                nextPC_out <= nextPC_in;
                pc4Plus4 <= pc3Plus4;
                rB4 <= rB3;
                RegWrite_out <= RegWrite_in;
                Memread4 <= Memread3;
                Memwrite4 <= Memwrite3;
                MemToReg_out <= MemToReg_in;
                funct3_4 <= funct3_3;
                rWR_out <= rWR_in;
                rs1_out <= rs1_in;
                rs2_out <= rs2_in;
            end
        end
endmodule