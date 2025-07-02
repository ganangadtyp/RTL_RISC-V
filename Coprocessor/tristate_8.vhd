----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : Tristbuf_8
-- Fungsi       : tristate buffer 8 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tristbuf_8 is port (
      X8  : in std_logic_vector(7 downto 0);
		En8 : in std_logic;
     	F8  : out std_logic_vector(7 downto 0));
end entity;

architecture rtl of tristbuf_8 is
begin 
    F8 <= (others => 'Z') when En8 = '0' else X8;
end rtl;

