module imem(
    input wire [31:0] PC,
    output reg [31:0] instruction
);
    reg [31:0] imem [16383:0];
    
    initial begin
        $readmemh("tests/rv32ui-p-add.hex",imem, 0, 16383); //load instructions into memory
    end

    assign instruction = imem[(PC - 32'h80000000) >> 2];
endmodule