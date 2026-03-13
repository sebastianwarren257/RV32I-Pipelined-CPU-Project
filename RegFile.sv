module RegisterFile(
    output wire [31:0] rA,
    output wire [31:0] rB,
    input wire [31:0] rD,
    input wire [4:0] rAi,
    input wire [4:0] rBi,
    input wire [4:0] rDi,
    input wire WriE,
    input wire Clk
);

    reg [31:0] regs [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'h0;
    end

    wire sameA = WriE && (rDi != 5'd0) && (rDi == rAi); //bypass logic for write-first only when write-first needs to occur
    wire sameB = WriE && (rDi != 5'd0) && (rDi == rBi);
    assign rA = (rAi==5'd0) ? 32'b0 : sameA ? rD : regs[rAi];
    assign rB = (rBi==5'd0) ? 32'b0 : sameB ? rD : regs[rBi];

    always_ff @(posedge Clk) begin //write function
        if(WriE&&(rDi!=5'd0))begin //don't allow write to x0
            regs[rDi] <= rD;
        end 
        
    end

endmodule
