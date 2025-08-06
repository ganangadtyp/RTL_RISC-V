

-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity dual_mem is
  generic (ADDR_LENGTH : integer := 6;
           DATA_LENGTH : integer := 32;
           N_ADDR      : integer := 64);
  port (clk  : in std_logic;  
        we   : in std_logic;  
        a    : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        dpra : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        di   : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        spo  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        dpo  : out std_logic_vector(DATA_LENGTH - 1 downto 0));
end dual_mem;  

architecture rtl of dual_mem is
  type ram_type is array (N_ADDR - 1  downto 0) of std_logic_vector (DATA_LENGTH - 1 downto 0);
  signal RAM : ram_type := (0 => X"428a2f98",
							1 => X"71374491",
							2 => X"b5c0fbcf",
							3 => X"e9b5dba5",
							4 => X"3956c25b",
							5 => X"59f111f1",
							6 => X"923f82a4",
							7 => X"ab1c5ed5",
							8 => X"d807aa98",
							9 => X"12835b01",
							10 => X"243185be",
							11 => X"550c7dc3",
							12 => X"72be5d74",
							13 => X"80deb1fe",
							14 => X"9bdc06a7",
							15 => X"c19bf174",
							16 => X"e49b69c1",
							17 => X"efbe4786",
							18 => X"0fc19dc6",
							19 => X"240ca1cc",
							20 => X"2de92c6f",
							21 => X"4a7484aa",
							22 => X"5cb0a9dc",
							23 => X"76f988da",
							24 => X"983e5152",
							25 => X"a831c66d",
							26 => X"b00327c8",
							27 => X"bf597fc7",
							28 => X"c6e00bf3",
							29 => X"d5a79147",
							30 => X"06ca6351",
							31 => X"14292967",
							32 => X"27b70a85",
							33 => X"2e1b2138",
							34 => X"4d2c6dfc",
							35 => X"53380d13",
							36 => X"650a7354",
							37 => X"766a0abb",
							38 => X"81c2c92e",
							39 => X"92722c85",
							40 => X"a2bfe8a1",
							41 => X"a81a664b",
							42 => X"c24b8b70",
							43 => X"c76c51a3",
							44 => X"d192e819",
							45 => X"d6990624",
							46 => X"f40e3585",
							47 => X"106aa070",
							48 => X"19a4c116",
							49 => X"1e376c08",
							50 => X"2748774c",
							51 => X"34b0bcb5",
							52 => X"391c0cb3",
							53 => X"4ed8aa4a",
							54 => X"5b9cca4f",
							55 => X"682e6ff3",
							56 => X"748f82ee",
							57 => X"78a5636f",
							58 => X"84c87814",
							59 => X"8cc70208",
							60 => X"90befffa",
							61 => X"a4506ceb",
							62 => X"bef9a3f7",
							63 => X"c67178f2");  
  signal read_a : std_logic_vector(ADDR_LENGTH - 1 downto 0) := (others=>'0');
  signal read_dpra : std_logic_vector(ADDR_LENGTH - 1 downto 0) := (others=> '0');

  attribute ram_style: string;
  attribute ram_style of RAM: signal is "block";

begin
  process (clk)
  begin  
    if rising_edge(clk) then
      if (we = '1') then    
        RAM(conv_integer(a)) <= di;
      end if;  
      read_a <= a;
      read_dpra <= dpra;
    end if;  
  end process;
  
  spo <= RAM(conv_integer(read_a));
  dpo <= RAM(conv_integer(read_dpra));
end rtl;
