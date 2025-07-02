----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 13:12:13
-- Design Name: 
-- Module Name: rca_16bit - Behavioral
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

entity rca_16bit is
    Port (
        a : in STD_LOGIC_VECTOR(15 downto 0);
        b : in STD_LOGIC_VECTOR(15 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(15 downto 0);
        cout : out STD_LOGIC
    );
end rca_16bit;

architecture Behavioral of rca_16bit is
    signal carry : STD_LOGIC_VECTOR(16 downto 0);
begin
    carry(0) <= cin;
    
    -- Ripple Carry Adder 16bit
    gen: for i in 0 to 15 generate
        sum(i) <= a(i) xor b(i) xor carry(i);
        carry(i+1) <= (a(i) and b(i)) or (a(i) and carry(i)) or (b(i) and carry(i));
    end generate;

    cout <= carry(16);
end Behavioral;


