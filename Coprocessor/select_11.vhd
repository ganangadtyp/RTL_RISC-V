----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : selector_11_to_1
-- Fungsi      : melakukan pemilihan 11 buah input 32 bit
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_11_to_1 is
  port(
    in_1       : in  std_logic_vector(31 downto 0);
    in_2       : in  std_logic_vector(31 downto 0);
    in_3       : in  std_logic_vector(31 downto 0);
    in_4       : in  std_logic_vector(31 downto 0);
    in_5       : in  std_logic_vector(31 downto 0);
    in_6       : in  std_logic_vector(31 downto 0);
    in_7       : in  std_logic_vector(31 downto 0);
    in_8       : in  std_logic_vector(31 downto 0);
    in_9       : in  std_logic_vector(31 downto 0);
    in_10      : in  std_logic_vector(31 downto 0);
    in_11      : in  std_logic_vector(31 downto 0);
    sel_11     : in  std_logic_vector(11 downto 1);
    sel_outs_11: out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_11_to_1 is

  component tristbuf
    port(
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

begin
  sel11_1 : tristbuf
    port map(
      X  => in_1,
      En => sel_11(1),
      F  => sel_outs_11
    );

  sel11_2 : tristbuf
    port map(
      X  => in_2,
      En => sel_11(2),
      F  => sel_outs_11
    );

  sel11_3 : tristbuf
    port map(
      X  => in_3,
      En => sel_11(3),
      F  => sel_outs_11
    );

  sel11_4 : tristbuf
    port map(
      X  => in_4,
      En => sel_11(4),
      F  => sel_outs_11
    );

  sel11_5 : tristbuf
    port map(
      X  => in_5,
      En => sel_11(5),
      F  => sel_outs_11
    );

  sel11_6 : tristbuf
    port map(
      X  => in_6,
      En => sel_11(6),
      F  => sel_outs_11
    );

  sel11_7 : tristbuf
    port map(
      X  => in_7,
      En => sel_11(7),
      F  => sel_outs_11
    );

  sel11_8 : tristbuf
    port map(
      X  => in_8,
      En => sel_11(8),
      F  => sel_outs_11
    );

  sel11_9 : tristbuf
    port map(
      X  => in_9,
      En => sel_11(9),
      F  => sel_outs_11
    );

  sel11_10 : tristbuf
    port map(
      X  => in_10,
      En => sel_11(10),
      F  => sel_outs_11
    );

  sel11_11 : tristbuf
    port map(
      X  => in_11,
      En => sel_11(11),
      F  => sel_outs_11
    );

end architecture;
