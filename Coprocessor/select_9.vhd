----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : selector_9_to_1
-- Fungsi      : melakukan pemilihan 9 buah input 32 bit
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_9_to_1 is
  port(
    in9_1      : in  std_logic_vector(31 downto 0);
    in9_2      : in  std_logic_vector(31 downto 0);
    in9_3      : in  std_logic_vector(31 downto 0);
    in9_4      : in  std_logic_vector(31 downto 0);
    in9_5      : in  std_logic_vector(31 downto 0);
    in9_6      : in  std_logic_vector(31 downto 0);
    in9_7      : in  std_logic_vector(31 downto 0);
    in9_8      : in  std_logic_vector(31 downto 0);
    in9_9      : in  std_logic_vector(31 downto 0);
    sel_9      : in  std_logic_vector(9 downto 1);
    sel_outs_9 : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_9_to_1 is

  component tristbuf
    port(
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

begin
  sel9_1 : tristbuf
    port map(
      X  => in9_1,
      En => sel_9(1),
      F  => sel_outs_9
    );
  sel9_2 : tristbuf
    port map(
      X  => in9_2,
      En => sel_9(2),
      F  => sel_outs_9
    );
  sel9_3 : tristbuf
    port map(
      X  => in9_3,
      En => sel_9(3),
      F  => sel_outs_9
    );
  sel9_4 : tristbuf
    port map(
      X  => in9_4,
      En => sel_9(4),
      F  => sel_outs_9
    );
  sel9_5 : tristbuf
    port map(
      X  => in9_5,
      En => sel_9(5),
      F  => sel_outs_9
    );
  sel9_6 : tristbuf
    port map(
      X  => in9_6,
      En => sel_9(6),
      F  => sel_outs_9
    );
  sel9_7 : tristbuf
    port map(
      X  => in9_7,
      En => sel_9(7),
      F  => sel_outs_9
    );
  sel9_8 : tristbuf
    port map(
      X  => in9_8,
      En => sel_9(8),
      F  => sel_outs_9
    );
  sel9_9 : tristbuf
    port map(
      X  => in9_9,
      En => sel_9(9),
      F  => sel_outs_9
    );
end architecture;
