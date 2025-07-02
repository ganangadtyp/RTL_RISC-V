library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add_32bit is
    Port (
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(31 downto 0);
        cout : out STD_LOGIC
    );
end add_32bit;

architecture Structural of add_32bit is

    -- Component declaration for CLA 16-bit
    component cla_16bit
        Port (
            a : in STD_LOGIC_VECTOR(15 downto 0);
            b : in STD_LOGIC_VECTOR(15 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(15 downto 0);
            cout : out STD_LOGIC
        );
    end component;
    
    component rca_16bit
        Port (
            a : in STD_LOGIC_VECTOR(15 downto 0);
            b : in STD_LOGIC_VECTOR(15 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(15 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    -- Signals to connect carry between the two CLA 16-bit blocks
    signal carry_mid : STD_LOGIC;

begin

    -- Instantiate CLA 16-bit for lower 16-bit
    CLA_lower: cla_16bit
        Port map (
            a => a(15 downto 0),
            b => b(15 downto 0),
            cin => cin,
            sum => sum(15 downto 0),
            cout => carry_mid
        );

    -- Instantiate CLA 16-bit for upper 16-bit
    RCA_upper: rca_16bit
        Port map (
            a => a(31 downto 16),
            b => b(31 downto 16),
            cin => carry_mid,
            sum => sum(31 downto 16),
            cout => cout
        );

end Structural;
