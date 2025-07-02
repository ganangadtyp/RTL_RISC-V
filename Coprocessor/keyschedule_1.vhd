----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : enk_dek
-- Fungsi      : 
--   1. melakukan proses keyschedule awal untuk menghasilkan subkey KA, KB, KC, KD
--   2. melakukan proses enkripsi dan dekripsi
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity enk_dek is
  port (
    reset               : in  std_logic;
    clk                 : in  std_logic;
    input_data          : in  std_logic_vector(63 downto 0);
    data_selector       : in  std_logic_vector(4 downto 1);
    keymaster1_en       : in  std_logic;
    keymaster2_en       : in  std_logic;
    KW_first_selector   : in  std_logic;
    KW_last_selector    : in  std_logic_vector(4 downto 1);
    XOR_pre_fround      : in  std_logic;
    XOR_last_fround     : in  std_logic;
    const_selector      : in  std_logic_vector(6 downto 1);
    subkey_selector     : in  std_logic_vector(11 downto 1);
    key_selector        : in  std_logic;
    function_selector   : in  std_logic;
    out_enable          : in  std_logic;

    K1_in_crypto        : in  std_logic_vector(31 downto 0);
    K2_in_crypto        : in  std_logic_vector(31 downto 0);
    K3_in_crypto        : in  std_logic_vector(31 downto 0);
    K4_in_crypto        : in  std_logic_vector(31 downto 0);
    K5_in_crypto        : in  std_logic_vector(31 downto 0);
    K6_in_crypto        : in  std_logic_vector(31 downto 0);
    K7_in_crypto        : in  std_logic_vector(31 downto 0);
    K8_in_crypto        : in  std_logic_vector(31 downto 0);
    K9_in_crypto        : in  std_logic_vector(31 downto 0);
    K10_in_crypto       : in  std_logic_vector(31 downto 0);
    K11_in_crypto       : in  std_logic_vector(31 downto 0);
    KW1_in_crypto       : in  std_logic_vector(31 downto 0);
    KW2_in_crypto       : in  std_logic_vector(31 downto 0);
    KW3_in_crypto       : in  std_logic_vector(31 downto 0);
    KW4_in_crypto       : in  std_logic_vector(31 downto 0);
    KF1_in_crypto       : in  std_logic_vector(31 downto 0);
    KF2_in_crypto       : in  std_logic_vector(31 downto 0);
    C1, C2, C3, C4, C5, C6 : in std_logic_vector(31 downto 0);

    out_crypto          : out std_logic_vector(63 downto 0)
  );
end entity;

