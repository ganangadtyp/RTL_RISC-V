# =====================================================================
# startup.S - Startup file for the custom PicoRV32 system
#
# This code executes immediately on reset. It initializes the stack,
# clears the .bss section, and then calls the main() function in C.
# =====================================================================
#

# We place this code in a special ".init" section to ensure the linker
# places it at the very beginning of the executable, right after reset.
.section .init, "ax"
.global _start  # Make the _start label visible to the linker.
# The _start label is the official entry point of the program. 
_start:
        # -----------------------------------------------------------------
        # 1. Initialize the Stack Pointer (sp)
        #        The stack grows downwards from the top of RAM. We load the
        #        address of _stack_top (defined in the linker script) into 'sp'.
        # -----------------------------------------------------------------
        la sp, _stack_top

        # -----------------------------------------------------------------
        # 2. Clear the .bss section
        #        The .bss section holds uninitialized global/static variables.
        #        The C standard requires them to be zero before main() runs.
        #        We use the _bss_start and _bss_end symbols from the linker script.
        # -----------------------------------------------------------------
        la a0, _bss_start    # Load start address of .bss into register a0
        la a1, _bss_end         # Load end address of .bss into register a1

bss_zero_loop:
        beq a0, a1, bss_done    # If start address >= end address, we are done
        sw zero, 0(a0)            # Store a zero word at the current address
        addi a0, a0, 4            # Move pointer to the next word (4 bytes)
        j bss_zero_loop              # Repeat

bss_done:
        # -----------------------------------------------------------------
        # 3. Call the main() function from the C code
        # -----------------------------------------------------------------
        call main

        # -----------------------------------------------------------------
        # 4. Trap in an infinite loop
        #        In a bare-metal system, main() should never return. If it does,
        #        we catch the processor in a safe, infinite loop here.
        # -----------------------------------------------------------------

hang:
        j hang