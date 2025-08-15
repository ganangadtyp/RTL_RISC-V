`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Design Name: smartcard_3_tb
// Module Name: smartcard_3_tb.v
// Project Name: riscv_smartcard
// Target Devices: xc7a100tfgg484-2
// Tool Versions: Vivado 2019.1
// Description: This is testbench file for smartcard_3. The first section contains testbench for CPU without serial input
//              the second section contaim testbench with simulated serial miller input. ROM initialization file used is
//              main_3.coe. Change the file content to the output file from the compiler.
// 
// Dependencies:    smartcard_3.v (and each of its component files)
//                      picorv32.v,
//                      ISO14443_wrapper.vhd (and each of its component files),
//                      top_coprocessor_control.vhd (and each of its component files),
//                      mmi_top.v,
//                          mmi_to_cp.v,
//                          mmi_to_copcom.v,
//                          ram.v,
//                      bus_interface.v,
//                      pico_rom_3.xci,
//                      pico_rom_2.xci
//                  main_3.coe
// 
//////////////////////////////////////////////////////////////////////////////////


//module smartcard_3_tb();
   
//    reg clk_sc;
//    reg reset;
//    reg resetn;
//    wire trap;
//    wire [31:0] instr_out;
       
//    smartcard_3 smartcard(
//        .clk_sc(clk_sc),
//        .reset(reset),
//        .resetn(resetn),
//        .instr_out(instr_out),
//        .trap(trap)
//    );

//    reg  [63:0] instr_mnemonic;
    
//    wire [15:0] instr_16 = instr_out[15:0];

//    always #5 clk_sc = ~clk_sc;
    
//    always @(*) begin
//        casez (instr_out)
//            // --- Initial Memory ---
//            32'b0000000_00000_00000_000_00000_0000000: instr_mnemonic = "UNKNOWN ";
            
//            // --- RV32I ---
//            32'b0000000_?????_?????_000_?????_0110011: instr_mnemonic = "ADD     ";
//            32'b0100000_?????_?????_000_?????_0110011: instr_mnemonic = "SUB     ";
//            32'b0000000_?????_?????_111_?????_0110011: instr_mnemonic = "AND     ";
//            32'b0000000_?????_?????_110_?????_0110011: instr_mnemonic = "OR      ";
//            32'b0000000_?????_?????_100_?????_0110011: instr_mnemonic = "XOR     ";
//            32'b0000000_?????_?????_001_?????_0110011: instr_mnemonic = "SLL     ";
//            32'b0000000_?????_?????_101_?????_0110011: instr_mnemonic = "SRL     ";
//            32'b0100000_?????_?????_101_?????_0110011: instr_mnemonic = "SRA     ";
//            32'b0000000_?????_?????_010_?????_0110011: instr_mnemonic = "SLT     ";
//            32'b0000000_?????_?????_011_?????_0110011: instr_mnemonic = "SLTU    ";
    
//            32'b????????????????_000_?????_0010011: instr_mnemonic = "ADDI    ";
//            32'b????????????????_111_?????_0010011: instr_mnemonic = "ANDI    ";
//            32'b????????????????_110_?????_0010011: instr_mnemonic = "ORI     ";
//            32'b????????????????_100_?????_0010011: instr_mnemonic = "XORI    ";
//            32'b?????????????????????????_0110111: instr_mnemonic = "LUI      ";
    
//            32'b?????????????????????????_1101111: instr_mnemonic = "JAL     ";
//            32'b????????????????_000_?????_1100111: instr_mnemonic = "JALR    ";
//            32'b????????????????_000_?????_1100011: instr_mnemonic = "BEQ     ";
//            32'b????????????????_001_?????_1100011: instr_mnemonic = "BNE     ";
    
//            32'b????????????????_010_?????_0000011: instr_mnemonic = "LW      ";
//            32'b????????????????_010_?????_0100011: instr_mnemonic = "SW      ";
    
//            // --- RV32M ---
//            32'b0000001_?????_?????_000_?????_0110011: instr_mnemonic = "MUL     ";
//            32'b0000001_?????_?????_100_?????_0110011: instr_mnemonic = "DIV     ";
//            32'b0000001_?????_?????_110_?????_0110011: instr_mnemonic = "REM     ";
    
//            // --- RV32C (Compressed, check instruction[15:0]) ---
//            default: begin
//                casez (instr_16)
//                    16'b000_??_???_???_00: instr_mnemonic = "C.ADDI4SPN";
//                    16'b0000000000000001: instr_mnemonic = "C.NOP   ";
//                    16'b000_???_???_01:   instr_mnemonic = "C.ADDI  ";
//                    16'b001_???_???_01:   instr_mnemonic = "C.JAL   ";
//                    16'b010_???_???_01:   instr_mnemonic = "C.LI    ";
//                    16'b011_???_???_01:   instr_mnemonic = "C.LUI   ";
//                    16'b100_???_???_01:   instr_mnemonic = "C.SRLI/SRAI";
//                    16'b101_???_???_01:   instr_mnemonic = "C.J     ";
//                    16'b110_???_???_01:   instr_mnemonic = "C.BEQZ  ";
//                    16'b111_???_???_01:   instr_mnemonic = "C.BNEZ  ";
    
//                    16'b100_???_???_10:   instr_mnemonic = "C.MV    ";
//                    16'b1001_???_???_10:  instr_mnemonic = "C.ADD   ";
//                    16'b110_???_???_00:   instr_mnemonic = "C.SW    ";
//                    16'b010_???_???_00:   instr_mnemonic = "C.LW    ";
    
//                    default: instr_mnemonic = "UNKNOWN ";
//                endcase
//            end
//        endcase
//    end

//    initial begin
//        clk_sc = 1'b0;
//        resetn  = 1'b0;
//        reset = 1'b1;
//        #50;
//        resetn  = 1'b1;
//        reset  = 1'b0;
        
//    end
//endmodule

/* Miller serial simulation */

module smartcard_3_tb();

reg clk_sc;
reg reset;
reg resetn;
reg miller_in;
wire serial_out;
wire trap;
wire [31:0] instr_out;
   
smartcard_2 smartcard(
    .clk_sc(clk_sc),
    .reset(reset),
    .resetn(resetn),
    .instr_out(instr_out),
    .miller_in(miller_in),
    .serial_out(serial_out),
    .trap(trap)
);

reg  [63:0] instr_mnemonic;

wire [15:0] instr_16 = instr_out[15:0];

always #(73.757/2) clk_sc = ~clk_sc;

always @(*) begin
    casez (instr_out)
        // --- Initial Memory ---
        32'b0000000_00000_00000_000_00000_0000000: instr_mnemonic = "UNKNOWN ";
        
        // --- RV32I ---
        32'b0000000_?????_?????_000_?????_0110011: instr_mnemonic = "ADD     ";
        32'b0100000_?????_?????_000_?????_0110011: instr_mnemonic = "SUB     ";
        32'b0000000_?????_?????_111_?????_0110011: instr_mnemonic = "AND     ";
        32'b0000000_?????_?????_110_?????_0110011: instr_mnemonic = "OR      ";
        32'b0000000_?????_?????_100_?????_0110011: instr_mnemonic = "XOR     ";
        32'b0000000_?????_?????_001_?????_0110011: instr_mnemonic = "SLL     ";
        32'b0000000_?????_?????_101_?????_0110011: instr_mnemonic = "SRL     ";
        32'b0100000_?????_?????_101_?????_0110011: instr_mnemonic = "SRA     ";
        32'b0000000_?????_?????_010_?????_0110011: instr_mnemonic = "SLT     ";
        32'b0000000_?????_?????_011_?????_0110011: instr_mnemonic = "SLTU    ";

        32'b????????????????_000_?????_0010011: instr_mnemonic = "ADDI    ";
        32'b????????????????_111_?????_0010011: instr_mnemonic = "ANDI    ";
        32'b????????????????_110_?????_0010011: instr_mnemonic = "ORI     ";
        32'b????????????????_100_?????_0010011: instr_mnemonic = "XORI    ";
        32'b?????????????????????????_0110111: instr_mnemonic = "LUI      ";

        32'b?????????????????????????_1101111: instr_mnemonic = "JAL     ";
        32'b????????????????_000_?????_1100111: instr_mnemonic = "JALR    ";
        32'b????????????????_000_?????_1100011: instr_mnemonic = "BEQ     ";
        32'b????????????????_001_?????_1100011: instr_mnemonic = "BNE     ";

        32'b????????????????_010_?????_0000011: instr_mnemonic = "LW      ";
        32'b????????????????_010_?????_0100011: instr_mnemonic = "SW      ";

        // --- RV32M ---
        32'b0000001_?????_?????_000_?????_0110011: instr_mnemonic = "MUL     ";
        32'b0000001_?????_?????_100_?????_0110011: instr_mnemonic = "DIV     ";
        32'b0000001_?????_?????_110_?????_0110011: instr_mnemonic = "REM     ";

        // --- RV32C (Compressed, check instruction[15:0]) ---
        default: begin
            casez (instr_16)
                16'b000_??_???_???_00: instr_mnemonic = "C.ADDI4SPN";
                16'b0000000000000001: instr_mnemonic = "C.NOP   ";
                16'b000_???_???_01:   instr_mnemonic = "C.ADDI  ";
                16'b001_???_???_01:   instr_mnemonic = "C.JAL   ";
                16'b010_???_???_01:   instr_mnemonic = "C.LI    ";
                16'b011_???_???_01:   instr_mnemonic = "C.LUI   ";
                16'b100_???_???_01:   instr_mnemonic = "C.SRLI/SRAI";
                16'b101_???_???_01:   instr_mnemonic = "C.J     ";
                16'b110_???_???_01:   instr_mnemonic = "C.BEQZ  ";
                16'b111_???_???_01:   instr_mnemonic = "C.BNEZ  ";

                16'b100_???_???_10:   instr_mnemonic = "C.MV    ";
                16'b1001_???_???_10:  instr_mnemonic = "C.ADD   ";
                16'b110_???_???_00:   instr_mnemonic = "C.SW    ";
                16'b010_???_???_00:   instr_mnemonic = "C.LW    ";

                default: instr_mnemonic = "UNKNOWN ";
            endcase
        end
    endcase
end
    
reg prev_bit;
integer i;

reg [7:0]   test_pattern    = 8'b00100110;
reg [17:0]  test_pattern2   = 18'b01_00100000_0_10010011;

localparam  clk_period = 73.757;
localparam  bit_period = 9440;
    
initial begin

    clk_sc = 1'b0;
    resetn  = 1'b0;
    reset = 1'b1;
    miller_in = 1;
    #(1*clk_period);
    
    resetn  = 1'b1;
    reset  = 1'b0;
    #(100*clk_period);
    
    // Start of com
    miller_in = 0;
    #(bit_period/2);
    miller_in = 1;
    #(bit_period/2);
    
    prev_bit = 0;
    
    for (i = 0; i < 8; i = i + 1) begin
        if (test_pattern[i]) begin
            miller_in = 1;
            #(bit_period/2);
            miller_in = 0;
            #(bit_period/2);
        end
        else begin
            if (prev_bit) begin
                miller_in = 1;
                #(bit_period);
            end
            else begin
                miller_in = 0;
                #(bit_period/2);
                miller_in = 1;
                #(bit_period/2);
            end
        end
        
        prev_bit = test_pattern[i];
    end
    
    // idle
    miller_in = 1;
    #(clk_period * 7000);
    
    // Start of frame
    miller_in = 0;
    #(bit_period/2);
    miller_in = 1;
    #(bit_period/2);
    prev_bit = 0;
    
    for (i = 0; i < 8; i = i + 1) begin
        if (test_pattern[i]) begin
            miller_in = 1;
            #(bit_period/2);
            miller_in = 0;
            #(bit_period/2);
        end
        else begin
            if (prev_bit) begin
                miller_in = 1;
                #(bit_period);
            end
            else begin
                miller_in = 0;
                #(bit_period/2);
                miller_in = 1;
                #(bit_period/2);
            end
        end
        
        prev_bit = test_pattern[i];
    end
    
    // idle
    miller_in = 1;
    #(clk_period * 7000);
    
    // Start of com
    miller_in = 0;
    #(bit_period/2);
    miller_in = 1;
    #(bit_period/2);
    
    for (i = 0; i < 18; i = i + 1) begin
        if (test_pattern2[i]) begin
            miller_in = 1;
            #(bit_period/2);
            miller_in = 0;
            #(bit_period/2);
        end
        else begin
            if (prev_bit) begin
                miller_in = 1;
                #(bit_period);
            end
            else begin
                miller_in = 0;
                #(bit_period/2);
                miller_in = 1;
                #(bit_period/2);
            end
        end
        
        prev_bit = test_pattern2[i];
    end
    
end
endmodule
// */
