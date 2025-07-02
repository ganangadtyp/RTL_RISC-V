----------------------------------------------------
-- Desain      : Kriptografi BC3
-- Entity      : selector_1_to_11
-- Fungsi      : sebagai demux 1 ke 11 (32 bit)
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity selector_1_to_11 is
  port (
    in11    : in  std_logic_vector(31 downto 0);
    sel_11  : in  std_logic_vector(11 downto 1);
    out11_1 : out std_logic_vector(31 downto 0);
    out11_2 : out std_logic_vector(31 downto 0);
    out11_3 : out std_logic_vector(31 downto 0);
    out11_4 : out std_logic_vector(31 downto 0);
    out11_5 : out std_logic_vector(31 downto 0);
    out11_6 : out std_logic_vector(31 downto 0);
    out11_7 : out std_logic_vector(31 downto 0);
    out11_8 : out std_logic_vector(31 downto 0);
    out11_9 : out std_logic_vector(31 downto 0);
    out11_10: out std_logic_vector(31 downto 0);
    out11_11: out std_logic_vector(31 downto 0)
  );
end entity selector_1_to_11;

architecture dataflow of selector_1_to_11 is

  component tristbuf
    port (
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

begin

  sel11_1  : tristbuf port map ( X => in11,  En => sel_11(1),  F => out11_1  );
  sel11_2  : tristbuf port map ( X => in11,  En => sel_11(2),  F => out11_2  );
  sel11_3  : tristbuf port map ( X => in11,  En => sel_11(3),  F => out11_3  );
  sel11_4  : tristbuf port map ( X => in11,  En => sel_11(4),  F => out11_4  );
  sel11_5  : tristbuf port map ( X => in11,  En => sel_11(5),  F => out11_5  );
  sel11_6  : tristbuf port map ( X => in11,  En => sel_11(6),  F => out11_6  );
  sel11_7  : tristbuf port map ( X => in11,  En => sel_11(7),  F => out11_7  );
  sel11_8  : tristbuf port map ( X => in11,  En => sel_11(8),  F => out11_8  );
  sel11_9  : tristbuf port map ( X => in11,  En => sel_11(9),  F => out11_9  );
  sel11_10 : tristbuf port map ( X => in11,  En => sel_11(10), F => out11_10 );
  sel11_11 : tristbuf port map ( X => in11,  En => sel_11(11), F => out11_11 );

end architecture dataflow;