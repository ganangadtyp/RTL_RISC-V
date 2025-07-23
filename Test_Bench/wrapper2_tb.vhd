library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.mc8051_p.all;

entity wrapper2_tb is
-- Testbench tidak memerlukan port
end wrapper2_tb;

architecture behavior of wrapper2_tb is
    
    component mc8051_top is
    
  port (clk       : in std_logic;   -- system clock
        reset     : in std_logic;   -- system reset
        int0_i    : in std_logic_vector(C_IMPL_N_EXT-1 downto 0);  -- ext.Int
        int1_i    : in std_logic_vector(C_IMPL_N_EXT-1 downto 0);  -- ext.Int
        -- counter input 0 for T/C
        all_t0_i  : in std_logic_vector(C_IMPL_N_TMR-1 downto 0);
        -- counter input 1 for T/C
        all_t1_i  : in std_logic_vector(C_IMPL_N_TMR-1 downto 0);
        -- serial input for SIU
        all_rxd_i : in std_logic_vector(C_IMPL_N_SIU-1 downto 0);
        p0_i      : in std_logic_vector(7 downto 0);  -- IO-port0 input
        p1_i      : in std_logic_vector(7 downto 0);  -- IO-port1 input
        p2_i      : in std_logic_vector(7 downto 0);  -- IO-port2 input
        p3_i      : in std_logic_vector(7 downto 0);  -- IO-port3 input 

        p0_o        : out std_logic_vector(7 downto 0);  -- IO-port0 output
        p1_o        : out std_logic_vector(7 downto 0);  -- IO-port1 output
        p2_o        : out std_logic_vector(7 downto 0);  -- IO-port2 output
        p3_o        : out std_logic_vector(7 downto 0);  -- IO-port3 output
        
        -- pin komunikasi
        miller_in   : in  std_logic;       -- Modified Miller encoded input (external port)
        serial_out  : out std_logic;
        
        -- Mode 0 serial output for SIU
        all_rxd_o   : out std_logic_vector(C_IMPL_N_SIU-1 downto 0);
        -- serial output for SIU 
        all_txd_o   : out std_logic_vector(C_IMPL_N_SIU-1 downto 0);
        -- rxd direction signal
        all_rxdwr_o : out std_logic_vector(C_IMPL_N_SIU-1 downto 0)
        );

end component;
    
    signal p0_i : std_logic_vector(7 downto 0);
    signal p1_i : std_logic_vector(7 downto 0);
    signal p2_i : std_logic_vector(7 downto 0);
    signal p3_i : std_logic_vector(7 downto 0);
    
    signal p0_o : std_logic_vector(7 downto 0);
    signal p1_o : std_logic_vector(7 downto 0);
    signal p2_o : std_logic_vector(7 downto 0);
    signal p3_o : std_logic_vector(7 downto 0);

    signal int0_i    : std_logic_vector(C_IMPL_N_EXT-1 downto 0) := (others => '0');  -- ext.Int
    signal int1_i    : std_logic_vector(C_IMPL_N_EXT-1 downto 0) := (others => '0');  -- ext.Int
        -- counter input 0 for T/C
    signal all_t0_i  : std_logic_vector(C_IMPL_N_TMR-1 downto 0) := (others => '0');
        -- counter input 1 for T/C
    signal all_t1_i  : std_logic_vector(C_IMPL_N_TMR-1 downto 0) := (others => '0');
        -- serial input for SIU
    signal all_rxd_i : std_logic_vector(C_IMPL_N_SIU-1 downto 0) := (others => '0');
    
    signal all_rxd_o   : std_logic_vector(C_IMPL_N_SIU-1 downto 0);
        -- serial output for SIU 
    signal all_txd_o   : std_logic_vector(C_IMPL_N_SIU-1 downto 0);
        -- rxd direction signal
    signal all_rxdwr_o : std_logic_vector(C_IMPL_N_SIU-1 downto 0);
    
    signal start_out   : std_logic;
    signal end_out     : std_logic;
    signal start_sampling  : std_logic;
    signal end_sampling    : std_logic;
    signal all_sampling    : std_logic;
    signal o_decoded_bit   : std_logic;
    
    signal clk_src : std_logic := '0';
    signal reset   : std_logic := '0';
    signal miller_in        : std_logic := '1'; -- Default idle state for miller_in
    signal serial_out : std_logic;
    signal test_pattern : std_logic_vector(7 downto 0) := "00100110"; -- short frame
    signal test_pattern2 : std_logic_vector(18 downto 0) := "01"&"00100000"&"0"&"10010011"; -- standard frame
    signal test_pattern_out: std_logic := '0'; -- Signal to monitor the transmitted data
    signal s_addr_16, s_addr_17 : std_logic;
    signal s_CS : std_logic_vector(1 downto 0) := "00";
    
    -- Clock period definition
    constant clk_period : time := 73.757 ns; -- Clock period for 13.56 MHz

    -- Bit period definition for 106 kbps
    constant bit_period : time := 9.44 us; -- Duration of one bit for 106 kbps
    
