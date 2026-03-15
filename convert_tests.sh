#!/bin/bash

RISCV_TESTS=/mnt/c/CPU_project/riscv-tests/isa
OUTPUT=/mnt/c/CPU_project/tests

echo "=== Converting rv32ui tests to hex ==="

cd $RISCV_TESTS

for test in rv32ui-p-*; do
    if file "$test" | grep -q ELF; then
        riscv32-unknown-elf-objcopy -O binary "$test" "/tmp/${test}.bin"
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
        echo "Converted $test"
    fi
done

echo "=== Done ==="
EOF

chmod +x /mnt/c/CPU_project/convert_tests.sh