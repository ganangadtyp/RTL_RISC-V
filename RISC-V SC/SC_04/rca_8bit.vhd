----------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 07.05.2025 13:08:02
-- Design Name: 
-- Module Name: rca_8bit - Behavioral
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

entity rca_8bit is
    Port (
        a : in STD_LOGIC_VECTOR(7 downto 0);
        b : in STD_LOGIC_VECTOR(7 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(7 downto 0);
        cout : out STD_LOGIC
    );
end rca_8bit;

architecture Behavioral of rca_8bit is
    signal carry : STD_LOGIC_VECTOR(8 downto 0);
begin
    carry(0) <= cin;
    
    -- Ripple Carry Adder 8bit
    gen: for i in 0 to 7 generate
        sum(i) <= a(i) xor b(i) xor carry(i);
        carry(i+1) <= (a(i) and b(i)) or (a(i) and carry(i)) or (b(i) and carry(i));
    end generate;

    cout <= carry(8);
end Behavioral;
