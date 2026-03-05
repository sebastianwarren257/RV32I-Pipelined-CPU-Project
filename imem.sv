module imem(
    input wire [31:0] PC,
    output reg [31:0] instruction
);
    reg [31:0] imem [16383:0];
    
    initial begin
        $readmemh("imem.hex",imem); //load instructions into memory
    end

    assign instruction = imem[PC[31:2]];
endmodule