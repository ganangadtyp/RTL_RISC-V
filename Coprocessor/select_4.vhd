----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : selector_4
-- Fungsi      : melakukan pemilihan 4 buah input 32 bit
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_4 is
  port(
    -- variabel input 
    in_1       : in  std_logic_vector(31 downto 0);
    in_2       : in  std_logic_vector(31 downto 0);
    in_3       : in  std_logic_vector(31 downto 0);
    in_4       : in  std_logic_vector(31 downto 0);
    sel_4      : in  std_logic_vector(4 downto 1);
    -- variabel output 
    sel_outs_4 : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of selector_4 is
  component tristbuf
    port(
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;
begin
  sel4_1 : tristbuf
    port map(
      X  => in_1,
      En => sel_4(1),
      F  => sel_outs_4
    );

  sel4_2 : tristbuf
    port map(
      X  => in_2,
      En => sel_4(2),
      F  => sel_outs_4
    );

  sel4_3 : tristbuf
    port map(
      X  => in_3,
      En => sel_4(3),
      F  => sel_outs_4
    );

  sel4_4 : tristbuf
    port map(
      X  => in_4,
      En => sel_4(4),
      F  => sel_outs_4
    );
end architecture;
