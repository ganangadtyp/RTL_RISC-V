`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Design Name: bus_interface_3
// Module Name: bus_interface_3.v
// Project Name: riscv_smartcard
// Target Devices: xc7a100tfgg484-2
// Tool Versions: Vivado 2019.1
// Description: This module act as an intermediary between the CPU and to all of its memory related module.
//              The PicoRV-32 only has one address, read data, and write data wire, hencewny bus interfacing is
//              necessary to facilitate data exchange between the CPU to RAM, ROM, and MMI.
// 
// Dependencies: none
// 
//////////////////////////////////////////////////////////////////////////////////


module bus_interface_3(
    input clk, reset,
    
    //CPU
    input           mem_valid,
    input           mem_instr,
    input  [31:0]   mem_addr,
    input  [3:0]    mem_wstrb,
    input  [31:0]   mem_wdata,
    output          mem_ready,
    output [31:0]   mem_rdata,

    //MMI
    output          mmi_valid,
    output [2:0]    mmi_addr,                           /* CHANGE width according to MMI address width */
    output [3:0]    mmi_wstrb,
    input           mmi_ready,
    output [31:0]   mmi_wdata,
    input  [31:0]   mmi_rdata,

    //RAM
    output          ram_en,
    output [13:0]   ram_addr,                           /* CHANGE width according to RAM address width */
    output [3:0]    ram_wea,
    output [31:0]   ram_wdata,
    input  [31:0]   ram_rdata,

    //ROM
    output [16:0]  rom_addr,                            /* CHANGE width according to ROM address width */
    input  [31:0]  rom_rdata,
    output         rom_en
);

reg ram_ready, rom_ready;
reg [31:0] last_mem_rdata;

// CPU
assign mem_ready = mmi_ready || rom_ready || ram_ready;
assign mem_rdata = rom_ready ? rom_rdata : ram_ready ? ram_rdata : mmi_ready ? mmi_rdata : last_mem_rdata;

// MMI
assign mmi_valid = (mem_valid && (!mem_instr) && mem_addr[21:20] == 2'b01)? 1'd1 : 1'd0;                            /* CHANGE address selector according to allocated MMI address */
assign mmi_addr  = mem_addr[4:2];                                                                                   /* CHANGE width according to MMI address width */
assign mmi_wstrb = mem_wstrb;
assign mmi_wdata = mem_wdata;

// RAM
assign ram_en    = (mem_valid && (!mem_instr) && mem_addr[21:20] == 2'b10)? 1'd1 : 1'd0;                            /* CHANGE address selector according to allocated RAM address */
assign ram_addr  = mem_addr[15:2];                                                                                  /* CHANGE width according to RAM address width */
assign ram_wea   = mem_wstrb;
assign ram_wdata = mem_wdata;

// ROM
assign rom_en   = (mem_valid && mem_instr && (mem_addr[21:20] == 2'b00))? 1'd1 : 1'd0;                              /* CHANGE address selector according to ROM allocated address */
assign rom_addr = mem_addr[18:2];                                                                                   /* CHANGE width according to ROM address width */
    
//Control RAM dan ROM
always @(posedge clk) begin
    if (!reset) begin
        ram_ready <= ram_en;
        rom_ready <= rom_en; 
        last_mem_rdata <= mem_rdata;
    end
    else begin
        ram_ready <= 1'd0;
        rom_ready <= 1'd0;
        last_mem_rdata <= 32'd0;
    end
end

endmodule
