----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : subkey_reg
-- Fungsi      : menyimpan nilai subkey-subkey
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity subkey_reg is
  port (
    reset   : in  std_logic;
    clk     : in  std_logic;

    KA_in   : in  std_logic_vector(31 downto 0);
    KB_in   : in  std_logic_vector(31 downto 0);
    KC_in   : in  std_logic_vector(31 downto 0);
    KD_in   : in  std_logic_vector(31 downto 0);
    KE_in   : in  std_logic_vector(31 downto 0);
    KF_in   : in  std_logic_vector(31 downto 0);
    KG_in   : in  std_logic_vector(31 downto 0);
    K1_in   : in  std_logic_vector(31 downto 0);
    K2_in   : in  std_logic_vector(31 downto 0);
    K3_in   : in  std_logic_vector(31 downto 0);
    K4_in   : in  std_logic_vector(31 downto 0);
    K5_in   : in  std_logic_vector(31 downto 0);
    K6_in   : in  std_logic_vector(31 downto 0);
    K7_in   : in  std_logic_vector(31 downto 0);
    K8_in   : in  std_logic_vector(31 downto 0);
    K9_in   : in  std_logic_vector(31 downto 0);
    K10_in  : in  std_logic_vector(31 downto 0);
    K11_in  : in  std_logic_vector(31 downto 0);
    KW1_in  : in  std_logic_vector(31 downto 0);
    KW2_in  : in  std_logic_vector(31 downto 0);
    KW3_in  : in  std_logic_vector(31 downto 0);
    KW4_in  : in  std_logic_vector(31 downto 0);
    KF1_in  : in  std_logic_vector(31 downto 0);
    KF2_in  : in  std_logic_vector(31 downto 0);

    KA_enable   : in  std_logic;
    KB_enable   : in  std_logic;
    KC_enable   : in  std_logic;
    KD_enable   : in  std_logic;
    KE_enable   : in  std_logic;
    KF_enable   : in  std_logic;
    KG_enable   : in  std_logic;
    K1_enable   : in  std_logic;
    K2_enable   : in  std_logic;
    K3_enable   : in  std_logic;
    K4_enable   : in  std_logic;
    K5_enable   : in  std_logic;
    K6_enable   : in  std_logic;
    K7_enable   : in  std_logic;
    K8_enable   : in  std_logic;
    K9_enable   : in  std_logic;
    K10_enable  : in  std_logic;
    K11_enable  : in  std_logic;
    KW1_enable  : in  std_logic;
    KW2_enable  : in  std_logic;
    KW3_enable  : in  std_logic;
    KW4_enable  : in  std_logic;
    KF1_enable  : in  std_logic;
    KF2_enable  : in  std_logic;

    KA_out   : out std_logic_vector(31 downto 0);
    KB_out   : out std_logic_vector(31 downto 0);
    KC_out   : out std_logic_vector(31 downto 0);
    KD_out   : out std_logic_vector(31 downto 0);
    KE_out   : out std_logic_vector(31 downto 0);
    KF_out   : out std_logic_vector(31 downto 0);
    KG_out   : out std_logic_vector(31 downto 0);
    K1_out   : out std_logic_vector(31 downto 0);
    K2_out   : out std_logic_vector(31 downto 0);
    K3_out   : out std_logic_vector(31 downto 0);
    K4_out   : out std_logic_vector(31 downto 0);
    K5_out   : out std_logic_vector(31 downto 0);
    K6_out   : out std_logic_vector(31 downto 0);
    K7_out   : out std_logic_vector(31 downto 0);
    K8_out   : out std_logic_vector(31 downto 0);
    K9_out   : out std_logic_vector(31 downto 0);
    K10_out  : out std_logic_vector(31 downto 0);
    K11_out  : out std_logic_vector(31 downto 0);
    KW1_out  : out std_logic_vector(31 downto 0);
    KW2_out  : out std_logic_vector(31 downto 0);
    KW3_out  : out std_logic_vector(31 downto 0);
    KW4_out  : out std_logic_vector(31 downto 0);
    KF1_out  : out std_logic_vector(31 downto 0);
    KF2_out  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of subkey_reg is

  component reg_32
    port (
      reset   : in  std_logic;
      En      : in  std_logic;
      clk     : in  std_logic;
      reg_in  : in  std_logic_vector(31 downto 0);
      reg_out : out std_logic_vector(31 downto 0)
    );
  end component;

  signal inv_clk : std_logic;

begin
  -- invert clock for the first four registers
  inv_clk <= not clk;

  key_A : reg_32
    port map(
      reset   => reset,
      En      => KA_enable,
      clk     => inv_clk,
      reg_in  => KA_in,
      reg_out => KA_out
    );

  key_B : reg_32
    port map(
      reset   => reset,
      En      => KB_enable,
      clk     => inv_clk,
      reg_in  => KB_in,
      reg_out => KB_out
    );

  key_C : reg_32
    port map(
      reset   => reset,
      En      => KC_enable,
      clk     => inv_clk,
      reg_in  => KC_in,
      reg_out => KC_out
    );

  key_D : reg_32
    port map(
      reset   => reset,
      En      => KD_enable,
      clk     => inv_clk,
      reg_in  => KD_in,
      reg_out => KD_out
    );

  -- use non-inverted clock for the rest
  key_E : reg_32
    port map(
      reset   => reset,
      En      => KE_enable,
      clk     => clk,
      reg_in  => KE_in,
      reg_out => KE_out
    );

  key_F : reg_32
    port map(
      reset   => reset,
      En      => KF_enable,
      clk     => clk,
      reg_in  => KF_in,
      reg_out => KF_out
    );

  key_G : reg_32
    port map(
      reset   => reset,
      En      => KG_enable,
      clk     => clk,
      reg_in  => KG_in,
      reg_out => KG_out
    );

  key_1 : reg_32
    port map(
      reset   => reset,
      En      => K1_enable,
      clk     => clk,
      reg_in  => K1_in,
      reg_out => K1_out
    );

  key_2 : reg_32
    port map(
      reset   => reset,
      En      => K2_enable,
      clk     => clk,
      reg_in  => K2_in,
      reg_out => K2_out
    );

  key_3 : reg_32
    port map(
      reset   => reset,
      En      => K3_enable,
      clk     => clk,
      reg_in  => K3_in,
      reg_out => K3_out
    );

  key_4 : reg_32
    port map(
      reset   => reset,
      En      => K4_enable,
      clk     => clk,
      reg_in  => K4_in,
      reg_out => K4_out
    );

  key_5 : reg_32
    port map(
      reset   => reset,
      En      => K5_enable,
      clk     => clk,
      reg_in  => K5_in,
      reg_out => K5_out
    );

  key_6 : reg_32
    port map(
      reset   => reset,
      En      => K6_enable,
      clk     => clk,
      reg_in  => K6_in,
      reg_out => K6_out
    );

  key_7 : reg_32
    port map(
      reset   => reset,
      En      => K7_enable,
      clk     => clk,
      reg_in  => K7_in,
      reg_out => K7_out
    );

  key_8 : reg_32
    port map(
      reset   => reset,
      En      => K8_enable,
      clk     => clk,
      reg_in  => K8_in,
      reg_out => K8_out
    );

  key_9 : reg_32
    port map(
      reset   => reset,
      En      => K9_enable,
      clk     => clk,
      reg_in  => K9_in,
      reg_out => K9_out
    );

  key_10 : reg_32
    port map(
      reset   => reset,
      En      => K10_enable,
      clk     => clk,
      reg_in  => K10_in,
      reg_out => K10_out
    );

  key_11 : reg_32
    port map(
      reset   => reset,
      En      => K11_enable,
      clk     => clk,
      reg_in  => K11_in,
      reg_out => K11_out
    );

  key_W1 : reg_32
    port map(
      reset   => reset,
      En      => KW1_enable,
      clk     => clk,
      reg_in  => KW1_in,
      reg_out => KW1_out
    );

  key_W2 : reg_32
    port map(
      reset   => reset,
      En      => KW2_enable,
      clk     => clk,
      reg_in  => KW2_in,
      reg_out => KW2_out
    );

  key_W3 : reg_32
    port map(
      reset   => reset,
      En      => KW3_enable,
      clk     => clk,
      reg_in  => KW3_in,
      reg_out => KW3_out
    );

  key_W4 : reg_32
    port map(
      reset   => reset,
      En      => KW4_enable,
      clk     => clk,
      reg_in  => KW4_in,
      reg_out => KW4_out
    );

  key_F1 : reg_32
    port map(
      reset   => reset,
      En      => KF1_enable,
      clk     => clk,
      reg_in  => KF1_in,
      reg_out => KF1_out
    );

  key_F2 : reg_32
    port map(
      reset   => reset,
      En      => KF2_enable,
      clk     => clk,
      reg_in  => KF2_in,
      reg_out => KF2_out
    );

end architecture;
