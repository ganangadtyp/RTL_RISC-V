`timescale 1ns / 1ps

module mmi_to_copcom (
    // i/o between MMI
    input   [31:0]  data_router,
    input   [31:0]  data_from_reader,
    input   [31:0]  read_address,
    output  [31:0]  write_address,
    output  [31:0]  data_out

    // i/o to COPCOM
    output  [7:0]   COPCRCEN_o, COPCRCINIT1_o, COPCRCINIT2_o, COPCRCI1_o, COPCRCI2_o;
    output  [7:0]   COPRDEN_o, COPWR_o, COPWREN_o, COPWRLN_o;
    input   [7:0]   COPRDSTAT, COPRD, COPRDLN, COPWRSTAT;
    input   [7:0]   COPCRCO1, COPCRCO2, COPCRCSTAT;
);

// To COPCOM
localparam  COPCRCEN        = 32'hF0_00_00_00,
            COPCRCINIT1     = 32'hF0_00_00_01,
            COPCRCINIT2     = 32'hF0_00_00_02,
            COPCRCI1        = 32'hF0_00_00_03,
            COPCRCI2        = 32'hF0_00_00_04,

            COPWR           = 32'hF0_00_00_05,
            COPWREN         = 32'hF0_00_00_06,
            COPWRLN         = 32'hF0_00_00_07,

            COPRDEN         = 32'hF0_00_00_08;

// From COPCOM
localparam  COPCRCSTAT      = 32'hF1_00_00_00,
            COPCRCO1        = 32'hF1_00_00_01,
            COPCRCO2        = 32'hF1_00_00_02,

            COPWRSTAT       = 32'hF1_00_00_03,

            COPRD           = 32'hF1_00_00_04,
            COPRDSTAT       = 32'hF1_00_00_05,
            COPRDLN         = 32'hF1_00_00_06;

always @(*)
begin
    CASE (read_address)

        // Select output data to comm
        COPCRCEN    : COPCRCEN_o    <=  data_from_reader; 
        COPCRCINIT1 : COPCRCINIT1_o <=  data_from_reader; 
        COPCRCINIT2 : COPCRCINIT2_o <=  data_from_reader; 
        COPCRCI1    : COPCRCI1_o    <=  data_from_reader; 
        COPCRCI2    : COPCRCI2_o    <=  data_from_reader; 
        COPWR       : COPWR_o       <=  data_from_reader; 
        COPWREN     : COPWREN_o     <=  data_from_reader; 
        COPWRLN     : COPWRLN_o     <=  data_from_reader; 
        COPRDEN     : COPRDEN_o     <=  data_from_reader; 
        
        // Select output data to Pico
        COPCRCSTAT  : data_out  <= COPCRCSTAT;
        COPCRCO1    : data_out  <= COPCRCO1;
        COPCRCO2    : data_out  <= COPCRCO2;
        COPWRSTAT   : data_out  <= COPWRSTAT;
        COPRD       : data_out  <= COPRD;
        COPRDSTAT   : data_out  <= COPRDSTAT;
        COPRDLN     : data_out  <= COPRDLN;

        default     : data_out  <= 0;
    endcase     

    // meneruskan data address untuk store jika base address sesuai
    if (read_address[31:25])
        write_address  <= read_address;
   
end

endmodule