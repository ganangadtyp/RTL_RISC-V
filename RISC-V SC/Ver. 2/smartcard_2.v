`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2025 11:54:16
// Design Name: 
// Module Name: smartcard_2
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


module smartcard_2(
    input clk_sc,
    input reset,
    input resetn,
    output [31:0] instr_out,
    output trap,
    output serial_out
    );
    
    wire mem_valid, mem_instr, mem_ready;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire [3:0] mem_wstrb;
    
    wire [13:0] ram_addr;
    wire [15:0] rom_addr;
    wire [31:0] ram_wdata, ram_rdata, rom_rdata;
    wire [3:0] ram_wea;
    wire ram_en, rom_en;
    
    wire mmi_valid;
    wire mmi_ready;
    wire [3:0] mmi_wstrb;
    wire [31:0] i_mmi_wdata;
    wire [31:0] o_mmi_rdata;
    wire [2:0] i_mmi_addr;
    
    wire [7:0] COPCRCSTAT_i;
    wire [7:0] COPCRCO1_i; 
    wire [7:0] COPCRCO2_i;
    wire [7:0] COPRDSTAT_i; 
    wire [7:0] COPRD_i;
    wire [7:0] COPRDLN_i; 
    wire [7:0] COPWRSTAT_i;
    
    wire [7:0] COPCRCEN_o;
    wire [7:0] COPCRCINIT1_o; 
    wire [7:0] COPCRCINIT2_o; 
    wire [7:0] COPCRCI1_o; 
    wire [7:0] COPCRCI2_o;
    wire [7:0] COPRDEN_o; 
    wire [7:0] COPWR_o; 
    wire [7:0] COPWREN_o; 
    wire [7:0] COPWRLN_o;

    wire [7:0] i_data;
    wire [7:0] i_statusout;
    wire [7:0] i_statusout2;
    
    wire [7:0] o_data;
    wire [7:0] o_command;
    wire [15:0] o_addr_th;
    wire [15:0] o_addr_src;
    wire [15:0] o_addr_dest;
    
    assign instr_out = mem_rdata;
    
    picorv32 core(
        .clk(clk_sc),
        .resetn(resetn),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .trap(trap),

        // Not used in this example:
            // Look-Ahead Interface
            .mem_la_read(),
            .mem_la_write(),
            .mem_la_addr(),
            .mem_la_wdata(),
            .mem_la_wstrb(),
            
            // Pico Co-Processor Interface (PCPI)
            .pcpi_valid(),
            .pcpi_insn(),
            .pcpi_rs1(),
            .pcpi_rs2(),
            .pcpi_wr(),
            .pcpi_rd(),
            .pcpi_wait(),
            .pcpi_ready(),
            
            // IRQ Interface
            .irq(32'h00000000),
            .eoi()
    );
    
    bus_interface_2 interface(
        .clk(clk_sc),
        .mem_addr(mem_addr),
        .mem_instr(mem_instr),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready),
        .mem_valid(mem_valid),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mmi_valid(mmi_valid),
        .mmi_addr(i_mmi_addr),
        .mmi_wstrb(mmi_wstrb),
        .mmi_rdata(o_mmi_rdata),
        .mmi_wdata(i_mmi_wdata),
        .mmi_ready(mmi_ready),
        .ram_addr(ram_addr),
        .ram_en(ram_en),
        .ram_rdata(ram_rdata),
        .ram_wdata(ram_wdata),
        .ram_wea(ram_wea),
        .reset(reset),
        .rom_addr(rom_addr),
        .rom_en(rom_en),
        .rom_rdata(rom_rdata));
        
    pico_ram pico_ram(
      .clka(clk_sc),                    // input wire clka
      .ena(ram_en),                  // input wire ena
      .wea(ram_wea),                  // input wire [3 : 0] wea
      .addra(ram_addr),                 // input wire [31 : 0] addra
      .dina(ram_wdata),                 // input wire [31 : 0] dina
      .douta(ram_rdata)                 // output wire [31 : 0] douta
    );
    
    pico_rom_2 pico_rom(
      .clka(clk_sc),                    // input wire clka
      .ena(rom_en),                  // input wire ena
      .addra(rom_addr),                 // input wire [31 : 0] addra
      .douta(rom_rdata)                 // output wire [31 : 0] douta
    );


    mmi_top mmi_top(
        .clk(clk_sc),
        .rst(reset),


    .mmi_valid(mmi_valid),
    .mmi_ready(mmi_ready),
    .mmi_wstrb(mmi_wstrb),
    .i_mmi_wdata(i_mmi_wdata),
    .o_mmi_rdata(o_mmi_rdata), 
    .i_mmi_addr(i_mmi_addr),     


    .COPCRCSTAT_i(COPCRCSTAT_i),
    .COPCRCO1_i(COPCRCO1_i), 
    .COPCRCO2_i(COPCRCO2_i),
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
    .COPWRLN_o(COPWRLN_o),

    .i_data(i_data),
    .i_statusout(i_statusout),
    .i_statusout2(i_statusout2),
    
    .o_data(o_data),
    .o_command(o_command),
    .o_addr_th(o_addr_th),
    .o_addr_src(o_addr_src),
    .o_addr_dest(o_addr_dest) 
    );
    
        ISO14443_wrapper ISO14443_wrapper(
        .clk(clk_sc),
        .reset(reset),
        .o_COPCRCSTAT(COPCRCSTAT_i),
        .o_COPCRCO_1(COPCRCO1_i),
        .o_COPCRCO_2(COPCRCO2_i),
        .o_COPRDSTAT(COPRDSTAT_i),
        .o_COPRD(COPRD_i),
        .o_COPRDLN(COPRDLN_i),
        .o_COPWRSTAT(COPWRSTAT_i),
        .i_COPCRCEN(COPCRCEN_o),
        .i_COPCRCINIT_1(COPCRCINIT1_o),
        .i_COPCRCINIT_2(COPCRCINIT2_o),
        .i_COPCRCI_1(COPCRCI1_o),
        .i_COPCRCI_2(COPCRCI2_o),
        .i_COPRDEN(COPRDEN_o),
        .i_COPWR(COPWR_o),
        .i_COPWREN(COPWREN_o),
        .i_COPWRLN(COPWRLN_o),
        .serial_out(serial_out)
    );
    
    top_coprocessor_control top_coprocessor_control(
        .clk(clk_sc),
        .reset(reset),
        .DataIn(o_data),
        .CommandIn(o_command),
        .AdThIn(o_addr_th),
        .AdSrcIn(o_addr_src),
        .AdDestIn(o_addr_dest),
        .DataOut(i_data),
        .StatusOut(i_statusout),
        .StatusOut2(i_statusout2)
    );
    
endmodule
