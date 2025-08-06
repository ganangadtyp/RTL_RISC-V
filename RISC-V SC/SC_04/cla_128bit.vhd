library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add_128bit is
    Port (
        a : in STD_LOGIC_VECTOR(127 downto 0);
        b : in STD_LOGIC_VECTOR(127 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(127 downto 0);
        cout : out STD_LOGIC
    );
end add_128bit;

architecture Structural of add_128bit is

    -- Component declaration for CLA 64-bit
    component add_64bit
        Port (
            a : in STD_LOGIC_VECTOR(63 downto 0);
            b : in STD_LOGIC_VECTOR(63 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(63 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    -- Signal to connect carry between the two CLA 64-bit blocks
    signal carry_mid : STD_LOGIC;

begin

    -- Instantiate CLA 64-bit for lower 64-bit
    i_add_lower: add_64bit
        Port map (
            a => a(63 downto 0),
            b => b(63 downto 0),
            cin => cin,
            sum => sum(63 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 64-bit for upper 64-bit
    i_add_upper: add_64bit
        Port map (
            a => a(127 downto 64),
            b => b(127 downto 64),
            cin => carry_mid,
            sum => sum(127 downto 64),
            cout => cout
        );

end Structural;
