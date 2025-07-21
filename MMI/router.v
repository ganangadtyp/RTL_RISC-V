`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 08:14:53
// Design Name: 
// Module Name: router
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


module router(
    input [31:0] i_mem_addr,
    input [31:0] i_mem_wdata,
    output [2:0] valid_route,
    output [31:0] o_mem_addr,
    output [31:0] o_mem_wdata_ram,
    output [31:0] o_mem_wdata_cp,
    output [31:0] o_mem_wdata_comm
    );
    
    // harus definisikan alokasinya
    always @(*) begin
        if (i_mem_addr <= 32'h00_00_00_03 && i_mem_addr >= 32'h00_00_00_00)
            o_mem_wdata_ram <= i_mem_wdata;
            valid_route <= 4'b100;
        else if (i_mem_addr <= 32'h00_00_00_17 && i_mem_addr >= 32'h00_00_00_14)
            o_mem_wdata_cp <= i_mem_wdata;
            valid_route <= 4'b010;
        else if (i_mem_addr <= 32'h00_00_00_1B && i_mem_addr >= 32'h00_00_00_18)
            o_mem_wdata_comm <= i_mem_wdata;
            valid_route<= 4'b001;     
    end

    assign o_mem_addr <= i_mem_addr;
endmodule
