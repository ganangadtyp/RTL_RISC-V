library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add_sub_256bit is
    Port (
        a : in STD_LOGIC_VECTOR(255 downto 0);      -- input a
        b : in STD_LOGIC_VECTOR(255 downto 0);      -- input b
        sub : in STD_LOGIC;                         -- 1 = pengurangan; 0 = penjumlahan
        sum : out STD_LOGIC_VECTOR(255 downto 0);   -- hasil penjumlahan/pengurangan
        cout : out STD_LOGIC                        -- Carry
    );
end add_sub_256bit;

architecture Structural of add_sub_256bit is

    -- Component declaration for CLA 256-bit
    component add_128bit
        Port (
            a : in STD_LOGIC_VECTOR(127 downto 0);
            b : in STD_LOGIC_VECTOR(127 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(127 downto 0);
            cout : out STD_LOGIC
        );
 
    end component;

    -- Signal to connect carry between the two CLA 256-bit blocks
    signal carry_mid : STD_LOGIC;
    signal b_inverted : STD_LOGIC_VECTOR(255 downto 0);
    signal inversion : STD_LOGIC_VECTOR(255 downto 0):= (others => '1');

begin
     b_inverted <= b xor inversion when sub='1' else b;

    -- Instantiate CLA 256-bit for lower 256-bit
    i_add_lower: add_128bit
        Port map (
            a => a(127 downto 0),
            b => b_inverted(127 downto 0),
            cin => sub, -- Set cin to '1' for subtraction (two's complement)
            sum => sum(127 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 256-bit for upper 256-bit
    i_add_upper: add_128bit
        Port map (
            a => a(255 downto 128),
            b => b_inverted(255 downto 128),
            cin => carry_mid,
            sum => sum(255 downto 128),
            cout => cout
        );

end Structural;