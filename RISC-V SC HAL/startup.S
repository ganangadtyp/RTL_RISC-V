    # =====================================================================
    # startup.S - Startup file for the custom PicoRV32 system (modified)
    # Copies .rodata/.data from ROM to RAM, clears .bss, then calls main()
    # =====================================================================

    .section .init, "ax"
    .global _start
    _start:
        # 1 Initialize the Stack Pointer
        la   sp, _stack_top

        # ------------------------------------------------------------
        # 2 Copy .rodata from ROM (LMA) to RAM (VMA)
        # _rodata_load_start = address in ROM (LOADADDR)
        # _rodata_start/_rodata_end = runtime addresses in RAM
        # ------------------------------------------------------------
        la   t0, _rodata_load_start   # t0 = source (ROM)
        la   t1, _rodata_start        # t1 = dest   (RAM)
        la   t2, _rodata_end          # t2 = end    (RAM)
1:      beq  t1, t2, 2f
        lw   t3, 0(t0)
        sw   t3, 0(t1)
        addi t0, t0, 4
        addi t1, t1, 4
        j    1b
2:

        # ------------------------------------------------------------
        # 3 Copy .data from ROM (LMA) to RAM (VMA)
        # ------------------------------------------------------------
        la   t0, _data_load_start
        la   t1, _data_start
        la   t2, _data_end
3:      beq  t1, t2, 4f
        lw   t3, 0(t0)
        sw   t3, 0(t1)
        addi t0, t0, 4
        addi t1, t1, 4
        j    3b
4:

        # ------------------------------------------------------------
        # 4 Zero the .bss region
        # ------------------------------------------------------------
        la   a0, _bss_start
        la   a1, _bss_end
bss_zero_loop:
        beq  a0, a1, bss_done
        sw   zero, 0(a0)
        addi a0, a0, 4
        j    bss_zero_loop
bss_done:

        # 5 Call main()
        call main

hang:
        j hang
