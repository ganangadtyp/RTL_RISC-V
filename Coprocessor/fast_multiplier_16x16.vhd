library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fast_multiplier_16x16 is
    Port (
        a : in STD_LOGIC_VECTOR(15 downto 0);
        b : in STD_LOGIC_VECTOR(15 downto 0);
        p : out STD_LOGIC_VECTOR(31 downto 0)
    );
end fast_multiplier_16x16;

architecture Behavioral of fast_multiplier_16x16 is
    signal ac, bc, ad, bd : STD_LOGIC_VECTOR(15 downto 0);
    signal t1, t2 : STD_LOGIC_VECTOR(31 downto 0);
    signal psum : STD_LOGIC_VECTOR(16 downto 0);
    
    component mult8 is
        Port (
        i_a : in STD_LOGIC_VECTOR(7 downto 0);
        i_b : in STD_LOGIC_VECTOR(7 downto 0);
        o_p : out STD_LOGIC_VECTOR(15 downto 0)
        );
end component;

component csa3 is
  generic (
    WIDTH : integer := 12
  );
  port (
    A     : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    B     : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    C     : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    Sum   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    Carry : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
  );
end component;

begin
    -- Instansiasi fast_multiplier_8x8
    u_m0 : mult8
        Port map (
            i_a => a(15 downto 8),
            i_b => b(15 downto 8),
            o_p => ac
        );
        
    u_m1 : mult8
        Port map (
            i_a => a(7 downto 0),
            i_b => b(15 downto 8),
            o_p => bc
        );
        
    u_m2 : mult8
        Port map (
            i_a => a(15 downto 8),
            i_b => b(7 downto 0),
            o_p => ad
        );
    
    u_m3 : mult8
        Port map (
            i_a => a(7 downto 0),
            i_b => b(7 downto 0),
            o_p => bd
        );

    -- Menghitung nilai t2, psum, dan t1
    t1 <= ac & "0000" & "0000" & "0000" & "0000";  -- Memasukkan ac ke bagian atas t1
    t2 <= "0000" & "0000" & "0000" & "0000" & bd;  -- Memasukkan bd ke bagian bawah t2
    psum <=  ('0' & ad) + ('0' & bc);
    
    -- Menghasilkan output
    p <= t1 + t2 + ("0000" & "000" & psum & "0000" & "0000");  -- Menggunakan psum dengan padding 2 bit 0 di depan
end Behavioral;
