----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.06.2025 17:56:51
-- Design Name: 
-- Module Name: rca_11bit - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rca_11bit is
    Port (
        a : in STD_LOGIC_VECTOR(10 downto 0);
        b : in STD_LOGIC_VECTOR(10 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(10 downto 0);
        cout : out STD_LOGIC
    );
end rca_11bit;

architecture Behavioral of rca_11bit is
    signal carry : STD_LOGIC_VECTOR(11 downto 0);
begin
    carry(0) <= cin;
    
    -- Ripple Carry Adder 11bit
    gen: for i in 0 to 10 generate
        sum(i) <= a(i) xor b(i) xor carry(i);
        carry(i+1) <= (a(i) and b(i)) or (a(i) and carry(i)) or (b(i) and carry(i));
    end generate;

    cout <= carry(11);
end Behavioral;
