`timescale 1ns/1ps
module SingleCycleProc_tb;

    // === Testbench signals ===
    reg         Clk;
    reg         reset;
    reg [31:0]  startPC;

    // === Outputs from CPU ===
    wire [31:0] MemtoRegOut;
    wire [31:0] currentPC;

    // === Instantiate DUT (Device Under Test) ===
    SingleCycleProc CPU(
        .reset(reset),
        .startPC(startPC),
        .currentPC(currentPC),
        .Clk(Clk),
        .MemtoRegOut(MemtoRegOut)
    );

    // === Clock generation: toggles every 5 ns ===
    always begin
        #5 Clk = ~Clk;
    end
    initial begin
        $dumpfile("singlecycle.vcd");
        $dumpvars;
     end
    // === Test procedure ===
    initial begin
        // Initial setup
        $display("\n=== Starting Single Cycle CPU Test ===\n");
        Clk     = 0;
        reset   = 1;
        startPC = 0;

        // Hold reset for one cycle
        #10 reset = 0;

        // Run for some cycles
        repeat (20) begin
            @(posedge Clk);
            $display("PC = %h | MemToRegOut = %h", currentPC, MemtoRegOut);
        end

        $display("\n=== Finished CPU Simulation ===\n");
        $finish;
    end

endmodule
