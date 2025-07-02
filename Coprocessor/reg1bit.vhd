----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2025 12:12:39
-- Design Name: 
-- Module Name: reg1bit - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

entity reg1bit is
  port (
    clk     : in  std_logic;  -- clock input
    reset   : in  std_logic;  -- asynchronous reset, aktif tinggi
    en      : in  std_logic;  -- enable load data
    clr     : in  std_logic;  -- synchronous clear ke nilai init
    init    : in  std_logic;  -- nilai awal lewat port
    d       : in  std_logic;  -- data input
    q       : out std_logic   -- data output
  );
end entity;

architecture behavioral of reg1bit is
  signal q_reg : std_logic := '0';
begin
  process(clk, reset)
  begin
    if reset = '1' then
      q_reg <= '0';
    elsif rising_edge(clk) then
      if en = '1' then
        if clr = '1' then
            q_reg <= init;
        else
            q_reg <= d; 
        end if;
      else
        q_reg <= q_reg;
      end if;
    end if;
  end process;
  q <= q_reg;

end behavioral;

