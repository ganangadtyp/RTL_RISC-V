----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : Kriptografi_BC3
-- Fungsi      : arsitektur utama algoritma Kriptografi BC3
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Kriptografi_BC3 is
  port (
    reset        : in  std_logic;
    clk          : in  std_logic;
    input_data   : in  std_logic_vector(63 downto 0);
    key_ready    : in  std_logic;
    input_ready  : in  std_logic;
    enc_dec      : in  std_logic;
    data_ack     : in  std_logic;
    output_ready : out std_logic;
    key_done     : out std_logic;
    out_crypto   : out std_logic_vector(63 downto 0)
  );
end entity;

architecture dataflow of Kriptografi_BC3 is

  -- component declarations
  component enk_dek
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
      C1                   : in  std_logic_vector(31 downto 0);
      C2                   : in  std_logic_vector(31 downto 0);
      C3                   : in  std_logic_vector(31 downto 0);
      C4                   : in  std_logic_vector(31 downto 0);
      C5                   : in  std_logic_vector(31 downto 0);
      C6                   : in  std_logic_vector(31 downto 0);
      out_crypto          : out std_logic_vector(63 downto 0)
    );
  end component;

  component keyschedule_2
    port (
      seq_B_key_selector  : in  std_logic_vector(11 downto 1);
      AND_OR_out_selector : in  std_logic_vector(3  downto 1);
      seq_A_key_selector  : in  std_logic_vector(9  downto 1);
      KA_in_sch            : in  std_logic_vector(31 downto 0);
      KB_in_sch            : in  std_logic_vector(31 downto 0);
      KC_in_sch            : in  std_logic_vector(31 downto 0);
      KD_in_sch            : in  std_logic_vector(31 downto 0);
      KE_in_sch            : in  std_logic_vector(31 downto 0);
      KF_in_sch            : in  std_logic_vector(31 downto 0);
      KG_in_sch            : in  std_logic_vector(31 downto 0);
      K1_in_sch            : in  std_logic_vector(31 downto 0);
      K2_in_sch            : in  std_logic_vector(31 downto 0);
      K3_in_sch            : in  std_logic_vector(31 downto 0);
      K4_in_sch            : in  std_logic_vector(31 downto 0);
      K5_in_sch            : in  std_logic_vector(31 downto 0);
      K6_in_sch            : in  std_logic_vector(31 downto 0);
      K7_in_sch            : in  std_logic_vector(31 downto 0);
      K8_in_sch            : in  std_logic_vector(31 downto 0);
      K9_in_sch            : in  std_logic_vector(31 downto 0);
      KW1_in_sch           : in  std_logic_vector(31 downto 0);
      KW2_in_sch           : in  std_logic_vector(31 downto 0);
      KF1_in_sch           : in  std_logic_vector(31 downto 0);
      KE_out_sch           : out std_logic_vector(31 downto 0);
      KF_out_sch           : out std_logic_vector(31 downto 0);
      KG_out_sch           : out std_logic_vector(31 downto 0);
      K1_out_sch           : out std_logic_vector(31 downto 0);
      K2_out_sch           : out std_logic_vector(31 downto 0);
      K3_out_sch           : out std_logic_vector(31 downto 0);
      K4_out_sch           : out std_logic_vector(31 downto 0);
      K5_out_sch           : out std_logic_vector(31 downto 0);
      K6_out_sch           : out std_logic_vector(31 downto 0);
      K7_out_sch           : out std_logic_vector(31 downto 0);
      K8_out_sch           : out std_logic_vector(31 downto 0);
      K9_out_sch           : out std_logic_vector(31 downto 0);
      K10_out_sch          : out std_logic_vector(31 downto 0);
      K11_out_sch          : out std_logic_vector(31 downto 0);
      KW1_out_sch          : out std_logic_vector(31 downto 0);
      KW2_out_sch          : out std_logic_vector(31 downto 0);
      KW3_out_sch          : out std_logic_vector(31 downto 0);
      KW4_out_sch          : out std_logic_vector(31 downto 0);
      KF1_out_sch          : out std_logic_vector(31 downto 0);
      KF2_out_sch          : out std_logic_vector(31 downto 0)
    );
  end component;

  component FSM_keyschedule_1
    port (
      reset                : in  std_logic;
      clk                  : in  std_logic;
      sche_1_enable        : in  std_logic;
      sche_1_ok            : out std_logic;
      data_selector        : out std_logic_vector(4 downto 1);
      keymaster1_en        : out std_logic;
      keymaster2_en        : out std_logic;
      KW_first_selector    : out std_logic;
      KW_last_selector     : out std_logic_vector(4 downto 1);
      XOR_pre_fround       : out std_logic;
      XOR_last_fround      : out std_logic;
      const_selector       : out std_logic_vector(6 downto 1);
      key_selector         : out std_logic;
      out_enable           : out std_logic;
      KAKB_enable          : out std_logic;
      KCKD_enable          : out std_logic
    );
  end component;

  component FSM_keyschedule_2
    port (
      reset                : in  std_logic;
      clk                  : in  std_logic;
      sche_2_enable        : in  std_logic;
      sche_2_ok            : out std_logic;
      seq_B_key_selector   : out std_logic_vector(11 downto 1);
      AND_OR_out_selector  : out std_logic_vector(3  downto 1);
      seq_A_key_selector   : out std_logic_vector(9  downto 1);
      KE_enable            : out std_logic;
      KF_enable            : out std_logic;
      KG_enable            : out std_logic;
      K1_enable            : out std_logic;
      K2_enable            : out std_logic;
      K3_enable            : out std_logic;
      K4_enable            : out std_logic;
      K5_enable            : out std_logic;
      K6_enable            : out std_logic;
      K7_enable            : out std_logic;
      K8_enable            : out std_logic;
      K9_enable            : out std_logic;
      K10_enable           : out std_logic;
      K11_enable           : out std_logic;
      KW1_enable           : out std_logic;
      KW2_enable           : out std_logic;
      KW3_enable           : out std_logic;
      KW4_enable           : out std_logic;
      KF1_enable           : out std_logic;
      KF2_enable           : out std_logic
    );
  end component;

  component subkey_reg
    port (
      reset           : in  std_logic;
      clk             : in  std_logic;
      KA_in           : in  std_logic_vector(31 downto 0);
      KB_in           : in  std_logic_vector(31 downto 0);
      KC_in           : in  std_logic_vector(31 downto 0);
      KD_in           : in  std_logic_vector(31 downto 0);
      KE_in           : in  std_logic_vector(31 downto 0);
      KF_in           : in  std_logic_vector(31 downto 0);
      KG_in           : in  std_logic_vector(31 downto 0);
      K1_in           : in  std_logic_vector(31 downto 0);
      K2_in           : in  std_logic_vector(31 downto 0);
      K3_in           : in  std_logic_vector(31 downto 0);
      K4_in           : in  std_logic_vector(31 downto 0);
      K5_in           : in  std_logic_vector(31 downto 0);
      K6_in           : in  std_logic_vector(31 downto 0);
      K7_in           : in  std_logic_vector(31 downto 0);
      K8_in           : in  std_logic_vector(31 downto 0);
      K9_in           : in  std_logic_vector(31 downto 0);
      K10_in          : in  std_logic_vector(31 downto 0);
      K11_in          : in  std_logic_vector(31 downto 0);
      KW1_in          : in  std_logic_vector(31 downto 0);
      KW2_in          : in  std_logic_vector(31 downto 0);
      KW3_in          : in  std_logic_vector(31 downto 0);
      KW4_in          : in  std_logic_vector(31 downto 0);
      KF1_in          : in  std_logic_vector(31 downto 0);
      KF2_in          : in  std_logic_vector(31 downto 0);
      KA_enable       : in  std_logic;
      KB_enable       : in  std_logic;
      KC_enable       : in  std_logic;
      KD_enable       : in  std_logic;
      KE_enable       : in  std_logic;
      KF_enable       : in  std_logic;
      KG_enable       : in  std_logic;
      K1_enable       : in  std_logic;
      K2_enable       : in  std_logic;
      K3_enable       : in  std_logic;
      K4_enable       : in  std_logic;
      K5_enable       : in  std_logic;
      K6_enable       : in  std_logic;
      K7_enable       : in  std_logic;
      K8_enable       : in  std_logic;
      K9_enable       : in  std_logic;
      K10_enable      : in  std_logic;
      K11_enable      : in  std_logic;
      KW1_enable      : in  std_logic;
      KW2_enable      : in  std_logic;
      KW3_enable      : in  std_logic;
      KW4_enable      : in  std_logic;
      KF1_enable      : in  std_logic;
      KF2_enable      : in  std_logic;
      KA_out          : out std_logic_vector(31 downto 0);
      KB_out          : out std_logic_vector(31 downto 0);
      KC_out          : out std_logic_vector(31 downto 0);
      KD_out          : out std_logic_vector(31 downto 0);
      KE_out          : out std_logic_vector(31 downto 0);
      KF_out          : out std_logic_vector(31 downto 0);
      KG_out          : out std_logic_vector(31 downto 0);
      K1_out          : out std_logic_vector(31 downto 0);
      K2_out          : out std_logic_vector(31 downto 0);
      K3_out          : out std_logic_vector(31 downto 0);
      K4_out          : out std_logic_vector(31 downto 0);
      K5_out          : out std_logic_vector(31 downto 0);
      K6_out          : out std_logic_vector(31 downto 0);
      K7_out          : out std_logic_vector(31 downto 0);
      K8_out          : out std_logic_vector(31 downto 0);
      K9_out          : out std_logic_vector(31 downto 0);
      K10_out         : out std_logic_vector(31 downto 0);
      K11_out         : out std_logic_vector(31 downto 0);
      KW1_out         : out std_logic_vector(31 downto 0);
      KW2_out         : out std_logic_vector(31 downto 0);
      KW3_out         : out std_logic_vector(31 downto 0);
      KW4_out         : out std_logic_vector(31 downto 0);
      KF1_out         : out std_logic_vector(31 downto 0);
      KF2_out         : out std_logic_vector(31 downto 0)
    );
  end component;

  component FSM_enkripsi
    port (
      reset             : in  std_logic;
      clk               : in  std_logic;
      enc_enable        : in  std_logic;
      enc_ok            : out std_logic;
      data_selector     : out std_logic_vector(4 downto 1);
      KW_first_selector : out std_logic;
      KW_last_selector  : out std_logic_vector(4 downto 1);
      XOR_pre_fround    : out std_logic;
      XOR_last_fround   : out std_logic;
      subkey_selector   : out std_logic_vector(11 downto 1);
      key_selector      : out std_logic;
      function_selector : out std_logic;
      out_enable        : out std_logic
    );
  end component;

  component FSM_dekripsi
    port (
      reset             : in  std_logic;
      clk               : in  std_logic;
      dec_enable        : in  std_logic;
      dec_ok            : out std_logic;
      data_selector     : out std_logic_vector(4 downto 1);
      KW_first_selector : out std_logic;
      KW_last_selector  : out std_logic_vector(4 downto 1);
      XOR_pre_fround    : out std_logic;
      XOR_last_fround   : out std_logic;
      subkey_selector   : out std_logic_vector(11 downto 1);
      key_selector      : out std_logic;
      function_selector : out std_logic;
      out_enable        : out std_logic
    );
  end component;

  component FSM_utama
    port (
      reset          : in  std_logic;
      clk            : in  std_logic;
      key_ready      : in  std_logic;
      input_ready    : in  std_logic;
      enc_dec        : in  std_logic;
      data_ack       : in  std_logic;
      sche_1_ok      : in  std_logic;
      sche_2_ok      : in  std_logic;
      enc_ok         : in  std_logic;
      dec_ok         : in  std_logic;
      sche_1_enable  : out std_logic;
      sche_2_enable  : out std_logic;
      enc_enable     : out std_logic;
      dec_enable     : out std_logic;
      output_ready   : out std_logic
    );
  end component;

  -- interconnect & control signals
  signal data_selector      : std_logic_vector(4 downto 1);
  signal data_selector_sche : std_logic_vector(4 downto 1);
  signal data_selector_enc  : std_logic_vector(4 downto 1);
  signal data_selector_dec  : std_logic_vector(4 downto 1);

  signal keymaster1_en        : std_logic;
  signal keymaster2_en        : std_logic;

  signal KW_first_selector    : std_logic;
  signal KW_first_selector_sche : std_logic;
  signal KW_first_selector_enc  : std_logic;
  signal KW_first_selector_dec  : std_logic;

  signal KW_last_selector     : std_logic_vector(4 downto 1);
  signal KW_last_selector_sche : std_logic_vector(4 downto 1);
  signal KW_last_selector_enc  : std_logic_vector(4 downto 1);
  signal KW_last_selector_dec  : std_logic_vector(4 downto 1);

    signal C1 : std_logic_vector(31 downto 0) := x"D62F59FB";
    signal C2 : std_logic_vector(31 downto 0) := x"D597BEF1";
    signal C3 : std_logic_vector(31 downto 0) := x"E4F92E2D";
    signal C4 : std_logic_vector(31 downto 0) := x"FF6EC9AB";
    signal C5 : std_logic_vector(31 downto 0) := x"F2DCE89B";
    signal C6 : std_logic_vector(31 downto 0) := x"636CB246";

  signal XOR_pre_fround       : std_logic;
  signal XOR_pre_fround_sche  : std_logic;
  signal XOR_pre_fround_enc   : std_logic;
  signal XOR_pre_fround_dec   : std_logic;

  signal XOR_last_fround      : std_logic;
  signal XOR_last_fround_sche : std_logic;
  signal XOR_last_fround_enc  : std_logic;
  signal XOR_last_fround_dec  : std_logic;

  signal const_selector       : std_logic_vector(6 downto 1);

  signal subkey_selector      : std_logic_vector(11 downto 1);
  signal subkey_selector_enc  : std_logic_vector(11 downto 1);
  signal subkey_selector_dec  : std_logic_vector(11 downto 1);

  signal key_selector         : std_logic;
  signal key_selector_sche    : std_logic;
  signal key_selector_enc     : std_logic;
  signal key_selector_dec     : std_logic;

  signal function_selector    : std_logic;
  signal function_selector_enc: std_logic;
  signal function_selector_dec: std_logic;

  signal out_enable           : std_logic;
  signal out_enable_sche      : std_logic;
  signal out_enable_enc       : std_logic;  
  signal out_enable_dec       : std_logic;

  signal KAKB_enable, KCKD_enable : std_logic;

  signal seq_B_key_selector   : std_logic_vector(11 downto 1);
  signal AND_OR_out_selector  : std_logic_vector(3  downto 1);
  signal seq_A_key_selector   : std_logic_vector(9  downto 1);

  signal KA_enable, KB_enable, KC_enable, KD_enable : std_logic;
  signal KE_enable, KF_enable, KG_enable            : std_logic;
  signal K1_enable, K2_enable, K3_enable, K4_enable : std_logic;
  signal K5_enable, K6_enable, K7_enable, K8_enable : std_logic;
  signal K9_enable, K10_enable, K11_enable           : std_logic;
  signal KW1_enable, KW2_enable, KW3_enable, KW4_enable : std_logic;
  signal KF1_enable, KF2_enable                       : std_logic;

  signal KA_in, KB_in, KC_in, KD_in             : std_logic_vector(31 downto 0);
  signal KE_in, KF_in, KG_in                   : std_logic_vector(31 downto 0);
  signal K1_in, K2_in, K3_in, K4_in             : std_logic_vector(31 downto 0);
  signal K5_in, K6_in, K7_in, K8_in             : std_logic_vector(31 downto 0);
  signal K9_in, K10_in, K11_in                  : std_logic_vector(31 downto 0);
  signal KW1_in, KW2_in, KW3_in, KW4_in         : std_logic_vector(31 downto 0);
  signal KF1_in, KF2_in                         : std_logic_vector(31 downto 0);

  signal KA_out, KB_out, KC_out, KD_out         : std_logic_vector(31 downto 0);
  signal KE_out, KF_out, KG_out                 : std_logic_vector(31 downto 0);
  signal K1_out, K2_out, K3_out, K4_out         : std_logic_vector(31 downto 0);
  signal K5_out, K6_out, K7_out, K8_out         : std_logic_vector(31 downto 0);
  signal K9_out, K10_out, K11_out                : std_logic_vector(31 downto 0);
  signal KW1_out, KW2_out, KW3_out, KW4_out     : std_logic_vector(31 downto 0);
  signal KF1_out, KF2_out                       : std_logic_vector(31 downto 0);

  signal enc_enable, dec_enable, sche_1_enable, sche_2_enable : std_logic;
  signal enc_ok, dec_ok, sche_1_ok, sche_2_ok                 : std_logic;
  signal s_out_crypto   : std_logic_vector(63 downto 0);
