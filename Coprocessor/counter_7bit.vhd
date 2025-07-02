----------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 01.01.2025 09:36:57
-- Design Name: 
-- Module Name: Counter_12bit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_7bit is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        en    : in  std_logic;
        Q     : out std_logic_vector(6 downto 0)
    );
end counter_7bit;

architecture Behavioral of counter_7bit is
    -- Menggunakan tipe unsigned untuk memudahkan operasi aritmetika
    signal counter : unsigned(6 downto 0) := (others => '0');
begin
    process(clk, reset, en)
    begin
       if reset = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                counter <= counter + 1;      -- Increment counter jika en aktif
            else
                counter <= counter;          -- Mempertahankan nilai counter
            end if;
        end if;
    end process;
    
    -- Konversi sinyal counter ke std_logic_vector untuk output
    Q <= std_logic_vector(counter);
end Behavioral;
