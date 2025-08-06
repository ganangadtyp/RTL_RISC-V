----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : Tristbuf_32
-- Fungsi       : tristate buffer 32 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tristbuf is port (
      X  : in std_logic_vector(31 downto 0);
		En : in std_logic;
     	F  : out std_logic_vector(31 downto 0));
end tristbuf;

architecture rtl of tristbuf is
begin 
    F <= (others => 'Z') when En = '0' else X;
end rtl;