begin

  -- combine controllers from each FSM
  data_selector   <= data_selector_sche or data_selector_enc   or data_selector_dec;
  key_selector    <= key_selector_sche    or key_selector_enc    or key_selector_dec;
  KW_first_selector <= KW_first_selector_sche or KW_first_selector_enc or KW_first_selector_dec;
  KW_last_selector  <= KW_last_selector_sche  or KW_last_selector_enc  or KW_last_selector_dec;
  XOR_pre_fround    <= XOR_pre_fround_sche    or XOR_pre_fround_enc    or XOR_pre_fround_dec;
  XOR_last_fround   <= XOR_last_fround_sche   or XOR_last_fround_enc   or XOR_last_fround_dec;
  function_selector <= function_selector_enc  or function_selector_dec;
  subkey_selector   <= subkey_selector_enc    or subkey_selector_dec;
  out_enable        <= out_enable_sche       or out_enable_enc        or out_enable_dec;
  key_done          <= sche_2_ok;

  -- 1) initial key-schedule, encrypt/decrypt core
  key_1 : enk_dek
    port map(
      reset             => reset,
      clk               => clk,
      input_data        => input_data,
      data_selector     => data_selector,
      keymaster1_en     => keymaster1_en,
      keymaster2_en     => keymaster2_en,
      KW_first_selector => KW_first_selector,
      KW_last_selector  => KW_last_selector,
      XOR_pre_fround    => XOR_pre_fround,
      XOR_last_fround   => XOR_last_fround,
      const_selector    => const_selector,
      subkey_selector   => subkey_selector,
      key_selector      => key_selector,
      function_selector => function_selector,
      out_enable        => out_enable,
      K1_in_crypto      => K1_out,
      K2_in_crypto      => K2_out,
      K3_in_crypto      => K3_out,
      K4_in_crypto      => K4_out,
      K5_in_crypto      => K5_out,
      K6_in_crypto      => K6_out,
      K7_in_crypto      => K7_out,
      K8_in_crypto      => K8_out,
      K9_in_crypto      => K9_out,
      K10_in_crypto     => K10_out,
      K11_in_crypto     => K11_out,
      KW1_in_crypto     => KW1_out,
      KW2_in_crypto     => KW2_out,
      KW3_in_crypto     => KW3_out,
      KW4_in_crypto     => KW4_out,
      KF1_in_crypto     => KF1_out,
      KF2_in_crypto     => KF2_out,
      C1                => C1,
      C2                => C2,
      C3                => C3,
      C4                => C4,
      C5                => C5,
      C6                => C6,
      out_crypto        => s_out_crypto
    );

  -- distribute key input for second schedule
  KB_in <= s_out_crypto(63 downto 32);
  KA_in <= s_out_crypto(31 downto  0);
  KD_in <= s_out_crypto(63 downto 32);
  KC_in <= s_out_crypto(31 downto  0);
  out_crypto <= s_out_crypto;

  -- 2) second key-schedule
  keysh_2 : keyschedule_2
    port map(
      seq_B_key_selector  => seq_B_key_selector,
      AND_OR_out_selector => AND_OR_out_selector,
      seq_A_key_selector  => seq_A_key_selector,
      KA_in_sch            => KA_out,
      KB_in_sch            => KB_out,
      KC_in_sch            => KC_out,
      KD_in_sch            => KD_out,
      KE_in_sch            => KE_out,
      KF_in_sch            => KF_out,
      KG_in_sch            => KG_out,
      K1_in_sch            => K1_out,
      K2_in_sch            => K2_out,
      K3_in_sch            => K3_out,
      K4_in_sch            => K4_out,
      K5_in_sch            => K5_out,
      K6_in_sch            => K6_out,
      K7_in_sch            => K7_out,
      K8_in_sch            => K8_out,
      K9_in_sch            => K9_out,
      KW1_in_sch           => KW1_out,
      KW2_in_sch           => KW2_out,
      KF1_in_sch           => KF1_out,
      KE_out_sch           => KE_in,
      KF_out_sch           => KF_in,
      KG_out_sch           => KG_in,
      K1_out_sch           => K1_in,
      K2_out_sch           => K2_in,
      K3_out_sch           => K3_in,
      K4_out_sch           => K4_in,
      K5_out_sch           => K5_in,
      K6_out_sch           => K6_in,
      K7_out_sch           => K7_in,
      K8_out_sch           => K8_in,
      K9_out_sch           => K9_in,
      K10_out_sch          => K10_in,
      K11_out_sch          => K11_in,
      KW1_out_sch          => KW1_in,
      KW2_out_sch          => KW2_in,
      KW3_out_sch          => KW3_in,
      KW4_out_sch          => KW4_in,
      KF1_out_sch          => KF1_in,
      KF2_out_sch          => KF2_in
    );

  -- 3) FSM for first key-schedule
  fsm_1 : FSM_keyschedule_1
    port map(
      reset              => reset,
      clk                => clk,
      sche_1_enable      => sche_1_enable,
      sche_1_ok          => sche_1_ok,
      data_selector      => data_selector_sche,
      keymaster1_en      => keymaster1_en,
      keymaster2_en      => keymaster2_en,
      KW_first_selector  => KW_first_selector_sche,
      KW_last_selector   => KW_last_selector_sche,
      XOR_pre_fround     => XOR_pre_fround_sche,
      XOR_last_fround    => XOR_last_fround_sche,
      const_selector     => const_selector,
      key_selector       => key_selector_sche,
      out_enable         => out_enable_sche,
      KAKB_enable        => KAKB_enable,
      KCKD_enable        => KCKD_enable
    );

  -- propagate enables to registers
  KA_enable <= KAKB_enable;
  KB_enable <= KAKB_enable;
  KC_enable <= KCKD_enable;
  KD_enable <= KCKD_enable;

  -- 4) FSM for second key-schedule
  fsm_2 : FSM_keyschedule_2
    port map(
      reset                => reset,
      clk                  => clk,
      sche_2_enable        => sche_2_enable,
      sche_2_ok            => sche_2_ok,
      seq_B_key_selector   => seq_B_key_selector,
      AND_OR_out_selector  => AND_OR_out_selector,
      seq_A_key_selector   => seq_A_key_selector,
      KE_enable            => KE_enable,
      KF_enable            => KF_enable,
      KG_enable            => KG_enable,
      K1_enable            => K1_enable,
      K2_enable            => K2_enable,
      K3_enable            => K3_enable,
      K4_enable            => K4_enable,
      K5_enable            => K5_enable,
      K6_enable            => K6_enable,
      K7_enable            => K7_enable,
      K8_enable            => K8_enable,
      K9_enable            => K9_enable,
      K10_enable           => K10_enable,
      K11_enable           => K11_enable,
      KW1_enable           => KW1_enable,
      KW2_enable           => KW2_enable,
      KW3_enable           => KW3_enable,
      KW4_enable           => KW4_enable,
      KF1_enable           => KF1_enable,
      KF2_enable           => KF2_enable
    );

  -- 5) registers to store subkeys
  regis : subkey_reg
    port map(
      reset   => reset,
      clk     => clk,
      KA_in   => KA_in,
      KB_in   => KB_in,
      KC_in   => KC_in,
      KD_in   => KD_in,
      KE_in   => KE_in,
      KF_in   => KF_in,
      KG_in   => KG_in,
      K1_in   => K1_in,
      K2_in   => K2_in,
      K3_in   => K3_in,
      K4_in   => K4_in,
      K5_in   => K5_in,
      K6_in   => K6_in,
      K7_in   => K7_in,
      K8_in   => K8_in,
      K9_in   => K9_in,
      K10_in  => K10_in,
      K11_in  => K11_in,
      KW1_in  => KW1_in,
      KW2_in  => KW2_in,
      KW3_in  => KW3_in,
      KW4_in  => KW4_in,
      KF1_in  => KF1_in,
      KF2_in  => KF2_in,
      KA_enable => KA_enable,
      KB_enable => KB_enable,
      KC_enable => KC_enable,
      KD_enable => KD_enable,
      KE_enable => KE_enable,
      KF_enable => KF_enable,
      KG_enable => KG_enable,
      K1_enable => K1_enable,
      K2_enable => K2_enable,
      K3_enable => K3_enable,
      K4_enable => K4_enable,
      K5_enable => K5_enable,
      K6_enable => K6_enable,
      K7_enable => K7_enable,
      K8_enable => K8_enable,
      K9_enable => K9_enable,
      K10_enable=> K10_enable,
      K11_enable=> K11_enable,
      KW1_enable=> KW1_enable,
      KW2_enable=> KW2_enable,
      KW3_enable=> KW3_enable,
      KW4_enable=> KW4_enable,
      KF1_enable=> KF1_enable,
      KF2_enable=> KF2_enable,
      KA_out   => KA_out,
      KB_out   => KB_out,
      KC_out   => KC_out,
      KD_out   => KD_out,
      KE_out   => KE_out,
      KF_out   => KF_out,
      KG_out   => KG_out,
      K1_out   => K1_out,
      K2_out   => K2_out,
      K3_out   => K3_out,
      K4_out   => K4_out,
      K5_out   => K5_out,
      K6_out   => K6_out,
      K7_out   => K7_out,
      K8_out   => K8_out,
      K9_out   => K9_out,
      K10_out  => K10_out,
      K11_out  => K11_out,
      KW1_out  => KW1_out,
      KW2_out  => KW2_out,
      KW3_out  => KW3_out,
      KW4_out  => KW4_out,
      KF1_out  => KF1_out,
      KF2_out  => KF2_out
    );

  -- 6) FSM for encryption
  fsm_enc : FSM_enkripsi
    port map(
      reset              => reset,
      clk                => clk,
      enc_enable         => enc_enable,
      enc_ok             => enc_ok,
      data_selector      => data_selector_enc,
      KW_first_selector  => KW_first_selector_enc,
      KW_last_selector   => KW_last_selector_enc,
      XOR_pre_fround     => XOR_pre_fround_enc,
      XOR_last_fround    => XOR_last_fround_enc,
      subkey_selector    => subkey_selector_enc,
      key_selector       => key_selector_enc,
      function_selector  => function_selector_enc,
      out_enable         => out_enable_enc
    );

  -- 7) FSM for decryption
  fsm_dec : FSM_dekripsi
    port map(
      reset              => reset,
      clk                => clk,
      dec_enable         => dec_enable,
      dec_ok             => dec_ok,
      data_selector      => data_selector_dec,
      KW_first_selector  => KW_first_selector_dec,
      KW_last_selector   => KW_last_selector_dec,
      XOR_pre_fround     => XOR_pre_fround_dec,
      XOR_last_fround    => XOR_last_fround_dec,
      subkey_selector    => subkey_selector_dec,
      key_selector       => key_selector_dec,
      function_selector  => function_selector_dec,
      out_enable         => out_enable_dec
    );

  -- 8) Main FSM
  fsm_ut : FSM_utama
    port map(
      reset          => reset,
      clk            => clk,
      key_ready      => key_ready,
      input_ready    => input_ready,
      enc_dec        => enc_dec,
      data_ack       => data_ack,
      sche_1_ok      => sche_1_ok,
      sche_2_ok      => sche_2_ok,
      enc_ok         => enc_ok,
      dec_ok         => dec_ok,
      sche_1_enable  => sche_1_enable,
      sche_2_enable  => sche_2_enable,
      enc_enable     => enc_enable,
      dec_enable     => dec_enable,
      output_ready   => output_ready
    );

end architecture;
