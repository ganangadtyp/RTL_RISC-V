module bus_interface (
    input clk, reset,
    
    //CPU
    input mem_valid,
    input mem_instr,
    input [31:0] mem_addr,
    input [3:0] mem_wstrb,
    input [31:0] mem_wdata,
    output mem_ready,
    output [31:0] mem_rdata,

    //MMI
    output mmi_valid,
    output [2:0] mmi_addr,
    output [3:0] mmi_wstrb,
    input mmi_ready,
    output [31:0] mmi_wdata,
    input [31:0] mmi_rdata,

    //RAM
    output ram_en,
    output [3:0] ram_wea,
    output [13:0] ram_addr,
    output [31:0] ram_wdata,
    input [31:0] ram_rdata,

    //ROM
    output [13:0] rom_addr,
    input [31:0] rom_rdata,
    output rom_en
);

reg ram_ready, rom_ready;

//CPU
assign mem_ready = mmi_ready || rom_ready || ram_ready;
assign mem_rdata = rom_ready ? rom_rdata : ram_ready ? ram_rdata : mmi_ready? mmi_rdata : 32'd0;

//MMI
assign mmi_valid = (mem_valid && (!mem_instr) && mem_addr[19:16] == 4'h2)? 1'd1 : 1'd0;
assign mmi_addr = mem_addr[2:0];
assign mmi_wstrb = mem_wstrb;
assign mmi_wdata = mem_wdata;

//RAM
assign ram_en = (mem_valid && (!mem_instr) && mem_addr[19:16] < 4'h1)? 1'd1 : 1'd0;
assign ram_wea = mem_wstrb;
assign ram_addr = mem_addr[15:2];
assign ram_wdata = mem_wdata;

//Control RAM dan ROM
always @(posedge clk) begin
    if (!reset) begin
        ram_ready <= mem_valid && (!mem_ready) && (mem_addr[19:16] < 4'h1);
        rom_ready <= mem_valid && (!mem_ready) && (mem_addr[19:16] == 4'h1); 
    end
    else begin
        ram_ready <= 1'd0;
        rom_ready <= 1'd0;
    end
end

//ROM
assign rom_en = (mem_valid && mem_instr && mem_addr[19:16] == 4'h1)? 1'd1 : 1'd0;
assign rom_addr = mem_addr[15:2];
    
endmodule