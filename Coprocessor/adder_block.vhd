----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 13:14:42
-- Design Name: 
-- Module Name: adder_block - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity adder_block is
    Port ( 
        i_c0      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c1      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c2      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c3      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c4      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c5      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c6      : in STD_LOGIC_VECTOR(7 downto 0);
        i_c7      : in STD_LOGIC_VECTOR(7 downto 0);
        o_p       : out STD_LOGIC_VECTOR(15 downto 0)
    );
end adder_block;

architecture Behavioral of adder_block is
component cla_16bit is
    Port (
        a : in STD_LOGIC_VECTOR(15 downto 0);
        b : in STD_LOGIC_VECTOR(15 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(15 downto 0);
        cout : out STD_LOGIC
    );
    
end component;
    signal s_a16            : std_logic_vector(15 downto 0);
    signal s_b16            : std_logic_vector(15 downto 0);
    signal s_sum16          : std_logic_vector(15 downto 0);
    signal s_carry16        : std_logic;
    
    component csa_10bit is
        port (
            A     : in  STD_LOGIC_VECTOR(9 downto 0);
            B     : in  STD_LOGIC_VECTOR(9 downto 0);
            C     : in  STD_LOGIC_VECTOR(9 downto 0);
            Sum   : out STD_LOGIC_VECTOR(9 downto 0);
            Carry : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
   
    signal s_a10            : std_logic_vector(9 downto 0) := (others => '0');
    signal s_b10            : std_logic_vector(9 downto 0):= (others => '0');
    signal s_c10            : std_logic_vector(9 downto 0):= (others => '0');
    signal s_d10            : std_logic_vector(9 downto 0):= (others => '0');
    signal s_e10            : std_logic_vector(9 downto 0):= (others => '0');
    signal s_f10            : std_logic_vector(9 downto 0):= (others => '0');
    signal s_sum010          : std_logic_vector(9 downto 0):= (others => '0');
    signal s_carry010        : std_logic_vector(9 downto 0):= (others => '0');
    signal s_sum110          : std_logic_vector(9 downto 0):= (others => '0');
    signal s_carry110        : std_logic_vector(9 downto 0):= (others => '0');
    
    component csa_11bit is
        port (
            A     : in  STD_LOGIC_VECTOR(10 downto 0);
            B     : in  STD_LOGIC_VECTOR(10 downto 0);
            C     : in  STD_LOGIC_VECTOR(10 downto 0);
            Sum   : out STD_LOGIC_VECTOR(10 downto 0);
            Carry : out STD_LOGIC_VECTOR(10 downto 0)
        );
    end component;
   
    signal s_a11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_b11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_c11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_d11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_e11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_f11            : std_logic_vector(10 downto 0) := (others => '0');
    signal s_sum011, s_sum011s          : std_logic_vector(10 downto 0) := (others => '0');
    signal s_carry011, s_carry011s        : std_logic_vector(10 downto 0) := (others => '0');
    signal s_sum111, s_sum111s          : std_logic_vector(10 downto 0) := (others => '0');
    signal s_carry111, s_carry111s        : std_logic_vector(10 downto 0) := (others => '0');
    
   component rca_11bit is
    Port (
        a : in STD_LOGIC_VECTOR(10 downto 0);
        b : in STD_LOGIC_VECTOR(10 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(10 downto 0);
        cout : out STD_LOGIC
    );
    end component;
    signal t0, t1          : std_logic_vector(11 downto 0) := (others => '0'); --sum rca 11
    signal v0, v1        : std_logic; -- hasil carry rca 11
    
    component rca_7bit is
    Port (
        a : in STD_LOGIC_VECTOR(6 downto 0);
        b : in STD_LOGIC_VECTOR(6 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(6 downto 0);
        cout : out STD_LOGIC
    );
    end component;
    
    signal s_a7            : std_logic_vector(6 downto 0) := (others => '0');
    signal s_b7            : std_logic_vector(6 downto 0) := (others => '0');
    signal s_sum7          : std_logic_vector(6 downto 0) := (others => '0');
    signal s_carry7        : std_logic;
    
    component inc1_4 is
      port(
        a    : in  std_logic;                       -- carry-in = bit a
        b    : in  std_logic_vector(3 downto 0);    -- operand 4-bit
        sum  : out std_logic_vector(3 downto 0)    -- hasil b + a
      );
    end component;
    
    signal inc_a4, inc_carry4 : std_logic;
    signal inc_b4, inc_sum4 : std_logic_vector(3 downto 0) := (others => '0');
    
    component CLA_4bit is
    Port (
        A : in STD_LOGIC_VECTOR(3 downto 0);
        B : in STD_LOGIC_VECTOR(3 downto 0);
        cin : in STD_LOGIC;
        S : out STD_LOGIC_VECTOR(3 downto 0);
        Cout : out STD_LOGIC
    );
    end component;
    signal s_sum_cla4       : std_logic_vector(3 downto 0);
    signal s_carry_cla4 : std_logic;
    
    component rca_8bit is
    Port (
        a : in STD_LOGIC_VECTOR(7 downto 0);
        b : in STD_LOGIC_VECTOR(7 downto 0);
        cin : in STD_LOGIC;
        sum : out STD_LOGIC_VECTOR(7 downto 0);
        cout : out STD_LOGIC
    );
    end component;
    
    signal Inc : std_logic;
    signal s_p : std_logic_vector(11 downto 0);
begin
    --csa 10 bit 0
    s_a10 <= "00" & i_c0;
    s_b10 <= '0' & i_c1 & '0';
    s_c10 <= i_c2 & "00";
    i_csa10_0 : csa_10bit
        port map (
            a => s_a10,
            b => s_b10,
            c => s_c10,
            sum => s_sum010,
            carry => s_carry010
        );
    
    --csa 10 bit 1
    s_d10 <= "00" & i_c4;
    s_e10 <= '0' & i_c5 & '0';
    s_f10 <= i_c6 & "00";
    i_csa10_1 : csa_10bit
        port map (
            a => s_d10,
            b => s_e10,
            c => s_f10,
            sum => s_sum110,
            carry => s_carry110
        );
        
    -- csa 11 bit 0
    s_a11 <= '0' & s_sum010;
    s_b11 <= '0' & s_carry010(8 downto 0) & '0';
    s_c11 <= i_c3 & "000";
    i_csa11_0 : csa_11bit
        port map (
            a => s_a11,
            b => s_b11,
            c => s_c11,
            sum => s_sum011,
            carry => s_carry011
        );
        
        s_carry011s <= s_carry011(9 downto 0) & '0';
    
    -- csa 11 bit 1
    s_d11 <= '0' & s_sum110;
    s_e11 <= '0' & s_carry110(8 downto 0) & '0';
    s_f11 <= i_c7 & "000";
    i_csa11_1 : csa_11bit
        port map (
            a => s_d11,
            b => s_e11,
            c => s_f11,
            sum => s_sum111,
            carry => s_carry111
        );
    
    s_carry111s <= s_carry111(9 downto 0) & '0';
    
    i_CLA4 : CLA_4bit
        port map (
            A => s_sum011(3 downto 0),
            B => s_carry011s(3 downto 0),
            Cin => '0',
            S => t0(3 downto 0),
            Cout => s_carry_cla4
        );
        
    i_rca_7bit : rca_7bit
        port map (
            a => s_sum011(10 downto 4),
            b => s_carry011s(10 downto 4),
            cin => s_carry_cla4,
            sum => t0(10 downto 4),
            cout => t0(11)          
        );
        
     i_rca_11bit_1 : rca_11bit
        port map ( 
            a => s_sum111,
            b => s_carry111s,
            cin => '0',
            sum => t1(10 downto 0),
            cout => t1(11)
        );
        
    i_rca_8bit_0 : rca_8bit
        port map ( 
            a => t0(11 downto 4),
            b => t1(7 downto 0),
            cin => '0',
            sum => s_p(7 downto 0),
            cout => Inc
        );
    
    i_inc_4bit : inc1_4
        port map(
            a => Inc,
            b => t1(11 downto 8),
            sum => s_p(11 downto 8)
        );
        
    o_p <= s_p & t0(3 downto 0);
end Behavioral;