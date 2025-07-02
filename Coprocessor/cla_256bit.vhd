library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cla_256bit is
    Port (
        a : in STD_LOGIC_VECTOR(255 downto 0);
        b : in STD_LOGIC_VECTOR(255 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(255 downto 0);
        cout : out STD_LOGIC
    );
end cla_256bit;

architecture Behavioral of cla_256bit is

    -- Component declaration for CLA 128-bit
    component add_128bit
        Port (
            a : in STD_LOGIC_VECTOR(127 downto 0);
            b : in STD_LOGIC_VECTOR(127 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(127 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    -- Signal to connect carry between the two CLA 128-bit blocks
    signal carry_mid : STD_LOGIC;

begin

    -- Instantiate CLA 128-bit for lower 128-bit
    i_add_lower: add_128bit
        Port map (
            a => a(127 downto 0),
            b => b(127 downto 0),
            cin => cin,
            sum => sum(127 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 128-bit for upper 128-bit
    i_add_upper: add_128bit
        Port map (
            a => a(255 downto 128),
            b => b(255 downto 128),
            cin => carry_mid,
            sum => sum(255 downto 128),
            cout => cout
        );

end Behavioral;
