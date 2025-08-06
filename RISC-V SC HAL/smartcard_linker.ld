/*
 * =====================================================================
 * smartcard_linker.ld - Linker Script for the custom PicoRV32 system (Simplified)
 * =====================================================================
 */

/* Define the entry point of the program. This must match the label
   in the startup.S file. */
ENTRY(_start)

MEMORY
{
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
  RAM (rwx) : ORIGIN = 0x00050000, LENGTH = 64K
}

/* Define a global symbol for the top of the stack. */
_stack_top = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  .text :
  {
    KEEP(*(.init))
    *(.text*)
    *(.rodata*)
  } > ROM

  .data :
  {
    . = ALIGN(4);
    *(.data*)
  } > RAM

  .bss :
  {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss*)
    *(COMMON)
    _bss_end = .;
  } > RAM
}
