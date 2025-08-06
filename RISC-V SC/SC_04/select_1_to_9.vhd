----------------------------------------------------
-- Desain      : Kriptografi BC3
-- Entity      : selector_1_to_9
-- Fungsi      : sebagai demux 1 ke 9 (32 bit)
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_1_to_9 is
    port (
        in9    : in  std_logic_vector(31 downto 0);
        sel_9  : in  std_logic_vector(9 downto 1);
        out9_1 : out std_logic_vector(31 downto 0);
        out9_2 : out std_logic_vector(31 downto 0);
        out9_3 : out std_logic_vector(31 downto 0);
        out9_4 : out std_logic_vector(31 downto 0);
        out9_5 : out std_logic_vector(31 downto 0);
        out9_6 : out std_logic_vector(31 downto 0);
        out9_7 : out std_logic_vector(31 downto 0);
        out9_8 : out std_logic_vector(31 downto 0);
        out9_9 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture dataflow of selector_1_to_9 is

    component tristbuf
        port (
            X  : in  std_logic_vector(31 downto 0);
            En : in  std_logic;
            F  : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    -- instansiasi eksplisit port mapping
    sel9_1 : tristbuf
        port map (
            X  => in9,
            En => sel_9(1),
            F  => out9_1
        );

    sel9_2 : tristbuf
        port map (
            X  => in9,
            En => sel_9(2),
            F  => out9_2
        );

    sel9_3 : tristbuf
        port map (
            X  => in9,
            En => sel_9(3),
            F  => out9_3
        );

    sel9_4 : tristbuf
        port map (
            X  => in9,
            En => sel_9(4),
            F  => out9_4
        );

    sel9_5 : tristbuf
        port map (
            X  => in9,
            En => sel_9(5),
            F  => out9_5
        );

    sel9_6 : tristbuf
        port map (
            X  => in9,
            En => sel_9(6),
            F  => out9_6
        );

    sel9_7 : tristbuf
        port map (
            X  => in9,
            En => sel_9(7),
            F  => out9_7
        );

    sel9_8 : tristbuf
        port map (
            X  => in9,
            En => sel_9(8),
            F  => out9_8
        );

    sel9_9 : tristbuf
        port map (
            X  => in9,
            En => sel_9(9),
            F  => out9_9
        );

end architecture;
