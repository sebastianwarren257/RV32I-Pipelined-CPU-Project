    .section .text
    .globl _start
_start:
    addi x5, x0, 1      # x5 = 1   (t0)
    addi x6, x0, 0      # x6 = 0   (t1, base address)
    sw   x5, 0(x6)      # MEM[0] = 1

loop:
    jal  x0, loop       # infinite loop (j loop)