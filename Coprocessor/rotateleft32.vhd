----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : rotl_32
-- Fungsi       : rotasi kiri 1 bit pada data 32 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rotl_32 is port(
	in32  : in std_logic_vector(31 downto 0);
	outs : out std_logic_vector(31 downto 0));
end entity;

architecture dataflow of rotl_32 is

begin
 	outs(31)  <= in32(30);
 	outs(30)  <= in32(29);
 	outs(29)  <= in32(28);
 	outs(28)  <= in32(27);
 	outs(27)  <= in32(26);
 	outs(26)  <= in32(25);
 	outs(25)  <= in32(24);
 	outs(24)  <= in32(23);
 	outs(23)  <= in32(22);
 	outs(22)  <= in32(21);
 	outs(21)  <= in32(20);

 	outs(20)  <= in32(19);
 	outs(19)  <= in32(18);
 	outs(18)  <= in32(17);
 	outs(17)  <= in32(16);
 	outs(16)  <= in32(15);
 	outs(15)  <= in32(14);
 	outs(14)  <= in32(13);
 	outs(13)  <= in32(12);
 	outs(12)  <= in32(11);
 	outs(11)  <= in32(10);

 	outs(10)  <= in32(9);
 	outs(9)  <= in32(8);
 	outs(8)  <= in32(7);
 	outs(7)  <= in32(6);
 	outs(6)  <= in32(5);
 	outs(5)  <= in32(4);
 	outs(4)  <= in32(3);
 	outs(3)  <= in32(2);
 	outs(2)  <= in32(1);
 	outs(1)  <= in32(0);
 	outs(0)  <= in32(31);
end dataflow;

