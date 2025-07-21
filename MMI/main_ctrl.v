module main_ctrl (
    input i_mem_valid,
    input [3:0] i_mem_strb,
    input flag,
    input wr_ack,
    output mem_ready,
    output [3:0] wen
);
    //assign wr_ack =  cp_valid & cp_ready | comm_valid & comm_ready; 

    // always @(*) begin
    //     wen = (i_mem_valid & !mem_ready) ? i_mem_wstrb : 4'b0000;
    // end

    

endmodule