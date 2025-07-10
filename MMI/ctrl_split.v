module ctrl_split (
    input [3:0] wen,
    input valid,
    input [31:0] i_data
    input [31:0] addr,
    output [7:0] o_data,
    output [7:0] o_command,
    output [7:0] o_addr_th,
    output [7:0] o_addr_src,
    output [7:0] o_addr_dest,
);

    always @(*) begin
        if (addr == 32'h00_00_00_14) begin
            if (wen[0])
                o_data = i_data[7:0];
            else if (wen[1])
                o_data = i_data[15:8];
            else if (wen[2])
                o_data = i_data[23:16];
            else if (wen[3])
                o_data = i_data[31:24];
            else
        end    
        else if(addr == 32'h00_00_00_15) begin
            if (wen[0])
                o_command = i_data[7:0];
            else if (wen[1])
                o_command = i_data[15:8];
            else if (wen[2])
                o_command = i_data[23:16];
            else if (wen[3])
                o_command = i_data[31:24];
        end
        else if (addr == 32'h00_00_00_16) begin
            o_addr_th = i_data[15:0];
            o_addr_src = i_data[31:16];
        end
        else if(addr == 32'h00_00_00_17)
            o_addr_th = i_data[15:0];
        else
    end
    
endmodule