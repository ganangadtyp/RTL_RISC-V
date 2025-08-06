----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : selector_6_to_1
-- Fungsi       : melakukan pemilihan 6 buah input 32 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_6_to_1 is
  port (
    -- variabel input
    in6_1      : in  std_logic_vector(31 downto 0);
    in6_2      : in  std_logic_vector(31 downto 0);
    in6_3      : in  std_logic_vector(31 downto 0);
    in6_4      : in  std_logic_vector(31 downto 0);
    in6_5      : in  std_logic_vector(31 downto 0);
    in6_6      : in  std_logic_vector(31 downto 0);
    sel_6      : in  std_logic_vector(6 downto 1);
    -- variabel output
    sel_outs_6 : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_6_to_1 is

  component tristbuf
    port (
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

begin

  -- sel_6 = "000001" --> pilih in6_1
  sel6_1 : tristbuf
    port map (
      X  => in6_1,
      En => sel_6(1),
      F  => sel_outs_6
    );

  -- sel_6 = "000010" --> pilih in6_2
  sel6_2 : tristbuf
    port map (
      X  => in6_2,
      En => sel_6(2),
      F  => sel_outs_6
    );

  -- sel_6 = "000100" --> pilih in6_3
  sel6_3 : tristbuf
    port map (
      X  => in6_3,
      En => sel_6(3),
      F  => sel_outs_6
    );

  -- sel_6 = "001000" --> pilih in6_4
  sel6_4 : tristbuf
    port map (
      X  => in6_4,
      En => sel_6(4),
      F  => sel_outs_6
    );

  -- sel_6 = "010000" --> pilih in6_5
  sel6_5 : tristbuf
    port map (
      X  => in6_5,
      En => sel_6(5),
      F  => sel_outs_6
    );

  -- sel_6 = "100000" --> pilih in6_6
  sel6_6 : tristbuf
    port map (
      X  => in6_6,
      En => sel_6(6),
      F  => sel_outs_6
    );

end architecture;
