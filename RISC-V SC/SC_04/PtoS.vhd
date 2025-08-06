----------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 07.02.2025 10:24:08
-- Design Name: PtoS
-- Module Name: PtoS - Behavioral
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PtoS is
  Port ( 
    clk         : in std_logic;                     -- clock input 13.56MHz            
    reset       : in std_logic;                     -- sinyal general reset
    start       : in std_logic;                     -- sinyal untuk mulai
    exec_valid  : in std_logic;                     -- sinyal valid untuk masuk ke state EXEC
    data_empty  : in std_logic;                     -- Flag fifo empty
    data_in     : in std_logic_vector(7 downto 0);  -- data input dari buffer FIFO
    lenght_in   : in std_logic_vector(7 downto 0);
    serial_out  : out std_logic;                    -- output serial dengan manchester encoder
    busy        : out std_logic;                    -- sinyal busy
    o_inc_tail  : out std_logic;                    -- sinyal increment tail untuk fifo
    o_empty_error   : out std_logic;                -- flag eror jika buffer kosong dan PtoS diperintahkan berjalan
    done        : out std_logic                     -- sinyal tanda proses selesai
  );
end PtoS;

architecture Behavioral of PtoS is
    -- sinyal internal
    signal r_inc_tail   : std_logic; -- increment tail fifo buffer
    signal r_data_buff    : std_logic_vector(8 downto 0); -- buffer parallel to serial
    signal s_data_encode : std_logic;
    signal s_serial_out : std_logic;
    signal r_lenght : std_logic_vector(7 downto 0);
     component Parity_Calculator
        Port ( 
            data_in  : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(8 downto 0)
        );
    end component;
    -- sinyal untuk komponen parity_calculator
    signal s_par_in   : std_logic_vector(7 downto 0); -- input ke parity calculator
    signal s_par_out  : std_logic_vector(8 downto 0); -- dari output parity calculator
    
    component counter_7bit
        Port (
            clk   : in  std_logic;
            reset : in  std_logic;
            en    : in  std_logic;
            Q     : out std_logic_vector(6 downto 0)
        );
    end component;
    
    --sinyal untuk counter 7 bit
    signal r_counter7_en     : std_logic;
    signal r_counter7_rst    : std_logic;
    signal s_counter7_rst    : std_logic;
    signal s_clk_106         : std_logic;
    signal s_counter7_out    : std_logic_vector(6 downto 0);
    
    component counter_4bit
        Port (
            clk   : in  std_logic;
            reset : in  std_logic;
            en    : in  std_logic;
            Q     : out std_logic_vector(3 downto 0)
        );
    end component;
    
    -- Deklarasi Komponen Manchester_Encoder
    component Manchester_Encoder
        Port (
            clk   : in std_logic;
            d_in  : in std_logic;
            d_out : out std_logic
        );
    end component;
    
        --sinyal untuk counter 4 bit
    signal r_counter4_clk    : std_logic;
    signal r_counter4_en     : std_logic;
    signal r_counter4_rst    : std_logic;
    signal s_counter4_rst    : std_logic;
    signal s_counter4_out    : std_logic_vector(3 downto 0);
    
    --sinyal untuk frekuensi carrier
    signal r_freq_carrier_en     : std_logic;
    signal r_freq_carrier_rst    : std_logic;
    signal s_freq_carier        : std_logic_vector(3 downto 0);

    type state_type is (IDLE, SOF, FETCH, EXEC1, EXEC2, EXEC3, STATE_DONE);
    signal STATE, NEXT_STATE : state_type := IDLE;
    
begin
    -- menghubungkan data masuk ke perhitungan parity
    s_par_in <= data_in;
    
    -- sinyal clock 106KHz (13.56MHZ/128)
    s_clk_106 <= not s_counter7_out(6);
    
    -- reset counter
    s_counter7_rst <= reset or r_counter7_rst;
    s_counter4_rst <= reset or r_counter4_rst;
    
    -- jika s_counter4 < 9, th1 = '1';
    --th1 <= (not s_counter4_out(3)) or  ((not s_counter4_out(2)) and (not s_counter4_out(1)) and (not s_counter4_out(0)));
    
    -- output inc_tail
    o_inc_tail <= r_inc_tail;
    
    -- state machine controller
    control_unit: process(exec_valid, data_empty, start, STATE, NEXT_STATE, s_counter7_out, s_counter4_out, r_lenght)
    begin
        case STATE is
            when IDLE =>
                if (data_empty = '0') then
                    if (exec_valid = '1') then
                        NEXT_STATE <= SOF;
                    else
                        NEXT_STATE <= IDLE;
                    end if;
                else
                    NEXT_STATE <= IDLE;
                end if;
            when EXEC1 =>
                if (data_empty = '0') then
                    NEXT_STATE <= EXEC2;
                else
                    NEXT_STATE <= STATE_DONE;
                end if;
            when SOF =>
                  -- if s_counter7_out >= 253
                if ((s_counter7_out = "1111110") or (s_counter7_out = "1111111")) then
                    NEXT_STATE <= FETCH;
                else
                    NEXT_STATE <= SOF;
                end if;   
            when FETCH =>
                NEXT_STATE <= EXEC1;
            when EXEC2 =>
                -- if s_counter7_out >= 253
                if ((s_counter7_out = "1111110") or (s_counter7_out = "1111111")) then
                    if unsigned(s_counter4_out) < unsigned(r_lenght(3 downto 0)) then -- if s_counter4 < 9, th1 = '1';
                        NEXT_STATE <= EXEC3;
                    else
                         NEXT_STATE <= FETCH;
                    end if;  
                else
                    NEXT_STATE <= EXEC2;
                end if;
            when EXEC3 =>
                NEXT_STATE <= EXEC2;
