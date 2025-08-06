----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : selector_3
-- Fungsi      : melakukan pemilihan 3 buah input 32 bit
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_3 is
  port(
    -- variabel input
    in3_1      : in  std_logic_vector(31 downto 0);
    in3_2      : in  std_logic_vector(31 downto 0);
    in3_3      : in  std_logic_vector(31 downto 0);
    sel_3      : in  std_logic_vector(3 downto 1);
    -- variabel output
    sel_outs_3 : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_3 is

  component tristbuf
    port(
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

begin
  sel3_1 : tristbuf
    port map(
      X  => in3_1,
      En => sel_3(1),
      F  => sel_outs_3
    );

  sel3_2 : tristbuf
    port map(
      X  => in3_2,
      En => sel_3(2),
      F  => sel_outs_3
    );

  sel3_3 : tristbuf
    port map(
      X  => in3_3,
      En => sel_3(3),
      F  => sel_outs_3
    );

end architecture;
