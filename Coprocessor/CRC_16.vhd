----------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 30.04.2025 15:36:22
-- Design Name: 
-- Module Name: CRC_16 - Behavioral
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

entity CRC_16 is
    Port ( 
        clk             : in std_logic;
        reset           : in std_logic;
        i_start         : in std_logic_vector(1 downto 0);
        i_init_val      : in std_logic_vector(15 downto 0);
        i_data          : in std_logic_vector(15 downto 0);
        o_crc           : out std_logic_vector(15 downto 0);
        o_run           : out std_logic;
        o_done          : out std_logic
    );
end CRC_16;

architecture Behavioral of CRC_16 is
    type state_type is (IDLE, INIT, INIT2, WAITING, EXEC1, PRE_DONE, DONE);
    signal STATE, NEXT_STATE : state_type := IDLE;
    
    component reg1bit
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            en    : in  std_logic;
            clr   : in  std_logic;
            init  : in  std_logic;
            d     : in  std_logic;
            q     : out std_logic
        );
    end component;
    
    component counter_5bit
        port (
          clk   : in  std_logic;
          reset : in  std_logic;
          en    : in  std_logic;
          Q     : out std_logic_vector(4 downto 0)
        );
  end component;
    --signal internal
    signal r_data           : std_logic_vector (15 downto 0);
    signal r_init_val       : std_logic_vector (15 downto 0);
    signal r_start          : std_logic;
    signal r_start_help     : std_logic;
    signal r_lenght         : std_logic;
    
    
    signal s_data_in        : std_logic_vector (15 downto 0);
    signal s_data_out       : std_logic_vector (15 downto 0);
      
    signal clr, en          : std_logic;
    
    --signal untuk counter 5 bit
    signal s_counter_reset  : std_logic;
    signal r_counter_reset  : std_logic;
    signal r_counter_en     : std_logic;
    signal cnt5             : std_logic_vector(4 downto 0);
    
begin 
     starter_unit : process(reset, clk)
     begin
        if reset = '1' then
           r_start <= '0';
           r_start_help <= '0';
        elsif rising_edge(clk) then
            r_start <= i_start(0) and (not r_start_help);
            r_start_help <= i_start(0);
        end if;
     end process;           
     
     control_unit : process(STATE, NEXT_STATE, cnt5, r_start, r_lenght)
     begin
        case STATE is
            when IDLE =>
                if (r_start = '1') then
                    NEXT_STATE <= INIT;
                else 
                    NEXT_STATE <= IDLE;
                end if;
            when INIT =>
                NEXT_STATE <= INIT2;
            when INIT2 =>
                NEXT_STATE <= EXEC1;
            when WAITING =>
                if (r_start = '1') then
                    NEXT_STATE <= INIT;
                else 
                    NEXT_STATE <= WAITING;
                end if;
            when EXEC1 =>
                if (r_lenght = '1') then
                    if unsigned(cnt5) >= to_unsigned(14, cnt5'length) then
                        NEXT_STATE <= PRE_DONE;
                    else 
                        NEXT_STATE <= EXEC1;
                    end if;
                else
                    if unsigned(cnt5) >= to_unsigned(6, cnt5'length) then
                        NEXT_STATE <= PRE_DONE;
                    else 
                        NEXT_STATE <= EXEC1;
                    end if;
                end if;
            when PRE_DONE =>
                NEXT_STATE <= DONE;
            when DONE =>
                NEXT_STATE <= WAITING;
                
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
              
    seq_proc: process(clk)
    begin
        if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    r_data <= i_data;
                    r_init_val <= i_init_val;
                    r_lenght <= i_start(1);
                    en <= '0';
                    clr <= '0';
                    
                    r_counter_reset <= '1';
                    r_counter_en <= '0';
                    
                    o_crc <= (others => '0');

                    o_run <= '0';
                    o_done <= '0';
                when INIT =>
                    en <= '1';
                    clr <= '1';
                    
                    r_counter_reset <= '1';
                    r_counter_en <= '0';
                    
                    o_run <= '1';
                    o_done <= '0';
                when INIT2 =>
                    en <= '1';
                    clr <= '0';
                    
                    r_counter_reset <= '0';
                    r_counter_en <= '1';
                    
                    o_run <= '1';
                    o_done <= '0';
                when WAITING =>
                    r_data <= i_data;
                    r_init_val <= i_init_val;
                    r_lenght <= i_start(1);
                    en <= '0';
                    clr <= '0';
                    
                    r_counter_reset <= '1';
                    r_counter_en <= '0';

                    o_run <= '0';
                    o_done <= '1';
                when EXEC1 =>
                    en <= '1';
                    clr <= '0';
                    
                    r_counter_reset <= '0';
                    r_counter_en <= '1';
                    
                    r_data <= '0' & r_data(15 downto 1);
                    o_run <= '1';
                    o_done <= '0';
                when PRE_DONE =>
                    en <= '0';
                    clr <= '0';
                    
                    r_counter_reset <= '0';
                    r_counter_en <= '1';
                    
                    r_data <= '0' & r_data(15 downto 1);
                    o_run <= '1';
                    o_done <= '0';
                when DONE =>
                   r_init_val <= (others => '0');
                   r_lenght <= i_start(1);
                   en <= '1';
                   clr <= '1';
                   
                   r_counter_reset <= '1';
                   r_counter_en <= '0';
                   
                   o_crc <= s_data_out;

                   o_run <= '0';
                   o_done <= '1';
            end case;
        end if;
    end process;
    
    s_data_in(15) <= r_data(0) xor s_data_out(0);
    s_data_in(14) <= s_data_out(15);
    s_data_in(13) <= s_data_out(14);
    s_data_in(12) <= s_data_out(13);
    s_data_in(11) <= s_data_out(12);
    s_data_in(10) <= s_data_out(11) xor s_data_in(15);
    s_data_in(9) <= s_data_out(10);
    s_data_in(8) <= s_data_out(9);
    s_data_in(7) <= s_data_out(8);
    s_data_in(6) <= s_data_out(7);
    s_data_in(5) <= s_data_out(6);
    s_data_in(4) <= s_data_out(5);
    s_data_in(3) <= s_data_out(4) xor s_data_in(15);
    s_data_in(2) <= s_data_out(3);
    s_data_in(1) <= s_data_out(2);
    s_data_in(0) <= s_data_out(1);
    
    
    gen_regs: for i in 0 to 15 generate
        u_reg: reg1bit
            port map (
                clk   => clk,
                reset => reset,
                en    => en,
                clr   => clr,
                init  => r_init_val(i),
                d     => s_data_in(i),
                q     => s_data_out(i)
            );
    end generate;


    --counter reset control
    s_counter_reset <= reset or r_counter_reset;
    u_counter: counter_5bit
        port map (
          clk   => clk,
          reset => s_counter_reset,
          en    => r_counter_en,    -- counter hanya berjalan selama INIT+EXEC1
          Q     => cnt5
        );
    
end Behavioral;
