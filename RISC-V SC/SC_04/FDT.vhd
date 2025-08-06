----------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 01.01.2025 09:36:57
-- Design Name: 
-- Module Name: FDT - Behavioral
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


entity FDT is
    Port (
        clk         : in  std_logic;       -- 13.56 MHz clock
        reset       : in  std_logic;       -- Reset signal
        last_bit_in : in  std_logic;       -- Bit terakhir dari modified miller decoder (0/1)
        valid_in    : in std_logic;        -- sambung ke sinyal 'done' dari modified miller decoder
        miller_in   : in std_logic;        
        valid       : out std_logic        -- sinyal valid untuk ke menchester encoder
    );
end FDT;

architecture Behavioral of FDT is
    component counter_12bit is
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            en          : in  std_logic;
            Q           : out std_logic_vector(11 downto 0)
        );
    end component;
    -- counter signal
    signal counter_reset   : std_logic;
    signal counter_en      : std_logic := '0';
    signal counter_out     : std_logic_vector(11 downto 0);
    
    --internal signal
    signal last_bit_buff       : std_logic;
    
    -- state
    type state_type is (IDLE, LONG_COUNT, SHORT_COUNT);
    signal STATE, NEXT_STATE : state_type := IDLE;
    
begin
    
    counter : counter_12bit port map (
        clk => clk,
        reset => counter_reset,
        en => counter_en,
        Q => counter_out
    );
    
    last_bit_reg : process(clk, reset, valid_in)
    begin
        if reset = '1' then
            last_bit_buff <= '0';
        elsif rising_edge(clk) then
            if valid_in = '1' then
                last_bit_buff <= last_bit_in;
            end if;
        end if;
    end process;
    
    -- State transition process
    state_transition: process(clk, reset)
    begin
        if reset = '1' then
            STATE <= IDLE;
        elsif rising_edge(clk) then
            STATE <= NEXT_STATE;
        end if;
    end process;
    
    control_unit : process(STATE, last_bit_buff, miller_in, last_bit_in, counter_out)
    begin
    case STATE is
        when IDLE =>
            if miller_in = '1' then
                NEXT_STATE <= LONG_COUNT;
            else
                NEXT_STATE <= IDLE;
            end if;
        when LONG_COUNT =>
            if miller_in = '1' then
                if (unsigned(counter_out) = to_unsigned(1167, counter_out'length) )
                AND ( last_bit_buff = '0' ) then
                    NEXT_STATE <= SHORT_COUNT;
                elsif (unsigned(counter_out) = to_unsigned(1231, counter_out'length) )
                AND (last_bit_buff = '1' ) then
                    NEXT_STATE <= SHORT_COUNT;
                else
                    NEXT_STATE <= LONG_COUNT;
                end if;
            else
                NEXT_STATE <= IDLE;
            end if; 
        when SHORT_COUNT =>
            if miller_in = '1' then
                NEXT_STATE <= SHORT_COUNT;
            else
                NEXT_STATE <= IDLE;
            end if;
    end case;
    end process;
    
    seq_proc : process(clk)
    begin
        if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    counter_reset <= '1';
                    counter_en <= '0';
                    valid <= '0';
                when LONG_COUNT =>
                    if (unsigned(counter_out) = to_unsigned(1167, counter_out'length) )
                    AND ( last_bit_buff = '0') then
                        counter_reset <= '1';
                        counter_en <= '0';
                        valid <= '1';
                    elsif (unsigned(counter_out) = to_unsigned(1231, counter_out'length) )
                    AND (last_bit_buff = '1') then
                        counter_reset <= '1';
                        counter_en <= '0';
                        valid <= '1';
                    else
                        counter_reset <= '0';
                        counter_en <= '1';
                        valid <= '0';
                    end if;
                when SHORT_COUNT =>
                    if (unsigned(counter_out) = to_unsigned(127, counter_out'length)) then
                        counter_reset <= '1';
                        counter_en <= '0';
                        valid <= '1';
                    else
                        counter_reset <= '0';
                        counter_en <= '1';
                        valid <= '0';
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
