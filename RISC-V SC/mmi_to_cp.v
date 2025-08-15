`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Design Name: mmi_to_cp
// Module Name: mmi_to_cp.v
// Project Name: riscv_smartcard
// Target Devices: xc7a100tfgg484-2
// Tool Versions: Vivado 2019.1
// Description: This module connect data between the memory mapped interface (MMI) and coprocessor modules
//              All input and output data is explained in documentation
// 
// Dependencies: none
// 
//////////////////////////////////////////////////////////////////////////////////

module mmi_to_cp (
    // RAM
    output [23:0]  o_mmi,
    input  [63:0]  i_mmi,

    // Top Coprocessor Control
    input  [7:0]   i_data,
    input  [7:0]   i_statusout,
    input  [7:0]   i_statusout2,
    
    output  [7:0]  o_data,
    output  [7:0]  o_command,
    output  [15:0] o_addr_th,
    output  [15:0] o_addr_src,
    output  [15:0] o_addr_dest
);

    //To MMI
assign o_mmi [7:0]      = i_data;
assign o_mmi [15:8]     = i_statusout;
assign o_mmi [23:16]    = i_statusout2;

    //To CP
assign o_data           = i_mmi[7:0];
assign o_command        = i_mmi[15:8];
assign o_addr_th        = i_mmi[31:16];
assign o_addr_src       = i_mmi[47:32];
assign o_addr_dest      = i_mmi[63:48];
    
endmodule