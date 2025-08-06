----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : Tristbuf_64
-- Fungsi       : tristate buffer 64 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tristbuf_64 is port (
      X  : in std_logic_vector(63 downto 0);
		En : in std_logic;    
	-- sebagai sinyal kendali tristate
     	F  : out std_logic_vector(63 downto 0));
end entity;

architecture rtl of tristbuf_64 is
begin 
    F <= (others => 'Z') when En = '0' else X;
end rtl;


