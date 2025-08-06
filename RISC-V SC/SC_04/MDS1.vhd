----------------------------------------------------
-- Disain : Kriptografi BC3
-- Entity : MDS
-- Fungsi : perkalian MDS
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity MDS is port(
 	mds_in  : in std_logic_vector(31 downto 0);
	mds_out : out std_logic_vector(31 downto 0));
end entity;

architecture dataflow of MDS is
component tristbuf_8 port (
      X8  : in std_logic_vector(7 downto 0);
		En8 : in std_logic;
     	F8  : out std_logic_vector(7 downto 0));
end component;

component shiftl_8 port(
	in8  : in std_logic_vector(7 downto 0);
	outs_c : buffer std_logic;
	outs : buffer std_logic_vector(7 downto 0));
end component;

signal mds_in1, mds_in2, mds_in3, mds_in4  : std_logic_vector(7 downto 0);
signal xor_all, xor_all1, xor_all2   : std_logic_vector(7 downto 0);
signal xor1_tmp1, xor1_tmp2, xor1_tmp3, xor1_tmp4  : std_logic_vector(7 downto 0);
signal xor2_tmp1, xor2_tmp2, xor2_tmp3, xor2_tmp4  : std_logic_vector(7 downto 0);
signal shift_tmp1, shift_tmp2, shift_tmp3, shift_tmp4  : std_logic_vector(7 downto 0);
signal sel_tmp1, sel_tmp2, sel_tmp3, sel_tmp4  : std_logic_vector(7 downto 0);
signal c1_mds, c2_mds, c3_mds, c4_mds   : std_logic;
signal no_c1_mds, no_c2_mds, no_c3_mds, no_c4_mds   : std_logic;
signal out_tmp1, out_tmp2, out_tmp3, out_tmp4 : std_logic_vector(7 downto 0);
signal b_hex   : std_logic_vector(7 downto 0) := "00011011";

--signal mds_in  : std_logic_vector(31 downto 0) := X"01234567";

begin

 	   mds_in1 <= mds_in (7  downto 0);
 	   mds_in2 <= mds_in (15 downto 8);
 	   mds_in3 <= mds_in (23 downto 16);
 	   mds_in4 <= mds_in (31 downto 24);

  	   xor_all1 <= mds_in1  xor mds_in2;
  	   xor_all2 <= mds_in3  xor mds_in4;
  	   xor_all  <= xor_all1 xor xor_all2;
 	   
 	   xor1_tmp1 <= mds_in1 xor mds_in4;
 	   xor1_tmp2 <= mds_in1 xor mds_in2;
 	   xor1_tmp3 <= mds_in2 xor mds_in3;
 	   xor1_tmp4 <= mds_in3 xor mds_in4;
 	   
 	   shift1 : shiftL_8 port map (xor1_tmp1, c1_mds, shift_tmp1);  
 	   shift2 : shiftL_8 port map (xor1_tmp2, c2_mds, shift_tmp2);  
 	   shift3 : shiftL_8 port map (xor1_tmp3, c3_mds, shift_tmp3);  
 	   shift4 : shiftL_8 port map (xor1_tmp4, c4_mds, shift_tmp4);  
 
  	   xor2_tmp1 <= shift_tmp1 xor b_hex;
 	   xor2_tmp2 <= shift_tmp2 xor b_hex;
 	   xor2_tmp3 <= shift_tmp3 xor b_hex;
 	   xor2_tmp4 <= shift_tmp4 xor b_hex;
 	   
 	   no_c1_mds <= not c1_mds;
 	   no_c2_mds <= not c2_mds;
 	   no_c3_mds <= not c3_mds;
 	   no_c4_mds <= not c4_mds;
 	   
	   sel1a : tristbuf_8 port map (xor2_tmp1, c1_mds, sel_tmp1);  
 	   sel1b : tristbuf_8 port map (shift_tmp1, no_c1_mds, sel_tmp1); 
	   sel2a : tristbuf_8 port map (xor2_tmp2, c2_mds, sel_tmp2);  
 	   sel2b : tristbuf_8 port map (shift_tmp2, no_c2_mds, sel_tmp2); 
	   sel3a : tristbuf_8 port map (xor2_tmp3, c3_mds, sel_tmp3);  
 	   sel3b : tristbuf_8 port map (shift_tmp3, no_c3_mds, sel_tmp3); 
	   sel4a : tristbuf_8 port map (xor2_tmp4, c4_mds, sel_tmp4);  
 	   sel4b : tristbuf_8 port map (shift_tmp4, no_c4_mds, sel_tmp4); 
 	    
 	   
  	   out_tmp1 <= sel_tmp1 xor xor_all xor mds_in1;
 	   out_tmp2 <= sel_tmp2 xor xor_all xor mds_in2;
 	   out_tmp3 <= sel_tmp3 xor xor_all xor mds_in3;
 	   out_tmp4 <= sel_tmp4 xor xor_all xor mds_in4;
 	   
  	   mds_out(7  downto 0) <= out_tmp1;
 	   mds_out(15 downto 8) <= out_tmp2;
 	   mds_out(23 downto 16) <= out_tmp3;
 	   mds_out(31 downto 24) <= out_tmp4;
 	      
 	   
 end dataflow;

