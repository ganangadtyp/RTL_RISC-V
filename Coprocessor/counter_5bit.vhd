----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2025 14:17:29
-- Design Name: 
-- Module Name: counter_5bit - Behavioral
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

entity counter_5bit is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        en    : in  std_logic;
        Q     : out std_logic_vector(4 downto 0)
    );
end entity;

architecture Behavioral of counter_5bit is
    signal cnt_int : unsigned(4 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            cnt_int <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                cnt_int <= cnt_int + 1;
            end if;
        end if;
    end process;

    Q <= std_logic_vector(cnt_int);
end architecture;
