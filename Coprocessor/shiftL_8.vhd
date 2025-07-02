----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : shiftl_8
-- Fungsi       : pergeseran 1 bit ke kiri pada data 8 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity shiftl_8 is port(
	in8  : in std_logic_vector(7 downto 0);
	outs_c : buffer std_logic;
	outs : buffer std_logic_vector(7 downto 0));
end entity;

architecture dataflow of shiftl_8 is
begin
 	outs_c   <= in8(7);
 	outs(7)  <= in8(6);
 	outs(6)  <= in8(5);
 	outs(5)  <= in8(4);
 	outs(4)  <= in8(3);
 	outs(3)  <= in8(2);
 	outs(2)  <= in8(1);
 	outs(1)  <= in8(0);
 	outs(0)  <= '0';
end dataflow;

