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

    // === Clock generation: toggles every 5 ns ===
    always begin
        #5 Clk = ~Clk;
    end

    
    // === Dump waveforms ===
    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, PipelinedProc_tb);
    end

    always @(posedge Clk) begin
    if (!reset) begin
        if (
            CPU.DataMemory.memory[0] == 8'h01 &&
            CPU.DataMemory.memory[1] == 8'h00 &&
            CPU.DataMemory.memory[2] == 8'h00 &&
            CPU.DataMemory.memory[3] == 8'h00
        ) begin
            $display("PASS (smoke test)");
            $finish;
        end
        end
    end
    always @(posedge Clk) begin
  if (!reset) begin
    if (CPU.MEM_MemWrite) begin
      $display("STORE: addr=%h funct3=%b data=%h",
        CPU.MEM_ALUResult, CPU.MEM_funct3, CPU.forwarded_store_data
      );
    end
  end
end
    // === Test procedure ===
    initial begin
        $display("\n=== Starting Pipelined CPU Test ===\n");

        // Initial setup
        Clk     = 0;
        reset   = 1;
        startPC = 0;

        // Hold reset for a couple cycles (pipelines like this)
        #20 reset = 0;

        // Run long enough to fill + drain pipeline
        repeat (20) begin
            @(posedge Clk);
            $display("WB MemToRegOut = %h", MemToRegOut);
        end

        $display("\n=== Finished Pipelined CPU Simulation ===\n");
        $finish;
    end

endmodule
