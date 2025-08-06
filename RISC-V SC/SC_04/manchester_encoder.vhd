library ieee;
use ieee.std_logic_1164.all;

entity manchester_encoder is
    port (
        clk : in std_logic;
        d_in   : in std_logic;
        d_out   : out std_logic
    );
end entity manchester_encoder;

architecture behavioral of manchester_encoder is
begin
    d_out <= d_in xor clk;
end architecture behavioral;
