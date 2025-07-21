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

module mmi_to_cp (
    // RAM
    output [23:0] o_mmi,
    input [63:0] i_mmi,

    // Top Coprocessor Control
    input [7:0] i_data,
    input [7:0] i_statusout,
    input [7:0] i_statusout2,
    
    output [7:0] o_data,
    output [7:0] o_command,
    output [15:0] o_addr_th,
    output [15:0] o_addr_src,
    output [15:0] o_addr_dest
);

    //To MMI
    assign o_mmi [7:0] = i_data;
    assign o_mmi [15:8] = i_statusout;
    assign o_mmi [23:16] = i_statusout2;

    //To CP
    assign o_data = i_mmi[7:0];
    assign o_command = i_mmi[15:8];
    assign o_addr_th = i_mmi[31:16];
    assign o_addr_src = i_mmi[47:32];
    assign o_addr_dest = i_mmi[63:48];
    
endmodule