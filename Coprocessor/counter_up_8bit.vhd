----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2024 16:54:57
-- Design Name: 
-- Module Name: counter_up_8bit - Behavioral
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity counter_up_8bit is
    port (
        clk    : in std_logic;              -- Sinyal clock
        start  : in std_logic;              -- Sinyal start untuk memulai counter
        reset  : in std_logic;              -- Sinyal reset untuk mereset counter
        
        count  : out std_logic_vector(7 downto 0)  -- Keluaran 8-bit counter
    );
end counter_up_8bit;

architecture Behavioral of counter_up_8bit is
    signal counter : std_logic_vector(7 downto 0) := (others => '0');  -- Internal signal untuk counter 8-bit
    signal enable_counter : std_logic := '0';  -- Sinyal internal untuk mengontrol counter
    
begin

    -- Proses untuk menghitung counter
    process(clk)
    begin
        if rising_edge(clk) then
            -- Cek jika reset aktif, set counter ke 0
            if reset = '1' then
                counter <= (others => '0');  -- Reset counter ke 0
            -- Jika start aktif, mulai counting
            elsif start = '1' then
                if counter = x"FF" then  -- Jika counter mencapai 255 (8-bit max)
                    counter <= (others => '0');  -- Reset counter ke 0
                else
                    counter <= counter + 1;  -- Tambah nilai counter setiap clock cycle
                end if;
            end if;
        end if;
    end process;

    -- Assign internal counter ke keluaran
    count <= counter;

end Behavioral;
