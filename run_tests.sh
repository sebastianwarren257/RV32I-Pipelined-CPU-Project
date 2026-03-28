#!/bin/bash

PASS=0
FAIL=0
ERRORS=()

CPU_FILES="PipelinedProc.sv HazardDetection.sv IFID.sv IDEX.sv EXMEM.sv MEMWB.sv ALU.sv ALUControl.sv ControlUnit.sv ImmGen.sv ProgramCounter.sv ProgramCounterPipelined.sv RegFile.sv defines.sv imem.sv dmem.sv"

echo "=== Running rv32ui Tests ==="
echo ""

for hex in /mnt/c/CPU_project/tests/rv32ui-p-*.hex; do
    # Skip dmem hex files
    [[ "$hex" == *.dmem.hex ]] && continue

    TEST=$(basename "$hex" .hex)

    # Swap imem hex
    sed -i "s|readmemh(\"tests/[^\"]*\.hex\"|readmemh(\"tests/${TEST}.hex\"|g" imem.sv

    # Swap dmem hex
    sed -i "s|readmemh(\"tests/[^\"]*\.dmem\.hex\"|readmemh(\"tests/${TEST}.dmem.hex\"|g" dmem.sv

    # Swap test name
    sed -i "s|parameter TEST_NAME = \"[^\"]*\"|parameter TEST_NAME = \"${TEST}\"|g" PipelinedProcTest.sv

    # Compile
    iverilog -g2012 -o pipeline_test PipelinedProcTest.sv $CPU_FILES 2>/dev/null

    # Run
    RESULT=$(vvp pipeline_test 2>/dev/null | grep -E "PASS|FAIL|TIMEOUT")

    if echo "$RESULT" | grep -q "PASS"; then
        echo "✅ PASS: $TEST"
        PASS=$((PASS + 1))
    else
        echo "❌ FAIL: $TEST — $RESULT"
        FAIL=$((FAIL + 1))
        ERRORS+=("$TEST")
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS / $((PASS + FAIL))"
echo "FAILED: $FAIL / $((PASS + FAIL))"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo "Failed tests:"
    for t in "${ERRORS[@]}"; do
        echo "  - $t"
    done
fi