library ieee;
use ieee.std_logic_1164.all;

entity selector_4_64bit is
  port(
    -- inputs
    in64_1, in64_2, in64_3, in64_4 : in  std_logic_vector(63 downto 0);
    sel64_4                       : in  std_logic_vector(4 downto 1);
    -- output
    sel64_outs_4                  : out std_logic_vector(63 downto 0)
  );
end entity;

architecture dataflow of selector_4_64bit is

  component tristbuf_64
    port(
      X  : in  std_logic_vector(63 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(63 downto 0)
    );
  end component;

begin
  -- sel64_4 = "0001" --> in64_1
  select64_1 : tristbuf_64
    port map (
      X  => in64_1,
      En => sel64_4(1),
      F  => sel64_outs_4
    );

  -- sel64_4 = "0010" --> in64_2
  select64_2 : tristbuf_64
    port map (
      X  => in64_2,
      En => sel64_4(2),
      F  => sel64_outs_4
    );

  -- sel64_4 = "0100" --> in64_3
  select64_3 : tristbuf_64
    port map (
      X  => in64_3,
      En => sel64_4(3),
      F  => sel64_outs_4
    );

  -- sel64_4 = "1000" --> in64_4
  select64_4 : tristbuf_64
    port map (
      X  => in64_4,
      En => sel64_4(4),
      F  => sel64_outs_4
    );

end architecture;