--            when EOF =>
--                if ((s_counter7_out = "1111110") or (s_counter7_out = "1111111")) then
--                    NEXT_STATE <= STATE_DONE;
--                else
--                    NEXT_STATE <= EOF;
--                end if;    
            when STATE_DONE =>
                NEXT_STATE <= IDLE;
        end case;
    end process;
                         
    
    state_transition: process(clk, reset)
    begin
        if reset = '1' then
            STATE <= IDLE;
        elsif rising_edge(clk) then
            STATE <= NEXT_STATE;
        end if;
    end process;


    seq_proc : process(clk, start)
    begin
        if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    r_data_buff <= (others => '0');
                    r_lenght <= (others => '0');
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '1';
                    
                    r_counter7_rst  <= '1';
                    r_counter4_rst  <= '1';

                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    
                    r_freq_carrier_en <= '0';
                    r_freq_carrier_rst <= '1';
                    
                    busy            <= '0';
                    done            <= '0';
                when EXEC1 =>                   
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '1';
                    
                    r_counter7_rst  <= '0';
                    r_counter4_rst  <= '0';
                    
                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    
                    busy <= '1';
                    done <= '0';
                when SOF =>
                    r_data_buff <= (others => '1');
                    r_counter4_clk <= '0';
                    
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '0';
                    
                    r_counter7_rst  <= '0';
                    r_counter4_rst  <= '1';
                    
                    r_freq_carrier_en <= '1';
                    r_freq_carrier_rst <= '0';
                    
                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    
                    busy  <= '1';
                    done <= '0';
                when FETCH =>
                    r_data_buff <= s_par_out;
                    r_lenght <= lenght_in;
                    r_counter4_clk <= '0';
                    
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '1';
                    
                    r_counter7_rst  <= '0';
                    r_counter4_rst  <= '1';
                    
                    r_inc_tail <= not data_empty;
                    o_empty_error <= '0';
                    
                    busy  <= '1';
                    done <= '0';
                when EXEC2 =>
                    r_counter4_clk <= '0';
                    
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '1';
                    
                    r_counter7_rst  <= '0';
                    r_counter4_rst  <= '0';
                    
                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    
                    busy  <= '1';
                    done <= '0';
                when EXEC3 =>
                    r_data_buff <= '0' & r_data_buff(8 downto 1);
                    r_counter4_clk  <= '1';
                    
                    r_counter7_en   <= '1';
                    r_counter4_en   <= '1';
                    
                    r_counter7_rst  <= '0';
                    r_counter4_rst  <= '0';

                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    
                    busy <= '1';
                    done <= '0';
--                when EOF =>
--                    r_data_buff <= (others => '0');
--                    r_counter7_en   <= '1';
--                    r_counter4_en   <= '1';
                    
--                    r_counter7_rst  <= '1';
--                    r_counter4_rst  <= '1';

--                    r_inc_tail <= '0';
--                    o_empty_error <= '0';
                    
--                    r_freq_carrier_en <= '0';
--                    r_freq_carrier_rst <= '1';
                    
--                    busy            <= '1';
--                    done            <= '0';
                when STATE_DONE =>
                    r_inc_tail <= '0';
                    o_empty_error <= '0';
                    busy <= '1';
                    done <= '1';
            end case;
        end if;    
        
    end process;
    -- Instansiasi Parity_Calculator
    parity_unit: Parity_Calculator
        port map (
            data_in  => s_par_in,
            data_out => s_par_out
        );
    -- instantiasi counter 7 bit
    freq_divider : counter_7bit
        port map (
            clk   => clk,
            reset => s_counter7_rst,
            en    => r_counter7_en,
            Q     => s_counter7_out
        );
     -- instantiasi counter 4 bit   
     data_counter  : counter_4bit
        port map (
            clk   => r_counter4_clk,
            reset => s_counter4_rst,
            en    => r_counter4_en,
            Q     => s_counter4_out
        );
        
     freq_subcarier  : counter_4bit
        port map (
            clk   => clk,
            reset => r_freq_carrier_rst,
            en    => r_freq_carrier_en,
            Q     => s_freq_carier
        );
        
     s_data_encode <= not r_data_buff(0);   
     serial_out <= s_serial_out and (not s_freq_carier(3));
     encoder: Manchester_Encoder
        port map (
            clk   => s_clk_106,
            d_in  => s_data_encode,
            d_out => s_serial_out
        );
    
end Behavioral;