architecture dataflow of enk_dek is

  -- component declarations
  component selector_4_64bit
    port (
      in64_1      : in  std_logic_vector(63 downto 0);
      in64_2      : in  std_logic_vector(63 downto 0);
      in64_3      : in  std_logic_vector(63 downto 0);
      in64_4      : in  std_logic_vector(63 downto 0);
      sel64_4     : in  std_logic_vector(4 downto 1);
      sel64_outs_4: out std_logic_vector(63 downto 0)
    );
  end component;

  component reg_64
    port (
      reset   : in  std_logic;
      en      : in  std_logic;
      clk     : in  std_logic;
      reg64_in : in  std_logic_vector(63 downto 0);
      reg64_out: out std_logic_vector(63 downto 0)
    );
  end component;

  component selector_2
    port (
      in_1      : in  std_logic_vector(31 downto 0);
      in_2      : in  std_logic_vector(31 downto 0);
      sel_2     : in  std_logic;
      sel_outs_2: out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_6_to_1
    port (
      in6_1      : in std_logic_vector(31 downto 0);
      in6_2      : in std_logic_vector(31 downto 0);
      in6_3      : in std_logic_vector(31 downto 0);
      in6_4      : in std_logic_vector(31 downto 0);
      in6_5      : in std_logic_vector(31 downto 0);
      in6_6      : in std_logic_vector(31 downto 0);
      sel_6      : in std_logic_vector(6 downto 1);
      sel_outs_6 : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_11_to_1
    port (
      in_1        : in std_logic_vector(31 downto 0);
      in_2        : in std_logic_vector(31 downto 0);
      in_3        : in std_logic_vector(31 downto 0);
      in_4        : in std_logic_vector(31 downto 0);
      in_5        : in std_logic_vector(31 downto 0);
      in_6        : in std_logic_vector(31 downto 0);
      in_7        : in std_logic_vector(31 downto 0);
      in_8        : in std_logic_vector(31 downto 0);
      in_9        : in std_logic_vector(31 downto 0);
      in_10       : in std_logic_vector(31 downto 0);
      in_11       : in std_logic_vector(31 downto 0);
      sel_11      : in std_logic_vector(11 downto 1);
      sel_outs_11 : out std_logic_vector(31 downto 0)
    );
  end component;

  component fround
    port (
      fround_left_in  : in std_logic_vector(31 downto 0);
      fround_right_in : in std_logic_vector(31 downto 0);
      subkey          : in std_logic_vector(31 downto 0);
      fround_out      : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_4
    port (
      in_1       : in std_logic_vector(31 downto 0);
      in_2       : in std_logic_vector(31 downto 0);
      in_3       : in std_logic_vector(31 downto 0);
      in_4       : in std_logic_vector(31 downto 0);
      sel_4      : in std_logic_vector(4 downto 1);
      sel_outs_4 : out std_logic_vector(31 downto 0)
    );
  end component;

  component spec_function
    port (
      in_left          : in std_logic_vector(31 downto 0);
      in_right         : in std_logic_vector(31 downto 0);
      KF1_in_crypto    : in std_logic_vector(31 downto 0);
      KF2_in_crypto    : in std_logic_vector(31 downto 0);
      function_selector: in std_logic;
      out_function     : out std_logic_vector(63 downto 0)
    );
  end component;

  -- internal signals
  signal xor_out64, select64_out            : std_logic_vector(63 downto 0);
  signal out_buffer, out_function, out_crypto_tmp : std_logic_vector(63 downto 0);
  signal reg64_out_left, reg64_out_right    : std_logic_vector(63 downto 0);
  signal KW_out_left, KW_out_right          : std_logic_vector(31 downto 0);
  signal KW_xor_out_left, KW_xor_out_right  : std_logic_vector(31 downto 0);
  signal pre_fround_out_left, pre_fround_out_right: std_logic_vector(31 downto 0);
  signal active_subkey                      : std_logic_vector(31 downto 0);
  signal const_out, subkey_out              : std_logic_vector(31 downto 0);
  signal fround_out                          : std_logic_vector(31 downto 0);
  signal KW_last_out_left, KW_last_out_right: std_logic_vector(31 downto 0);
  signal xor_last_left, xor_last_right      : std_logic_vector(31 downto 0);
  signal xor_last_out_left, xor_last_out_right: std_logic_vector(31 downto 0);

begin

  -- 1) select 64-bit portion of input_data
  select_input : selector_4_64bit
    port map (
      in64_1       => input_data,
      in64_2       => xor_out64,
      in64_3       => out_function,
      in64_4       => out_buffer,
      sel64_4      => data_selector,
      sel64_outs_4 => select64_out
    );

  -- 2) two 64-bit registers
  reg64_left : reg_64
    port map (
      reset   => reset,
      en      => keymaster2_en,
      clk     => clk,
      reg64_in=> select64_out,
      reg64_out=> reg64_out_left
    );

  reg64_right : reg_64
    port map (
      reset    => reset,
      en       => keymaster1_en,
      clk      => clk,
      reg64_in => select64_out,
      reg64_out=> reg64_out_right
    );

  xor_out64 <= reg64_out_left xor reg64_out_right;

  -- 3) KW mixing stage 1
  sel_left1 : selector_2
    port map (
      in_1       => KW1_in_crypto,
      in_2       => KW3_in_crypto,
      sel_2      => KW_first_selector,
      sel_outs_2 => KW_out_left
    );

  sel_right1 : selector_2
    port map (
      in_1       => KW2_in_crypto,
      in_2       => KW4_in_crypto,
      sel_2      => KW_first_selector,
      sel_outs_2 => KW_out_right
    );

  KW_xor_out_left  <= KW_out_left  xor select64_out(63 downto 32);
  KW_xor_out_right <= KW_out_right xor select64_out(31 downto  0);

  -- 4) KW mixing stage 2 (pre-fround)
  sel_left2 : selector_2
    port map (
      in_1       => KW_xor_out_left,
      in_2       => select64_out(63 downto 32),
      sel_2      => XOR_pre_fround,
      sel_outs_2 => pre_fround_out_left
    );

  sel_right2 : selector_2
    port map (
      in_1       => KW_xor_out_right,
      in_2       => select64_out(31 downto  0),
      sel_2      => XOR_pre_fround,
      sel_outs_2 => pre_fround_out_right
    );

  -- 5) constant selection
  select_const : selector_6_to_1
    port map (
      in6_1      => C1,
      in6_2      => C2,
      in6_3      => C3,
      in6_4      => C4,
      in6_5      => C5,
      in6_6      => C6,
      sel_6      => const_selector,
      sel_outs_6 => const_out
    );

  -- 6) subkey selection
  select_subkey : selector_11_to_1
    port map (
      in_1        => K1_in_crypto,
      in_2        => K2_in_crypto,
      in_3        => K3_in_crypto,
      in_4        => K4_in_crypto,
      in_5        => K5_in_crypto,
      in_6        => K6_in_crypto,
      in_7        => K7_in_crypto,
      in_8        => K8_in_crypto,
      in_9        => K9_in_crypto,
      in_10       => K10_in_crypto,
      in_11       => K11_in_crypto,
      sel_11      => subkey_selector,
      sel_outs_11 => subkey_out
    );

  sel_active_subkey : selector_2
    port map (
      in_1       => subkey_out,
      in_2       => const_out,
      sel_2      => key_selector,
      sel_outs_2 => active_subkey
    );

  -- 7) forward round
  frounde : fround
    port map (
      fround_left_in  => pre_fround_out_left,
      fround_right_in => pre_fround_out_right,
      subkey          => active_subkey,
      fround_out      => fround_out
    );

  -- 8) KW last mixing
  select_4_left : selector_4
    port map (
      in_1       => reg64_out_left(63 downto 32),
      in_2       => reg64_out_right(63 downto 32),
      in_3       => KW1_in_crypto,
      in_4       => KW3_in_crypto,
      sel_4      => KW_last_selector,
      sel_outs_4 => KW_last_out_left
    );

  select_4_right : selector_4
    port map (
      in_1       => reg64_out_left(31 downto  0),
      in_2       => reg64_out_right(31 downto  0),
      in_3       => KW2_in_crypto,
      in_4       => KW4_in_crypto,
      sel_4      => KW_last_selector,
      sel_outs_4 => KW_last_out_right
    );

  xor_last_left   <= fround_out              xor KW_last_out_left;
  xor_last_right  <= pre_fround_out_right   xor KW_last_out_right;

  sel_left3 : selector_2
    port map (
      in_1       => xor_last_left,
      in_2       => fround_out,
      sel_2      => XOR_last_fround,
      sel_outs_2 => xor_last_out_left
    );

  sel_right3 : selector_2
    port map (
      in_1       => xor_last_right,
      in_2       => pre_fround_out_right,
      sel_2      => XOR_last_fround,
      sel_outs_2 => xor_last_out_right
    );

  -- 9) final output register and byte-swap
   out_crypto_tmp(63 downto 32) <= xor_last_out_right;
   out_crypto_tmp(31 downto 0) <= xor_last_out_left;

  reg64_output : reg_64
    port map (
      reset    => reset,
      en       => out_enable,
      clk      => clk,
      reg64_in => out_crypto_tmp,
      reg64_out=> out_buffer
    );

  out_crypto(63 downto 32) <= out_buffer(31 downto  0);
  out_crypto(31 downto  0) <= out_buffer(63 downto 32);

  -- 10) final function/FA or FA-inverse
  FA_or_FAinv : spec_function
    port map (
      in_left          => out_buffer(63 downto 32),
      in_right         => out_buffer(31 downto  0),
      KF1_in_crypto    => KF1_in_crypto,
      KF2_in_crypto    => KF2_in_crypto,
      function_selector=> function_selector,
      out_function     => out_function
    );

end architecture;
