----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : keyschedule_2
-- Fungsi      : melakukan proses keyschedule kedua untuk 
--               menghasilkan subkey-subkey
-- dibuat oleh : Hidayat
-- direvisi    : 17 September 2008
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity keyschedule_2 is
  port (
    seq_B_key_selector  : in  std_logic_vector(11 downto 1);
    AND_OR_out_selector : in  std_logic_vector(3  downto 1);
    seq_A_key_selector  : in  std_logic_vector(9  downto 1);

    KA_in_sch, KB_in_sch, KC_in_sch, KD_in_sch,
    KE_in_sch, KF_in_sch, KG_in_sch                : in  std_logic_vector(31 downto 0);
    K1_in_sch, K2_in_sch, K3_in_sch, K4_in_sch,
    K5_in_sch, K6_in_sch, K7_in_sch, K8_in_sch,
    K9_in_sch, KW1_in_sch, KW2_in_sch, KF1_in_sch   : in  std_logic_vector(31 downto 0);

    KE_out_sch, KF_out_sch, KG_out_sch              : out std_logic_vector(31 downto 0);
    K1_out_sch, K2_out_sch, K3_out_sch, K4_out_sch,
    K5_out_sch, K6_out_sch, K7_out_sch, K8_out_sch,
    K9_out_sch, K10_out_sch, K11_out_sch            : out std_logic_vector(31 downto 0);
    KW1_out_sch, KW2_out_sch, KW3_out_sch, KW4_out_sch: out std_logic_vector(31 downto 0);
    KF1_out_sch, KF2_out_sch                        : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of keyschedule_2 is

  -- component declarations
  component selector_11_to_1
    port (
      in_1        : in  std_logic_vector(31 downto 0);
      in_2        : in  std_logic_vector(31 downto 0);
      in_3        : in  std_logic_vector(31 downto 0);
      in_4        : in  std_logic_vector(31 downto 0);
      in_5        : in  std_logic_vector(31 downto 0);
      in_6        : in  std_logic_vector(31 downto 0);
      in_7        : in  std_logic_vector(31 downto 0);
      in_8        : in  std_logic_vector(31 downto 0);
      in_9        : in  std_logic_vector(31 downto 0);
      in_10       : in  std_logic_vector(31 downto 0);
      in_11       : in  std_logic_vector(31 downto 0);
      sel_11      : in  std_logic_vector(11 downto 1);
      sel_outs_11 : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_3
    port (
      in3_1       : in  std_logic_vector(31 downto 0);
      in3_2       : in  std_logic_vector(31 downto 0);
      in3_3       : in  std_logic_vector(31 downto 0);
      sel_3       : in  std_logic_vector(3  downto 1);
      sel_outs_3  : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_9_to_1
    port (
      in9_1       : in  std_logic_vector(31 downto 0);
      in9_2       : in  std_logic_vector(31 downto 0);
      in9_3       : in  std_logic_vector(31 downto 0);
      in9_4       : in  std_logic_vector(31 downto 0);
      in9_5       : in  std_logic_vector(31 downto 0);
      in9_6       : in  std_logic_vector(31 downto 0);
      in9_7       : in  std_logic_vector(31 downto 0);
      in9_8       : in  std_logic_vector(31 downto 0);
      in9_9       : in  std_logic_vector(31 downto 0);
      sel_9       : in  std_logic_vector(9  downto 1);
      sel_outs_9  : out std_logic_vector(31 downto 0)
    );
  end component;

  component rotr_32
    port (
      in32 : in    std_logic_vector(31 downto 0);
      outs : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_1_to_9
    port (
      in9    : in    std_logic_vector(31 downto 0);
      sel_9  : in    std_logic_vector(9  downto 1);
      out9_1 : out std_logic_vector(31 downto 0);
      out9_2 : out std_logic_vector(31 downto 0);
      out9_3 : out std_logic_vector(31 downto 0);
      out9_4 : out std_logic_vector(31 downto 0);
      out9_5 : out std_logic_vector(31 downto 0);
      out9_6 : out std_logic_vector(31 downto 0);
      out9_7 : out std_logic_vector(31 downto 0);
      out9_8 : out std_logic_vector(31 downto 0);
      out9_9 : out std_logic_vector(31 downto 0)
    );
  end component;

  component selector_1_to_11
    port (
      in11    : in    std_logic_vector(31 downto 0);
      sel_11  : in    std_logic_vector(11 downto 1);
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
  end component;

  -- interconnect signals
  signal sel_outs_B1, sel_outs_B2, sel_outs_B3 : std_logic_vector(31 downto 0);
  signal sel_outs_3                            : std_logic_vector(31 downto 0);
  signal sel_outs_A1, sel_outs_A2, sel_outs_A3 : std_logic_vector(31 downto 0);
  signal outs_or_B, outs_and_B, outs_xor_B     : std_logic_vector(31 downto 0);
  signal rotr_out                              : std_logic_vector(31 downto 0);
  signal outs_and_A, outs_xor_A                : std_logic_vector(31 downto 0);

  -- constants
  constant C1 : std_logic_vector(31 downto 0) := X"D62F59FB";
  constant C2 : std_logic_vector(31 downto 0) := X"D597BEF1";
  constant C3 : std_logic_vector(31 downto 0) := X"E4F92E2D";

begin

  select_11_B1 : selector_11_to_1
    port map (
      in_1        => KC_in_sch,
      in_2        => KA_in_sch,
      in_3        => KF_in_sch,
      in_4        => KE_in_sch,
      in_5        => KW1_in_sch,
      in_6        => K1_in_sch,
      in_7        => K1_in_sch,
      in_8        => K6_in_sch,
      in_9        => C3,
      in_10       => X"00000000",
      in_11       => K9_in_sch,
      sel_11      => seq_B_key_selector,
      sel_outs_11 => sel_outs_B1
    );

  select_11_B2 : selector_11_to_1
    port map (
      in_1        => KD_in_sch,
      in_2        => KB_in_sch,
      in_3        => KG_in_sch,
      in_4        => KF_in_sch,
      in_5        => KW2_in_sch,
      in_6        => KW2_in_sch,
      in_7        => K2_in_sch,
      in_8        => KW2_in_sch,
      in_9        => K3_in_sch,
      in_10       => X"00000000",
      in_11       => K4_in_sch,
      sel_11      => seq_B_key_selector,
      sel_outs_11 => sel_outs_B2
    );

  select_11_B3 : selector_11_to_1
    port map (
      in_1        => KA_in_sch,
      in_2        => KC_in_sch,
      in_3        => KE_in_sch,
      in_4        => KW1_in_sch,
      in_5        => K2_in_sch,
      in_6        => K3_in_sch,
      in_7        => K5_in_sch,
      in_8        => KF1_in_sch,
      in_9        => K7_in_sch,
      in_10       => K3_in_sch,
      in_11       => K6_in_sch,
      sel_11      => seq_B_key_selector,
      sel_outs_11 => sel_outs_B3
    );

  outs_or_B  <= sel_outs_B1 or sel_outs_B2;
  outs_and_B <= sel_outs_B1 and sel_outs_B2;

  rotate_R : rotr_32
    port map (
      in32 => K5_in_sch,
      outs => rotr_out
    );

  select_3 : selector_3
    port map (
      in3_1      => outs_and_B,
      in3_2      => outs_or_B,
      in3_3      => rotr_out,
      sel_3      => AND_OR_out_selector,
      sel_outs_3 => sel_outs_3
    );

  outs_xor_B <= sel_outs_3 xor sel_outs_B3;

  select_9_A1 : selector_9_to_1
    port map (
      in9_1      => KA_in_sch,
      in9_2      => KE_in_sch,
      in9_3      => KE_in_sch,
      in9_4      => C2,
      in9_5      => C1,
      in9_6      => K1_in_sch,
      in9_7      => K3_in_sch,
      in9_8      => K8_in_sch,
      in9_9      => K2_in_sch,
      sel_9      => seq_A_key_selector,
      sel_outs_9 => sel_outs_A1
    );

  select_9_A2 : selector_9_to_1
    port map (
      in9_1      => KB_in_sch,
      in9_2      => KF_in_sch,
      in9_3      => KW2_in_sch,
      in9_4      => KW2_in_sch,
      in9_5      => KE_in_sch,
      in9_6      => K5_in_sch,
      in9_7      => K5_in_sch,
      in9_8      => K4_in_sch,
      in9_9      => K8_in_sch,
      sel_9      => seq_A_key_selector,
      sel_outs_9 => sel_outs_A2
    );

  select_9_A3 : selector_9_to_1
    port map (
      in9_1      => KD_in_sch,
      in9_2      => KG_in_sch,
      in9_3      => KF_in_sch,
      in9_4      => K3_in_sch,
      in9_5      => K4_in_sch,
      in9_6      => K6_in_sch,
      in9_7      => K6_in_sch,
      in9_8      => K5_in_sch,
      in9_9      => K9_in_sch,
      sel_9      => seq_A_key_selector,
      sel_outs_9 => sel_outs_A3
    );

  outs_and_A <= sel_outs_A1 and sel_outs_A2;
  outs_xor_A <= sel_outs_A3 xor outs_and_A;

  select_1_11 : selector_1_to_11
    port map (
      in11       => outs_xor_B,
      sel_11     => seq_B_key_selector,
      out11_1    => KG_out_sch,
      out11_2    => KE_out_sch,
      out11_3    => KW2_out_sch,
      out11_4    => K2_out_sch,
      out11_5    => K3_out_sch,
      out11_6    => K4_out_sch,
      out11_7    => K6_out_sch,
      out11_8    => K7_out_sch,
      out11_9    => K8_out_sch,
      out11_10   => K9_out_sch,
      out11_11   => KW3_out_sch
    );

  select_1_9 : selector_1_to_9
    port map (
      in9        => outs_xor_A,
      sel_9      => seq_A_key_selector,
      out9_1     => KF_out_sch,
      out9_2     => KW1_out_sch,
      out9_3     => K1_out_sch,
      out9_4     => K5_out_sch,
      out9_5     => KF1_out_sch,
      out9_6     => KF2_out_sch,
      out9_7     => K11_out_sch,
      out9_8     => K10_out_sch,
      out9_9     => KW4_out_sch
    );

end architecture;
