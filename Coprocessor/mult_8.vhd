----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 14:05:54
-- Design Name: 
-- Module Name: mult8 - Behavioral
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

entity mult8 is
Port (
        i_a : in STD_LOGIC_VECTOR(7 downto 0);
        i_b : in STD_LOGIC_VECTOR(7 downto 0);
        o_p : out STD_LOGIC_VECTOR(15 downto 0)
    );
end mult8;

architecture Structural of mult8 is
    component adder_block is
    Port ( 
        i_c0      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c1      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c2      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c3      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c4      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c5      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c6      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c7      : in STD_LOGIC_VECTOR(7 downto 0);
        o_p       : out STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;
    
    component pp_generator8 is
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
    end component;
    
    signal s_A, s_B     : std_logic_vector(7 downto 0);
    signal s_C0, s_C1, s_C2, s_C3, s_C4, s_C5, s_C6, s_C7 
    : std_logic_vector(7 downto 0);
    signal s_p : std_logic_vector(15 downto 0);
begin

    u_adder_block : adder_block
        port map (
            i_C0 => s_C0,
            i_C1 => s_C1,
            i_C2 => s_C2,
            i_C3 => s_C3,
            i_C4 => s_C4,
            i_C5 => s_C5,
            i_C6 => s_C6,
            i_C7 => s_C7,
            o_p => s_p
        );
        
    u_partial_product : pp_generator8
        port map ( 
            i_A => s_A,
            i_B => s_B,
            o_C0 => s_C0,
            o_C1 => s_C1,
            o_C2 => s_C2,
            o_C3 => s_C3,
            o_C4 => s_C4,
            o_C5 => s_C5,
            o_C6 => s_C6,
            o_C7 => s_C7
        );
    s_A <= i_a;
    s_b <= i_b;
    o_p <= s_p;
end Structural;

