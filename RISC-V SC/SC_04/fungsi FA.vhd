----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : spec_function
-- Fungsi      : fungsi khusus FA dan FA inverse
-- dibuat oleh : Hidayat
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity spec_function is
  port(
    -- variabel input     
    in_left           : in  std_logic_vector(31 downto 0);
    in_right          : in  std_logic_vector(31 downto 0);
    KF1_in_crypto     : in  std_logic_vector(31 downto 0);
    KF2_in_crypto     : in  std_logic_vector(31 downto 0);
    function_selector : in  std_logic;
    -- variabel output 
    out_function      : out std_logic_vector(63 downto 0)
  );
end entity;

architecture dataflow of spec_function is

  component tristbuf
    port(
      X  : in  std_logic_vector(31 downto 0);
      En : in  std_logic;
      F  : out std_logic_vector(31 downto 0)
    );
  end component;

  component rotl_32
    port(
      in32 : in    std_logic_vector(31 downto 0);
      outs : out std_logic_vector(31 downto 0)
    );
  end component;

  component rotr_32
    port(
      in32 : in    std_logic_vector(31 downto 0);
      outs : out std_logic_vector(31 downto 0)
    );
  end component;

  signal tmpFA1         : std_logic_vector(31 downto 0);
  signal tmpFA2         : std_logic_vector(31 downto 0);
  signal tmpFA_outL     : std_logic_vector(31 downto 0);
  signal tmpFA3         : std_logic_vector(31 downto 0);
  signal tmpFA4         : std_logic_vector(31 downto 0);
  signal tmpFA_outR     : std_logic_vector(31 downto 0);

  signal tmpFAinv1      : std_logic_vector(31 downto 0);
  signal tmpFAinv2      : std_logic_vector(31 downto 0);
  signal tmpFAinv_outR  : std_logic_vector(31 downto 0);
  signal tmpFAinv3      : std_logic_vector(31 downto 0);
  signal tmpFAinv4      : std_logic_vector(31 downto 0);
  signal tmpFAinv_outL  : std_logic_vector(31 downto 0);

  signal no_select      : std_logic;

begin
  -- === F-round (FA) ===
  tmpFA1      <= in_left and KF1_in_crypto;
  u1L : rotl_32
    port map(
      in32 => tmpFA1,
      outs => tmpFA2
    );

  tmpFA_outL  <= tmpFA2 xor in_right;

  u2L : rotr_32
    port map(
      in32 => tmpFA_outL,
      outs => tmpFA3
    );

  tmpFA4      <= tmpFA3 or KF2_in_crypto;
  tmpFA_outR  <= tmpFA4 xor in_left;

  -- === F-round inverse ===
  u2R : rotr_32
    port map(
      in32 => in_right,
      outs => tmpFAinv1
    );

  tmpFAinv2      <= tmpFAinv1 or KF2_in_crypto;
  tmpFAinv_outR  <= tmpFAinv2 xor in_left;

  tmpFAinv3      <= tmpFAinv_outR and KF1_in_crypto;
  u1R : rotl_32
    port map(
      in32 => tmpFAinv3,
      outs => tmpFAinv4
    );

  tmpFAinv_outL  <= tmpFAinv4 xor in_right;

  -- === Output multiplexing ===
  no_select  <= not function_selector;

  outFA_L : tristbuf
    port map(
      X  => tmpFA_outL,
      En => function_selector,
      F  => out_function(63 downto 32)
    );

  outFA_R : tristbuf
    port map(
      X  => tmpFA_outR,
      En => function_selector,
      F  => out_function(31 downto  0)
    );

  outFAinv_L : tristbuf
    port map(
      X  => tmpFAinv_outL,
      En => no_select,
      F  => out_function(63 downto 32)
    );

  outFAinv_R : tristbuf
    port map(
      X  => tmpFAinv_outR,
      En => no_select,
      F  => out_function(31 downto  0)
    );

end architecture;
