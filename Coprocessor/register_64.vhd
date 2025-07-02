----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : reg_64
-- Fungsi       : register 64 bit
-- dibuat oleh  : Hidayat
-- modifikasi oleh   : Ganang Aditya Pratama
-- Tanggal modifikasi : 16-05-2025
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reg_64 is port (
      reset, en, clk : in std_logic;
      reg64_in : in std_logic_vector(63 downto 0);	
      reg64_out : out std_logic_vector(63 downto 0));
end entity;

architecture rtl of reg_64 is
--   signal reg64_in :  std_logic_vector(63 downto 0) := X"0123456789ABCDEF";
    signal r_reg64_out : std_logic_vector(63 downto 0);
begin 
--    process (reset, en, clk) 
--      begin 
--        if reset = '0' then
--           reg64_out <= (others => '0');  
--        else if en = '1' then
--            if (clk'event and Clk ='0') then 
--                reg64_out <= reg64_in; 
--            end if; 
--        end if;
--        end if;   
--    end process;

-- MODIFIKASI
--memodifikasi sensitivity list hanya clk dan reset. 
--Mengubah 
--else if en = '1' then
--            if (clk'event and Clk ='0') then 
--Menjadi 
--elsif rising_edge(clk) then
--          if en = '1' then

    process(clk, reset)
    begin
    -- Asynchronous, active-low reset
        if reset = '0' then
          r_reg64_out <= (others => '0');
          
        -- Synchronous on rising edge
        elsif rising_edge(clk) then
          if en = '1' then
            r_reg64_out <= reg64_in;
          else
             r_reg64_out <= r_reg64_out;
          end if;
        end if;
  end process; 
  reg64_out <= r_reg64_out;
end rtl;

