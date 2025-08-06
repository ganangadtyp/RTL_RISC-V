----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 13:59:11
-- Design Name: 
-- Module Name: pp_generator8 - Behavioral
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

entity pp_generator8 is
    port (
        i_A  : in  std_logic_vector(7 downto 0);
        i_B  : in  std_logic_vector(7 downto 0);
        o_C0 : out std_logic_vector(7 downto 0);
        o_C1 : out std_logic_vector(7 downto 0);
        o_C2 : out std_logic_vector(7 downto 0);
        o_C3 : out std_logic_vector(7 downto 0);
        o_C4 : out std_logic_vector(7 downto 0);
        o_C5 : out std_logic_vector(7 downto 0);
        o_C6 : out std_logic_vector(7 downto 0);
        o_C7 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of pp_generator8 is
    signal s_B0, s_B1, s_B2, s_B3, s_B4, s_B5, s_B6, s_B7      : std_logic_vector(7 downto 0);
begin
    s_B0 <= (others => i_B(0));
    s_B1 <= (others => i_B(1));
    s_B2 <= (others => i_B(2));
    s_B3 <= (others => i_B(3));
    s_B4 <= (others => i_B(4));
    s_B5 <= (others => i_B(5));
    s_B6 <= (others => i_B(6));
    s_B7 <= (others => i_B(7));
    -- partial products: each bit of A AND dengan satu bit B
    o_C0 <= i_A and s_B0;
    o_C1 <= i_A and s_B1;
    o_C2 <= i_A and s_B2;
    o_C3 <= i_A and s_B3;
    o_C4 <= i_A and s_B4;
    o_C5 <= i_A and s_B5;
    o_C6 <= i_A and s_B6;
    o_C7 <= i_A and s_B7;
end architecture;
