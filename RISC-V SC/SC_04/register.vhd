----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : reg_32
-- Fungsi       : register 32 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reg_32 is port (
      reset, en, clk : in std_logic;
      reg_in : in std_logic_vector(31 downto 0);	
     	reg_out : out std_logic_vector(31 downto 0));
end entity;

architecture rtl of reg_32 is
begin 
    process (reset, clk, en) 
      begin 
        if reset = '0' then
           reg_out <= (others => '0');  
           else if en = '1' then
             if (clk'event and Clk ='0') then 
                reg_out <= reg_in; 
             end if; 
           end if;
       end if;
    end process; 
end rtl;

