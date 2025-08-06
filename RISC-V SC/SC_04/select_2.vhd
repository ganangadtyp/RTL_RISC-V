----------------------------------------------------
-- Disain       : Kriptografi BC3
-- Entity       : selector_2
-- Fungsi       : melakukan pemilihan 2 buah input 32 bit
-- dibuat oleh  : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_2 is
  port (
    -- variabel input
    in_1      : in  std_logic_vector(31 downto 0);
    in_2      : in  std_logic_vector(31 downto 0);
    sel_2     : in  std_logic;
    -- variabel output
    sel_outs_2: out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_2 is

  component tristbuf
    port (
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

  signal no_sel_2 : std_logic;

begin
  -- ketika sel_2 = '1' pilih in_1, jika '0' pilih in_2
  no_sel_2 <= not sel_2;

  sel2_1 : tristbuf
    port map (
      X  => in_1,
      En => sel_2,
      F  => sel_outs_2
    );

  sel2_2 : tristbuf
    port map (
      X  => in_2,
      En => no_sel_2,
      F  => sel_outs_2
    );

end architecture;
