`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 11:22:06
// Design Name: 
// Module Name: ram
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

module ram (
    input   wire        clk,
    input   wire        rst,

    // Bus Interface
    input               mmi_valid,
    input       [3:0]   mmi_wstrb,
    output reg          mmi_ready,
    input       [31:0]  i_mmi_wdata, // Input data yang ingin ditulis
    output reg  [31:0]  o_mmi_rdata, // Data read dari register
    input       [2:0]   i_mmi_addr,     // Input alamat

    // CP Interface
    input       [23:0]  i_cp,
    output reg  [63:0]  o_cp,

    // input com, tiap clock seluruh register untuk com dibaca dan ditulis nilainya. List nilai tiap bit ada di bawah
    input       [55:0]  i_com,
    output reg  [71:0]  o_com

);

reg [31:0] ram [0:7];

//assign mmi_ready = mmi_valid;

always @(posedge clk) begin
    //    write from CPU
    if (rst) begin 
        //ram      <= 0;
        ram[3'h0]      <= 0;    // StatusOut2   StatusOut1	Data
        ram[3'h1]      <= 0;    // COPCRCO2	    COPCRCO1	COPCRCSTAT	
        ram[3'h2]      <= 0;    // COPRDLN		COPRDSTAT   COPRD		COPWRSTAT
        ram[3'h3]      <= 0;    // AdThIn		            Command		Data
        ram[3'h4]      <= 0;    // AdDstIn		            AdSrcIn
        ram[3'h5]      <= 0;    //									    COPCRCEN
        ram[3'h6]      <= 0;    // COPCRCI2	    COPCRCI1	COPCRCINIT2	COPCRCINIT1
        ram[3'h7]      <= 0;    // COPRDEN		COPWRLN		COPWR		COPWREN
    end
    else begin
        // r/w cpu to register
        if (mmi_valid) begin
            if (i_mmi_addr > 2) begin   // writeable address 0x0 - 0x2
                if (mmi_wstrb[0]) ram[i_mmi_addr][7:0]    <= i_mmi_wdata[7:0];
                if (mmi_wstrb[1]) ram[i_mmi_addr][15:8]   <= i_mmi_wdata[15:8];
                if (mmi_wstrb[2]) ram[i_mmi_addr][23:16]  <= i_mmi_wdata[23:16];
                if (mmi_wstrb[3]) ram[i_mmi_addr][31:24]  <= i_mmi_wdata[31:24];
            end
            else mmi_ready <= 1;        // read only address 0x3 - 0x7
        end
        else mmi_ready <= 0;
        
        // read data
        o_mmi_rdata <= ram[i_mmi_addr];
    
        // r/w cop-com to register
        // Write from CP
        ram[3'h0][7:0]      <= i_cp[7:0];
        ram[3'h0][15:8]     <= i_cp[15:8];
        ram[3'h0][23:16]    <= i_cp[23:16];
    
        // Write from Communication
        ram[3'h1][31:8]   <= i_com[23:0];  
        ram[3'h2]         <= i_com[55:24];  
        
        // Send to CP
        o_cp <= {ram[3'h4][31:16], ram[3'h4][15:0], ram[3'h3][31:16], ram[3'h3][15:8],ram[3'h3][7:0]};
    
        // Send to Communication
        o_com    <= {ram[3'h7][31:0], ram[3'h6][31:0], ram[3'h5][7:0]};
        
    end
end

endmodule
