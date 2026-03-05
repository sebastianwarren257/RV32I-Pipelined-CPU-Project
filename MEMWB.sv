module MEMWB(
    input Clk,
    input reset,
    input [31:0] readData4,
    output reg [31:0] readData5,
    input [31:0] pc4Plus4,
    output reg [31:0] pc5Plus4,
    input [31:0] ALUResult4,
    output reg [31:0] ALUResult5,
    input [1:0] MemToReg4,
    output reg [1:0] MemToReg5,
    input RegWrite4,
    output reg RegWrite5,
    input [4:0] rWR4,
    output reg [4:0] rWR5,
    input [31:0] pc4,
    output reg [31:0] pc5
);
    always_ff @(posedge Clk) begin
            if(reset) begin
                ALUResult5 <= 32'b0;
                readData5 <= 32'b0;
                RegWrite5 <= 1'b0;
                MemToReg5 <= 2'b00;
                rWR5 <= 5'b0;
                pc5Plus4 <= 32'b0;
                pc5<=32'b0;
            end
            else begin
                ALUResult5 <= ALUResult4;
                readData5 <= readData4;
                RegWrite5 <= RegWrite4;
                MemToReg5 <= MemToReg4;
                rWR5 <= rWR4;
                pc5Plus4 <= pc4Plus4;
                pc5<=pc4;
            end
        end
endmodule