----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.02.2025 14:51:55
-- Design Name: 
-- Module Name: Parity_Calculator - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Parity_Calculator is
  Port ( 
    data_in : in std_logic_vector(7 downto 0);      -- data masuk
    data_out    : out std_logic_vector(8 downto 0)  -- data keluar
  );
end Parity_Calculator;

architecture Behavioral of Parity_Calculator is
    signal s_parity : std_logic;
begin
    -- perhitungan odd parity
    s_parity <= data_in(7) xor data_in(6) xor data_in(5) xor data_in(4) xor
                data_in(3) xor data_in(2) xor data_in(1) xor data_in(0) xor '1'; 
    data_out <= s_parity & data_in; -- concate parity ke dalam frame data

end Behavioral;
