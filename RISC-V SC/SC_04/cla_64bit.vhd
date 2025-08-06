library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add_64bit is
    Port (
        a : in STD_LOGIC_VECTOR(63 downto 0);
        b : in STD_LOGIC_VECTOR(63 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(63 downto 0);
        cout : out STD_LOGIC
    );
end add_64bit;

architecture Structural of add_64bit is

    -- Component declaration for CLA 32-bit
    component add_32bit
        Port (
            a : in STD_LOGIC_VECTOR(31 downto 0);
            b : in STD_LOGIC_VECTOR(31 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(31 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    -- Signal to connect carry between the two CLA 32-bit blocks
    signal carry_mid : STD_LOGIC;

begin

    -- Instantiate CLA 32-bit for lower 32-bit
    i_add_lower: add_32bit
        Port map (
            a => a(31 downto 0),
            b => b(31 downto 0),
            cin => cin,
            sum => sum(31 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 32-bit for upper 32-bit
    i_add_upper: add_32bit
        Port map (
            a => a(63 downto 32),
            b => b(63 downto 32),
            cin => carry_mid,
            sum => sum(63 downto 32),
            cout => cout
        );

end Structural;
