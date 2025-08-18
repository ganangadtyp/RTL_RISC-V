# # Makefile for PicoRV32 Firmware Compilation
# # This version handles linker warnings and builds a specific target.

# --- Configuration ---
# Set the base name for the target firmware files
# TARGET = main
# TARGET = comm
TARGET = crypto
HAL = hal

# Toolchain definitions
CC = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
PYTHON = python3

# Compiler and Linker Flags
# CFLAGS = -march=rv32i -mabi=ilp32 -g -Os -fno-jump-tables
CFLAGS = -march=rv32i -mabi=ilp32 -g -Os
LDFLAGS = -nostdlib -T smartcard_linker.ld -Wl,--no-warn-rwx-segments

# Source files
C_SRCS = $(TARGET).c
C_HAL  = $(HAL).c
S_SRCS = startup.S
OBJS = $(C_SRCS:.c=.o) $(C_HAL:.c=.o) $(S_SRCS:.S=.o)
# OBJS = $(C_SRCS:.c=.o) $(S_SRCS:.S=.o)

# --- Build Rules ---
# Default target - builds the COE file
all: $(TARGET).coe

# Rule to create the final .coe file from the .bin file
$(TARGET).coe: $(TARGET).bin
	@echo "CONVERTING $(TARGET).bin to $(TARGET).coe"
	$(PYTHON) bin_to_coe.py $< $@

# Rule to create the .bin file from the .elf file
$(TARGET).bin: $(TARGET).elf
	@echo "CREATING Binary $< -> $@"
	$(OBJCOPY) -O binary $< $@

# Rule to link the final .elf file from object files using custom linker script
$(TARGET).elf: $(OBJS) smartcard_linker.ld
	@echo "LINKING -> $@ (using custom linker script)"
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

# Generic rule to compile C source files
%.o: %.c
	@echo "COMPILING C $< -> $@"
	$(CC) $(CFLAGS) -c -o $@ $<

# Generic rule to assemble startup file
%.o: %.S
	@echo "ASSEMBLING $< -> $@"
	$(CC) $(CFLAGS) -c -o $@ $<

# --- Housekeeping ---
# Clean up generated files
clean:
	@echo "CLEANING build files for $(TARGET)"
	rm -f $(TARGET).o startup.o $(TARGET).elf $(TARGET).bin
	@echo "CLEANING build files for"
	rm -f $(HAL).o startup.o $(HAL).elf $(HAL).bin $(HAL).coe

# Show memory layout information
info: $(TARGET).elf
	@echo "=== Memory Layout Information ==="
	riscv32-unknown-elf-size $(TARGET).elf
	@echo "=== Section Headers ==="
	riscv32-unknown-elf-objdump -h $(TARGET).elf

# Phony targets
.PHONY: all clean info