begin

    i_mc8051_top : mc8051_top
        port map(
            clk => clk_src,
            reset => reset,
            int0_i => int0_i,
            int1_i => int1_i,
            all_t0_i  => all_t0_i,
            all_t1_i => all_t1_i,
            all_rxd_i => all_rxd_i,
            p0_i => p0_i,
            p1_i => p1_i,
            p2_i => p2_i,
            p3_i => p3_i,
            p0_o => p0_o,
            p1_o => p1_o,
            p2_o => p2_o,
            p3_o => p3_o,
            
            miller_in   => miller_in,
            serial_out  => serial_out,
            
            all_rxd_o  =>  all_rxd_o,
            all_txd_o => all_txd_o,
            all_rxdwr_o => all_rxdwr_o
--            -- Modification by Marcellius Xavier, EE Finsal Project 1617.01.067, Institut Teknologi Bandung
--            -- June 7, 2017
--            CS		=> s_CS

        );
        
        -- Modification by Marcellius Xavier, EE Final Project 1617.01.067, Institut Teknologi Bandung
	-- June 7, 2017
	-- Modification by Marcellius Xavier, EE Final Project 1617.01.067, Institut Teknologi Bandung
		-- June 7, 2017
		s_addr_16 <= p1_o(6);
		s_addr_17 <= p1_o(7);
		s_CS <= s_addr_17 & s_addr_16;
		
		p1_i <= p1_o;

    -- Proses untuk menghasilkan sinyal clock (periode 10 ns)
    clk_process : process
    begin
        clk_src <= '0';
        wait for clk_period / 2;
        clk_src <= '1';
        wait for clk_period / 2;
    end process;

    -- Proses untuk menghasilkan stimulus sinyal reset
    -- Stimulus process to generate Modified Miller encoded input
    stimulus_process: process
        variable prev_bit : std_logic := '0'; -- Track the previous bit
    begin
        -- Reset DUT
        reset <= '1'; -- Hold reset
        miller_in <= '1'; -- Default idle state (Sequence F)
        wait for clk_period * 1;
        reset <= '0'; -- Release reset
        wait for clk_period * 100;

        -- Start of Frame
        miller_in <= '0'; -- Start with pause
        wait for bit_period / 2;
        miller_in <= '1'; -- Resume
        wait for bit_period / 2;

        -- Generate Modified Miller encoding for the test pattern
        for i in 0 to test_pattern'length - 1 loop
            -- Update `test_pattern_out` for debugging
            test_pattern_out <= test_pattern(i);

            if test_pattern(i) = '1' then
                -- Bit '1': Pause at start
                miller_in <= '1';
                wait for bit_period / 2;
                miller_in <= '0'; -- Resume
                wait for bit_period / 2;
            else
                -- Bit '0'
                if prev_bit = '0' then
                    -- Transition at mid-period (Sequence Z)
                    miller_in <= '0';
                    wait for bit_period / 2;
                    miller_in <= '1'; -- Pause
                    wait for bit_period / 2;
                else
                    -- Continuous '0' (Sequence Y)
                    miller_in <= '1';
                    wait for bit_period; -- Full bit duration
                end if;
            end if;

            -- Update previous bit
            prev_bit := test_pattern(i);
        end loop;
        miller_in <= '1';
        -- Wait for the decoder to process all inputs
        wait for clk_period * 7000;
        
        -- Sequence D: Start of communication
        miller_in <= '0'; -- Start with pause
        wait for bit_period / 2;
        miller_in <= '1'; -- Resume
        wait for bit_period / 2;

        -- Generate Modified Miller encoding for the test pattern
        for i in 0 to test_pattern'length - 1 loop
            -- Update `test_pattern_out` for debugging
            test_pattern_out <= test_pattern(i);

            if test_pattern(i) = '1' then
                -- Bit '1': Pause at start
                miller_in <= '1';
                wait for bit_period / 2;
                miller_in <= '0'; -- Resume
                wait for bit_period / 2;
            else
                -- Bit '0'
                if prev_bit = '0' then
                    -- Transition at mid-period (Sequence Z)
                    miller_in <= '0';
                    wait for bit_period / 2;
                    miller_in <= '1'; -- Pause
                    wait for bit_period / 2;
                else
                    -- Continuous '0' (Sequence Y)
                    miller_in <= '1';
                    wait for bit_period; -- Full bit duration
                end if;
            end if;

            -- Update previous bit
            prev_bit := test_pattern(i);
        end loop;
        miller_in <= '1';
        -- Wait for the decoder to process all inputs
        wait for clk_period * 7000;
        
        -- Sequence D: Start of communication
        miller_in <= '0'; -- Start with pause
        wait for bit_period / 2;
        miller_in <= '1'; -- Resume
        wait for bit_period / 2;
        
        -- Generate Modified Miller encoding for the test pattern
        for i in 0 to test_pattern2'length - 1 loop
            -- Update `test_pattern_out` for debugging
            test_pattern_out <= test_pattern2(i);

            if test_pattern2(i) = '1' then
                -- Bit '1': Pause at start
                miller_in <= '1';
                wait for bit_period / 2;
                miller_in <= '0'; -- Resume
                wait for bit_period / 2;
            else
                -- Bit '0'
                if prev_bit = '0' then
                    -- Transition at mid-period (Sequence Z)
                    miller_in <= '0';
                    wait for bit_period / 2;
                    miller_in <= '1'; -- Pause
                    wait for bit_period / 2;
                else
                    -- Continuous '0' (Sequence Y)
                    miller_in <= '1';
                    wait for bit_period; -- Full bit duration
                end if;
            end if;

            -- Update previous bit
            prev_bit := test_pattern2(i);
        end loop;
        wait;
    end process;
end behavior;
