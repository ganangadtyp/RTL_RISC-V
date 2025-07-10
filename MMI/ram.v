module ram (
    // input router
    input [31:0]    i_mem_addr,
    input [31:0]    i_mem_wdata,
    input           i_valid,
    input [3:0]     wen_router,
    input           r_valid,

    // input cp
    input [7:0]     i_cp_wdata,
    input [31:0]    i_cp_addr,
    input           i_cp_valid,
    input           r_cp_valid,
    input [3:0]     wen_cp,

    // input com
    input [7:0]     i_com_wdata,
    input [31:0]    i_com_addr,
    input           i_com_valid,
    input           r_com_valid,
    input [3:0]     wen_com,

    // output
    output [31:0] o_mem_rdata
    output [2:0] o_valid
);
    reg [31:0] ram [0:31];
    reg [31:0] ram_wdata, ram_addr;
    reg [3:0]  ram_wen;

    always @(posedge clk) begin

        // write
        case ({i_valid, i_cp_valid, i_com_valid})
            3'b100 :    // dari router
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            3'b010 :    // dari cp
                begin 
                    ram_wdata   <= i_cp_wdata; 
                    ram_addr    <= i_cp_addr;
                    ram_wen     <= wen_cp;
                end
            3'b001 :    // dari comm
                begin 
                    ram_wdata   <= i_com_wdata; 
                    ram_addr    <= i_com_addr;
                    ram_wen     <= wen_com;
                end
            3'b110 :    // konflik  router & cp
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            3'b101 :    // konflik  router & com
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            3'b011 :    // konflik  cp & com
                begin 
                    ram_wdata   <= i_cp_wdata; 
                    ram_addr    <= i_cp_addr;
                    ram_wen     <= wen_cp;
                end
            3'b111 :    // konflik  router & cp & com 
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            default: ram_wdata   <= 0;
        endcase

        if (!{i_valid, i_cp_valid, i_com_valid}) begin
            if (ram_wen[0]) ram[ram_addr][7:0]    <= ram_wdata;
            if (ram_wen[1]) ram[ram_addr][15:8]   <= ram_wdata;
            if (ram_wen[2]) ram[ram_addr][23:16]  <= ram_wdata;
            if (ram_wen[3]) ram[ram_addr][31:24]  <= ram_wdata;
        end

        // read
        case ({r_valid, r_cp_valid, r_com_valid})
            3'b100 :    // dari router
                begin 
                    o_mem_rdata <= ram[i_mem_addr];
                    o_valid     <= 3'b100;
                end
            3'b010 :    // dari cp
                begin 
                    o_mem_rdata <= ram[i_cp_addr];
                    o_valid     <= 3'b10;
                end
            3'b001 :    // dari comm
                begin 
                    o_mem_rdata <= ram[i_com_addr];
                    o_valid     <= 3'b001;
                end
            3'b110 :    // konflik  router & cp
                begin 
                    if (i_mem_addr == i_cp_addr)
                    begin
                        o_mem_rdata <= ram[i_mem_addr];
                        o_valid     <= 3'b110;
                    end
                    else begin
                        o_mem_rdata <= ram[i_mem_addr];
                        o_valid     <= 3'b100;
                    end
                end
            3'b101 :    // konflik  router & com
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            3'b011 :    // konflik  cp & com
                begin 
                    ram_wdata   <= i_cp_wdata; 
                    ram_addr    <= i_cp_addr;
                    ram_wen     <= wen_cp;
                end
            3'b111 :    // konflik  router & cp & com 
                begin 
                    ram_wdata   <= i_mem_wdata; 
                    ram_addr    <= i_mem_addr;
                    ram_wen     <= wen_router;
                end
            default: ram_wdata   <= 0;
        endcase


    end
endmodule


    // always @(posedge clk) begin
    //     if ({i_valid, i_cp_valid, i_com_valid} == 3'b100) begin
    //         if (wen[0]) ram[i_mem_addr][7:0] <= i_mem_wdata;
    //         if (wen[1]) ram[i_mem_addr][15:8] <= i_mem_wdata;
    //         if (wen[2]) ram[i_mem_addr][23:16] <= i_mem_wdata;
    //         if (wen[3]) ram[i_mem_addr][31:24] <= i_mem_wdata;
    //     end

    //     o_mem_rdata <= ram[i_mem_addr];
    // end

    
        // if ({i_valid, i_cp_valid, i_com_valid} == 3'b100) begin
        //     if (wen_router[0]) ram[i_mem_addr][7:0]    <= i_mem_wdata;
        //     if (wen_router[1]) ram[i_mem_addr][15:8]   <= i_mem_wdata;
        //     if (wen_router[2]) ram[i_mem_addr][23:16]  <= i_mem_wdata;
        //     if (wen_router[3]) ram[i_mem_addr][31:24]  <= i_mem_wdata;
        // end
        // else if ({i_valid, i_cp_valid, i_com_valid} == 3'b010) begin
        //     if (wen_cp[0]) ram[i_cp_addr][7:0]     <= i_cp_wdata;
        //     if (wen_cp[1]) ram[i_cp_addr][15:8]    <= i_cp_wdata;
        //     if (wen_cp[2]) ram[i_cp_addr][23:16]   <= i_cp_wdata;
        //     if (wen_cp[3]) ram[i_cp_addr][31:24]   <= i_cp_wdata;
        // end
        // else if ({i_valid, i_cp_valid, i_com_valid} == 3'b001) begin
        //     if (wen_com[0]) ram[i_com_addr][7:0]    <= i_com_wdata;
        //     if (wen_com[1]) ram[i_com_addr][15:8]   <= i_com_wdata;
        //     if (wen_com[2]) ram[i_com_addr][23:16]  <= i_com_wdata;
        //     if (wen_com[3]) ram[i_com_addr][31:24]  <= i_com_wdata;
        // end
        
        // if ({r_valid, r_cp_valid, r_com_valid} == 3'b100) begin
        //     o_mem_rdata <= ram[i_mem_addr];
        //     o_valid     <= 3'b100;
        // end
        // else if ({r_valid, r_cp_valid, r_com_valid} == 3'b010) begin
        //     o_mem_rdata <= ram[i_cp_addr];
        //     o_valid     <= 3'b010;
        // end
        // else if ({r_valid, r_cp_valid, r_com_valid} == 3'b001) begin
        //     o_mem_rdata <= ram[i_com_addr];
        //     o_valid     <= 3'b001;
        // end