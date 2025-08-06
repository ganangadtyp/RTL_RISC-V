library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cla_512bit is
    Port (
        a : in STD_LOGIC_VECTOR(511 downto 0);
        b : in STD_LOGIC_VECTOR(511 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(511 downto 0);
        cout : out STD_LOGIC
    );
end cla_512bit;

architecture Behavioral of cla_512bit is

    -- Component declaration for CLA 128-bit
    component cla_256bit
        Port (
            a : in STD_LOGIC_VECTOR(255 downto 0);
            b : in STD_LOGIC_VECTOR(255 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(255 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    -- Signal to connect carry between the two CLA 128-bit blocks
    signal carry_mid : STD_LOGIC;

begin

    -- Instantiate CLA 128-bit for lower 128-bit
    CLA_lower: cla_256bit
        Port map (
            a => a(255 downto 0),
            b => b(255 downto 0),
            cin => cin,
            sum => sum(255 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 128-bit for upper 128-bit
    CLA_upper: cla_256bit
        Port map (
            a => a(511 downto 256),
            b => b(511 downto 256),
            cin => carry_mid,
            sum => sum(511 downto 256),
            cout => cout
        );

end Behavioral;
