----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.06.2025 18:29:30
-- Design Name: 
-- Module Name: rca_7bit - Behavioral
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

entity rca_7bit is
    Port (
        a    : in  STD_LOGIC_VECTOR(6 downto 0);
        b    : in  STD_LOGIC_VECTOR(6 downto 0);
        cin  : in  STD_LOGIC;
        sum  : out STD_LOGIC_VECTOR(6 downto 0);
        cout : out STD_LOGIC
    );
end entity rca_7bit;

architecture Behavioral of rca_7bit is
    signal carry : STD_LOGIC_VECTOR(7 downto 0);
begin
    -- Inisialisasi carry-in
    carry(0) <= cin;
    
    -- Ripple Carry Adder 7-bit
    gen: for i in 0 to 6 generate
        sum(i) <= a(i) xor b(i) xor carry(i);
        carry(i+1) <= (a(i) and b(i))
                    or (a(i) and carry(i))
                    or (b(i) and carry(i));
    end generate;

    -- Carry-out terakhir
    cout <= carry(7);
end architecture Behavioral;

