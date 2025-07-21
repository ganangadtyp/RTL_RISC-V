import sys
import argparse
import os # Import os module to check for file existence

def bin_to_coe(input_bin_file, output_coe_file, data_width_bits):
    """
    Converts a raw binary file to a Xilinx .coe file.

    Args:
        input_bin_file (str): Path to the input binary file.
        output_coe_file (str): Path to the output .coe file.
        data_width_bits (int): The data width of the BRAM in bits (e.g., 32 for RV32).
    """
    if data_width_bits % 8 != 0:
        print(f"Error: Data width ({data_width_bits} bits) must be a multiple of 8.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(input_bin_file):
        print(f"Error: Input binary file '{input_bin_file}' not found.", file=sys.stderr)
        sys.exit(1)

    bytes_per_word = data_width_bits // 8

    try:
        with open(input_bin_file, 'rb') as f_in:
            binary_data = f_in.read()
    except IOError as e:
        print(f"Error reading input file '{input_bin_file}': {e}", file=sys.stderr)
        sys.exit(1)

    # Pad with zeros if the binary data length is not a multiple of bytes_per_word
    padding_needed = (bytes_per_word - (len(binary_data) % bytes_per_word)) % bytes_per_word
    binary_data += b'\x00' * padding_needed

    data_list = []
    for i in range(0, len(binary_data), bytes_per_word):
        word_bytes = binary_data[i:i + bytes_per_word]
        # Interpret as little-endian (RISC-V is typically little-endian)
        word_int = int.from_bytes(word_bytes, byteorder='little')
        data_list.append(f"{word_int:0{data_width_bits//4}X}") # Format as hex, padded with leading zeros

    try:
        with open(output_coe_file, 'w') as f_out:
            f_out.write("MEMORY_INITIALIZATION_RADIX=16;\n")
            f_out.write("MEMORY_INITIALIZATION_VECTOR=\n")
            f_out.write(",\n".join(data_list))
            f_out.write(";")
    except IOError as e:
        print(f"Error writing output file '{output_coe_file}': {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Successfully converted '{input_bin_file}' to '{output_coe_file}' with {data_width_bits}-bit words.")
    print(f"Total words written: {len(data_list)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Converts a raw binary file (e.g., RISC-V program) into a Xilinx .coe memory initialization file.",
        formatter_class=argparse.RawTextHelpFormatter # Keeps formatting for description
    )

    parser.add_argument(
        "input_bin",
        type=str,
        help="Path to the input raw binary file (e.g., 'hello.bin').\n"
             "This file is typically generated from an ELF using:\n"
             "  riscv32-unknown-elf-objcopy -O binary <your_program>.elf <output>.bin"
    )
    parser.add_argument(
        "output_coe",
        type=str,
        help="Path for the output Xilinx .coe file (e.g., 'hello.coe')."
    )
    parser.add_argument(
        "-w", "--data-width",
        type=int,
        default=32,
        help="Data width of the target BRAM in bits (default: 32 for RV32 instructions).\n"
             "Must be a multiple of 8."
    )

    args = parser.parse_args()

    bin_to_coe(args.input_bin, args.output_coe, args.data_width)
