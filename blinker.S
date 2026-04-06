    .section .text
    .global _start
_start:
    li t0, 0x00010000  # LED Mem address
    li t1, 0x00008000  # LED turns leftmost LED on
    li t2, 0x01000000  # Delay Count

loop:
    sw t1 ,0(t0) # write pattern
    mv t3, t2 # addi t3, t2, 0
delay:
    addi t3, t3, -1 #decrement count
    bnez t3, delay #branches to delay until t3==0
    srli t1, t1, 1 #shift LED light one to the right
    beqz t1, _start #branches to _start when led hits past rightmost led
    j loop # repeat forever


