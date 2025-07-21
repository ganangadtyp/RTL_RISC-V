## bin_to_coe.py

Converts C binary file into .coe file suitable for initializing FPGA BRAM

To use it, make sure python3 is installed in your system and is discoverable (inside PATH variable). Then, type in your shell:

```
python3 bin_to_coe.py [input binary filename].bin [output coe filename].coe 
```

Type `python3 bin_to_coe.py --help/-h` for more detail.

## matrix_mult.c

The C program that multiplies two matrices that adheres to matrix multiplication rule. The matrix is hard-coded inside the program. 

## matrix_mult_[rv32 extension].coe

All the compiled C program corresponding .coe file for each RV32 extension
