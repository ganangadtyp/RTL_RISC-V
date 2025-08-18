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
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 512K
  RAM (rwx) : ORIGIN = 0x00200000, LENGTH = 64K
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

  /* Read-only data: loaded from ROM but run from RAM */
  .rodata : ALIGN(4)
  {
    _rodata_load_start = LOADADDR(.rodata); /* in ROM */
    _rodata_start = .;                      /* in RAM */
    *(.rodata*)
    *(.rodata.*)
    _rodata_end = .;
  } > RAM AT > ROM

  /* Writable data: also loaded from ROM into RAM */
  .data : ALIGN(4)
  {
    _data_load_start = LOADADDR(.data);
    _data_start = .;
    *(.data*)
    _data_end = .;
  } > RAM AT > ROM

  .bss :
  {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss*)
    *(COMMON)
    _bss_end = .;
  } > RAM
}
