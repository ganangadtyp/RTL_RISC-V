library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fast_multiplier_32x32 is
    Port (
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        p : out STD_LOGIC_VECTOR(63 downto 0)
    );
end fast_multiplier_32x32;

architecture Behavioral of fast_multiplier_32x32 is
    signal ac, bc, ad, bd : STD_LOGIC_VECTOR(31 downto 0);
    signal t1, t2 : STD_LOGIC_VECTOR(63 downto 0);
    signal psum : STD_LOGIC_VECTOR(32 downto 0);

    component fast_multiplier_16x16
        Port (
            a : in STD_LOGIC_VECTOR(15 downto 0);
            b : in STD_LOGIC_VECTOR(15 downto 0);
            p : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

begin
    -- Instansiasi fast_multiplier_16x16
    m1: fast_multiplier_16x16
        Port map (
            a => a(31 downto 16),
            b => b(31 downto 16),
            p => ac
        );

    m2: fast_multiplier_16x16
        Port map (
            a => a(15 downto 0),
            b => b(31 downto 16),
            p => bc
        );

    m3: fast_multiplier_16x16
        Port map (
            a => a(31 downto 16),
            b => b(15 downto 0),
            p => ad
        );

    m4: fast_multiplier_16x16
        Port map (
            a => a(15 downto 0),
            b => b(15 downto 0),
            p => bd
        );

    -- Menghitung nilai t2, psum, dan t1
    t2(63 downto 32) <= (others => '0');
    t2(31 downto 0) <= bd;  -- Memasukkan bd ke bagian bawah t2
    psum <= ('0' & bc) + ('0' & ad);  -- Memasukkan penjumlahan bc dan ad dengan padding 4 bit 0
    t1(63 downto 32)<= ac ;  -- Memasukkan ac ke bagian atas t1
    t1(31 downto 0) <= (others => '0');

    -- Menghasilkan output
    p <= t1 + t2 + ('0'&"00"&"0000"& "0000" & "0000" & psum & "0000" & "0000" & "0000" & "0000");  -- Menggunakan psum dengan padding 2 bit 0 di depan
end Behavioral;
