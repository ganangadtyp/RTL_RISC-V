module wr_cp (
    input [7:0] i_data,
    input [7:0] i_Status1,
    input [7:0] i_Status2,
    output [7:0] o_data,
    output flag
);
    // always @(*) begin
    //     if (i_Status1 & i_Status2) begin
    //         o_data = i_data;
    //         flag = 1'b1;
    //     end else
    //         flag = 1'b0;
    // end


endmodule