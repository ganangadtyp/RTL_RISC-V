----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.06.2025 18:19:41
-- Design Name: 
-- Module Name: inc1_4 - Behavioral
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

entity inc1_4 is
  port(
    a   : in  std_logic;                     -- carry-in
    b   : in  std_logic_vector(3 downto 0);  -- operand 4-bit
    sum : out std_logic_vector(3 downto 0);  -- hasil b + a
    cout: out std_logic                      -- carry-out
  );
end entity;

architecture rtl of inc1_4 is
  signal carry: std_logic_vector(4 downto 0);
begin
  carry(0) <= a;  -- carry-in adalah input a

  rippler: for i in 0 to 3 generate
  begin
    sum(i)   <= b(i) xor carry(i);          -- sum = bit ^ carry
    carry(i+1) <= b(i) and carry(i);        -- carry ke bit berikutnya
  end generate rippler;

  cout <= carry(4);
end architecture;


