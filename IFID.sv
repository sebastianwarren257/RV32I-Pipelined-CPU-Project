module IFID(
    input Clk,
    input reset,
    input IFID_flush,
    input [31:0] instruction1,
    input [31:0] pc1,
    input [31:0] pc1Plus4,
    output reg [31:0] instruction2,
    output reg [31:0] pc2,
    output reg [31:0] pc2Plus4,
    input stall,
    input [4:0] rs1_in, rs2_in,
    output reg [4:0] rs1_out, rs2_out
);
    always_ff @(posedge Clk) begin
        if(reset || IFID_flush) begin
            instruction2 <= 32'b0;
            pc2 <= 32'b0;
            pc2Plus4 <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
        end
        else if(stall)begin //holds values for stall
            instruction2<=instruction2;
            pc2<=pc2;
            pc2Plus4<=pc2Plus4;
            rs1_out <= rs1_out;
            rs2_out <= rs2_out;
        end
        else begin
            instruction2 <= instruction1;
            pc2 <= pc1;
            pc2Plus4 <= pc1Plus4;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
        end
    end
endmodule