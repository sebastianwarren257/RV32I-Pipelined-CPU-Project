`timescale 1ns/1ps
module PipelinedProc_tb;

    // === Testbench signals ===
    reg         Clk;
    reg         reset;
    reg [31:0]  startPC;

    // === Outputs from CPU ===
    wire [31:0] MemToRegOut;

    // === Instantiate DUT (Device Under Test) ===
    PipelinedProc CPU(
        .reset(reset),
        .startPC(startPC),
        .Clk(Clk),
        .MemToRegOut(MemToRegOut)
    );

    // === Test name  ===
    parameter TEST_NAME = "rv32ui-p-and";
     
    // === tohost address ===
    parameter TOHOST_ADDR = 32'h80001000;

    // === Clock generation: toggles every 5 ns ===
    always begin
        #5 Clk = ~Clk;
    end

    
    // === Dump waveforms ===
    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, PipelinedProc_tb);
    end

    // === Watch for tohost write (pass or fail) ===
    always @(posedge Clk) begin
    if (!reset && CPU.DataMemory.tohost != 0) begin
        if (CPU.DataMemory.tohost == 32'h1)
            $display("PASS: %s", TEST_NAME);
        else
            $display("FAIL: %s (test case %0d failed)",
                TEST_NAME, CPU.DataMemory.tohost >> 1);
        $finish;
    end
end

    // === Timeout Watching ===
    initial begin
        #500000;
        $display("TIMEOUT: %s never wrote to tohost", TEST_NAME);
        $finish;
    end

    // === Debug: first 10 cycles ===
integer cycle_count;
initial cycle_count = 0;

always @(posedge Clk) begin
    if (!reset) begin
        cycle_count <= cycle_count + 1;
        if (cycle_count < 200)
            $display("cycle=%0d PC=%h instr=%h", 
                cycle_count, CPU.IF_currentPC, CPU.IF_instruction);
    end
end
    // === Test procedure ===
    initial begin
        $display("\n=== Starting Pipelined CPU Test ===\n");

        // Initial setup
        Clk     = 0;
        reset   = 1;
        startPC = 32'h80000000;

        // Hold reset for a couple cycles (pipelines like this)
        #20 reset = 0;

        // Run long enough to fill + drain pipeline
    end

endmodule
