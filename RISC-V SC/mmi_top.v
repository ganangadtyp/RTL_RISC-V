`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 15:06:07
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mmi_top (
    input clk, rst,

    // i/o ram-bus
    input           mmi_valid,
    output          mmi_ready,
    input   [3:0]   mmi_wstrb,
    input   [31:0]  i_mmi_wdata, // Input data yang ingin ditulis
    output  [31:0]  o_mmi_rdata, // Data read dari register
    input   [2:0]   i_mmi_addr,     // Input alamat

    // i/o mmi-com
    input   [7:0]   COPCRCSTAT_i,
    input   [7:0]   COPCRCO1_i, 
    input   [7:0]   COPCRCO2_i,
    input   [7:0]   COPRDSTAT_i, 
    input   [7:0]   COPRD_i, 
    input   [7:0]   COPRDLN_i, 
    input   [7:0]   COPWRSTAT_i,
    
    output  [7:0]   COPCRCEN_o, 
    output  [7:0]   COPCRCINIT1_o, 
    output  [7:0]   COPCRCINIT2_o, 
    output  [7:0]   COPCRCI1_o, 
    output  [7:0]   COPCRCI2_o,
    output  [7:0]   COPRDEN_o, 
    output  [7:0]   COPWR_o, 
    output  [7:0]   COPWREN_o, 
    output  [7:0]   COPWRLN_o,

    // i/o mmi-cp
    input [7:0] i_data,
    input [7:0] i_statusout,
    input [7:0] i_statusout2,
    
    output [7:0] o_data,
    output [7:0] o_command,
    output [15:0] o_addr_th,
    output [15:0] o_addr_src,
    output [15:0] o_addr_dest     

);

    // i/o ram-com
    wire [55:0] o_mmi_com;
    wire [71:0] i_mmi_com;

    // i/o ram-cp
    wire [23:0] o_mmi_cp;
    wire [63:0] i_mmi_cp;

    ram ram(
        .clk(clk),
        .rst(rst),
        // ram-bus
        .mmi_valid(mmi_valid),
        .mmi_ready(mmi_ready),
        .mmi_wstrb(mmi_wstrb),
        .i_mmi_wdata(i_mmi_wdata),  // Input data yang ingin ditulis
        .o_mmi_rdata(o_mmi_rdata),  // Data read dari register
        .i_mmi_addr(i_mmi_addr),    // Input alamat

        // ram-com
        .i_com(o_mmi_com),
        .o_com(i_mmi_com),

        // ram-cp
        .i_cp(o_mmi_cp),
        .o_cp(i_mmi_cp)

    );

    mmi_to_copcom mmi_to_copcom(
        // ram-com
        .i_mmi(i_mmi_com),
        .o_mmi(o_mmi_com),

        // mmi-com
        .COPCRCO1_i(COPCRCO1_i), 
        .COPCRCO2_i(COPCRCO2_i), 
        .COPCRCSTAT_i(COPCRCSTAT_i),                            
        .COPRDSTAT_i(COPRDSTAT_i), 
        .COPRD_i(COPRD_i), 
        .COPRDLN_i(COPRDLN_i), 
        .COPWRSTAT_i(COPWRSTAT_i),                    
        .COPCRCEN_o(COPCRCEN_o), 
        .COPCRCINIT1_o(COPCRCINIT1_o), 
        .COPCRCINIT2_o(COPCRCINIT2_o), 
        .COPCRCI1_o(COPCRCI1_o), 
        .COPCRCI2_o(COPCRCI2_o),
        .COPRDEN_o(COPRDEN_o), 
        .COPWR_o(COPWR_o), 
        .COPWREN_o(COPWREN_o), 
        .COPWRLN_o(COPWRLN_o)     

    );

    mmi_to_cp mmi_to_cp(
        // ram-cp
        .i_mmi(i_mmi_cp),
        .o_mmi(o_mmi_cp),

        // Top Coprocessor Control
        .i_data(i_data),
        .i_statusout(i_statusout),
        .i_statusout2(i_statusout2),
        
        .o_data(o_data),
        .o_command(o_command),
        .o_addr_th(o_addr_th),
        .o_addr_src(o_addr_src),
        .o_addr_dest(o_addr_dest)

    );
endmodule