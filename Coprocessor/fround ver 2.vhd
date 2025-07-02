----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : fround
-- Fungsi      : ---  
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fround is
  port(
    fround_left_in  : in  std_logic_vector(31 downto 0);
    fround_right_in : in  std_logic_vector(31 downto 0);
    subkey          : in  std_logic_vector(31 downto 0);
    fround_out      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of fround is

  component mds
    port(
      mds_in  : in  std_logic_vector(31 downto 0);
      mds_out : out std_logic_vector(31 downto 0)
    );
  end component;

  component sbox
    port(
      sbox_in  : in  std_logic_vector(7 downto 0);
      sbox_out : out std_logic_vector(7 downto 0)
    );
  end component;

  signal sbox_tmp    : std_logic_vector(31 downto 0);
  signal mds_out_tmp : std_logic_vector(31 downto 0);

begin
  -- four parallel S-box instances with explicit port mapping
  fround_sbox1 : sbox
    port map (
      sbox_in  => fround_right_in( 7 downto  0),
      sbox_out => sbox_tmp( 7 downto  0)
    );

  fround_sbox2 : sbox
    port map (
      sbox_in  => fround_right_in(15 downto  8),
      sbox_out => sbox_tmp(15 downto  8)
    );

  fround_sbox3 : sbox
    port map (
      sbox_in  => fround_right_in(23 downto 16),
      sbox_out => sbox_tmp(23 downto 16)
    );

  fround_sbox4 : sbox
    port map (
      sbox_in  => fround_right_in(31 downto 24),
      sbox_out => sbox_tmp(31 downto 24)
    );

  -- MDS layer with explicit port mapping
  fround_mds : mds
    port map (
      mds_in  => sbox_tmp,
      mds_out => mds_out_tmp
    );

  -- final XOR combination
  fround_out <= mds_out_tmp xor subkey xor fround_left_in;

end architecture;
