library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_16bit is
    Port (
        a    : in  STD_LOGIC_VECTOR(15 downto 0);
        b    : in  STD_LOGIC_VECTOR(15 downto 0);
        cin  : in  STD_LOGIC;
        sum  : out STD_LOGIC_VECTOR(15 downto 0);
        cout : out STD_LOGIC
    );
end entity;

architecture Behavioral of cla_16bit is
    -- per-bit propagate & generate
    signal p, g     : STD_LOGIC_VECTOR(15 downto 0);
    -- block-level propagate & generate (4 blocks)
    signal P_blk, G_blk : STD_LOGIC_VECTOR(3 downto 0);
    -- carries: c(0)=cin, c(16)=cout
    signal c        : STD_LOGIC_VECTOR(16 downto 0);
    -- intermediate block carries
    signal c_blk    : STD_LOGIC_VECTOR(4 downto 0);
begin
    -- hitung per-bit p/g
    p <= a xor b;
    g <= a and b;

    -- block-level P/G untuk tiap 4-bit
    P_blk(0) <= p(3)  and p(2)  and p(1)  and p(0);
    G_blk(0) <= g(3) or (p(3) and g(2))
                   or (p(3) and p(2) and g(1))
                   or (p(3) and p(2) and p(1) and g(0));

    P_blk(1) <= p(7)  and p(6)  and p(5)  and p(4);
    G_blk(1) <= g(7) or (p(7) and g(6))
                   or (p(7) and p(6) and g(5))
                   or (p(7) and p(6) and p(5) and g(4));

    P_blk(2) <= p(11) and p(10) and p(9)  and p(8);
    G_blk(2) <= g(11) or (p(11) and g(10))
                    or (p(11) and p(10) and g(9))
                    or (p(11) and p(10) and p(9) and g(8));

    P_blk(3) <= p(15) and p(14) and p(13) and p(12);
    G_blk(3) <= g(15) or (p(15) and g(14))
                    or (p(15) and p(14) and g(13))
                    or (p(15) and p(14) and p(13) and g(12));

    -- mulai block carry chain
    c_blk(0) <= cin;
    c_blk(1) <= G_blk(0)
                or (P_blk(0) and c_blk(0));
    c_blk(2) <= G_blk(1)
                or (P_blk(1) and G_blk(0))
                or (P_blk(1) and P_blk(0) and c_blk(0));
    c_blk(3) <= G_blk(2)
                or (P_blk(2) and G_blk(1))
                or (P_blk(2) and P_blk(1) and G_blk(0))
                or (P_blk(2) and P_blk(1) and P_blk(0) and c_blk(0));
    c_blk(4) <= G_blk(3)
                or (P_blk(3) and G_blk(2))
                or (P_blk(3) and P_blk(2) and G_blk(1))
                or (P_blk(3) and P_blk(2) and P_blk(1) and G_blk(0))
                or (P_blk(3) and P_blk(2) and P_blk(1) and P_blk(0) and c_blk(0));

    -- peta block carries ke c
    c(0)  <= c_blk(0);
    c(4)  <= c_blk(1);
    c(8)  <= c_blk(2);
    c(12) <= c_blk(3);
    c(16) <= c_blk(4);

    -- intra-block carries
    -- block 0 (bits 0-3)
    c(1) <= g(0) or (p(0) and c(0));
    c(2) <= g(1) or (p(1) and g(0))
                 or (p(1) and p(0) and c(0));
    c(3) <= g(2) or (p(2) and g(1))
                 or (p(2) and p(1) and g(0))
                 or (p(2) and p(1) and p(0) and c(0));

    -- block 1 (bits 4-7)
    c(5) <= g(4) or (p(4) and c(4));
    c(6) <= g(5) or (p(5) and g(4))
                 or (p(5) and p(4) and c(4));
    c(7) <= g(6) or (p(6) and g(5))
                 or (p(6) and p(5) and g(4))
                 or (p(6) and p(5) and p(4) and c(4));

    -- block 2 (bits 8-11)
    c(9)  <= g(8)  or (p(8)  and c(8));
    c(10) <= g(9)  or (p(9)  and g(8))
                  or (p(9)  and p(8)  and c(8));
    c(11) <= g(10) or (p(10) and g(9))
                  or (p(10) and p(9)  and g(8))
                  or (p(10) and p(9)  and p(8) and c(8));

    -- block 3 (bits 12-15)
    c(13) <= g(12) or (p(12) and c(12));
    c(14) <= g(13) or (p(13) and g(12))
                  or (p(13) and p(12) and c(12));
    c(15) <= g(14) or (p(14) and g(13))
                  or (p(14) and p(13) and g(12))
                  or (p(14) and p(13) and p(12) and c(12));

    -- sum & final carry-out
    gen_sum: for i in 0 to 15 generate
        sum(i) <= p(i) xor c(i);
    end generate;
    cout <= c(16);

end architecture;