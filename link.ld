OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
  DMEM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

PASS_ADDR = ORIGIN(DMEM);

SECTIONS {
  .text : { *(.text*) } > IMEM
  .data : { *(.data*) } > DMEM
  .bss  : { *(.bss*) *(COMMON) } > DMEM
}