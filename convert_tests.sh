
#!/bin/bash

RISCV_TESTS=/mnt/c/CPU_project/riscv-tests/isa
OUTPUT=/mnt/c/CPU_project/tests

echo "=== Converting rv32ui tests to hex ==="

cd $RISCV_TESTS

for test in rv32ui-p-*; do
    if file "$test" | grep -q ELF; then
        # Convert to binary first
        riscv32-unknown-elf-objcopy -O binary "$test" "/tmp/${test}.bin"

        # Word-wide hex for imem
        python3 -c "
import struct
with open('/tmp/${test}.bin', 'rb') as f:
    data = f.read()
while len(data) % 4:
    data += b'\x00'
with open('${OUTPUT}/${test}.hex', 'w') as f:
    for i in range(0, len(data), 4):
        word = struct.unpack_from('<I', data, i)[0]
        f.write(f'{word:08x}\n')
"

        # Byte-wide hex for dmem
        python3 -c "
with open('/tmp/${test}.bin', 'rb') as f:
    data = f.read()
with open('${OUTPUT}/${test}.dmem.hex', 'w') as f:
    for byte in data:
        f.write(f'{byte:02x}\n')
"
        echo "Converted $test"
    fi
done

echo "=== Done ==="