----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.06.2025 17:04:32
-- Design Name: 
-- Module Name: csa_11bit - Behavioral
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

entity csa_11bit is
  port (
    A     : in  STD_LOGIC_VECTOR(10 downto 0);
    B     : in  STD_LOGIC_VECTOR(10 downto 0);
    C     : in  STD_LOGIC_VECTOR(10 downto 0);
    Sum   : out STD_LOGIC_VECTOR(10 downto 0);
    Carry : out STD_LOGIC_VECTOR(10 downto 0)
  );
end csa_11bit;

architecture behavioral of csa_11bit is
  -- sinyal internal untuk hasil reduksi level pertama
  signal S1 : STD_LOGIC_VECTOR(10 downto 0);
  signal C1 : STD_LOGIC_VECTOR(10 downto 0);
begin
  -- proses kombinatorial: hitung sum & carry per bit
  CSA_GEN: for i in 0 to 10 generate
  begin
    -- sum sementara: XOR 3-input
    S1(i) <= A(i) xor B(i) xor C(i);
    -- carry sementara: majority dari tiga input
    C1(i) <= (A(i) and B(i))
           or (B(i) and C(i))
           or (A(i) and C(i));
  end generate CSA_GEN;

    -- assign ke output
    Sum   <= S1;
    Carry <= C1;
end architecture;
