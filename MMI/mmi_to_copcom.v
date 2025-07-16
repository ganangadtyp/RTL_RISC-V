`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 15:06:07
// Design Name: 
// Module Name: mmi_to_copcom
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

module mmi_to_copcom (
    // i/o between MMI
    //input   wire        clk,
    output  wire [55:0]  o_mmi,
    input   wire [71:0]  i_mmi,

    // i/o to COPCOM
    input   [7:0]   COPCRCO1_i, COPCRCO2_i, COPCRCSTAT_i,                               // Input from CRC
    input   [7:0]   COPRDSTAT_i, COPRD_i, COPRDLN_i, COPWRSTAT_i,                       // Input COM RD/WR
    output  [7:0]   COPCRCEN_o, COPCRCINIT1_o, COPCRCINIT2_o, COPCRCI1_o, COPCRCI2_o,   // Output to CRC
    output  [7:0]   COPRDEN_o, COPWR_o, COPWREN_o, COPWRLN_o                            // Output COM RD/WR
);

// Assign I/O based on address
assign    COPCRCEN_o      = i_mmi[7:0];
assign    COPCRCINIT1_o   = i_mmi[15:8];
assign    COPCRCINIT2_o   = i_mmi[23:16];
assign    COPCRCI1_o      = i_mmi[31:24];
assign    COPCRCI2_o      = i_mmi[39:32];
assign    COPWREN_o       = i_mmi[47:40];
assign    COPWR_o         = i_mmi[55:48];
assign    COPWRLN_o       = i_mmi[63:56];
assign    COPRDEN_o       = i_mmi[71:64];

assign    o_mmi[7:0]      = COPCRCSTAT_i;
assign    o_mmi[15:8]     = COPCRCO1_i;
assign    o_mmi[23:16]    = COPCRCO2_i;
assign    o_mmi[31:24]    = COPWRSTAT_i;
assign    o_mmi[39:32]    = COPRD_i;
assign    o_mmi[47:40]    = COPRDSTAT_i;
assign    o_mmi[55:48]    = COPRDLN_i;
// end

endmodule