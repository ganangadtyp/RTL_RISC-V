---------------------------------------------------------------------------------
-- Company: ITB
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 25.02.2025 13:59:44
-- Design Name: 
-- Module Name: Modified_Miller_Decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - miller_in menjadi serial_in
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;  -- <-- untuk fungsi to_unsigned / to_signed

entity Modified_Miller_Decoder is
    Port (
        clk         : in  std_logic;       -- 13.56 MHz clock
        reset       : in  std_logic;       -- Reset signal
        serial_in   : in  std_logic;       -- Modified Miller encoded input (external port)
        i_fifo_empty : in std_logic;
        o_data_out  : out std_logic_vector(7 downto 0);       -- to data input buffer
        o_lenght_out  : out std_logic_vector(7 downto 0);
        parity_out  : out std_logic;        -- parity flag (external port)
        last_bit    : out std_logic;        -- last_bit(external port)
        inc_head    : out std_logic;        -- to write enable fifo
        run         : out std_logic;        -- Valid output signal (external port)
        done        : out std_logic        -- Valid output signal (external port)
    );
end Modified_Miller_Decoder;

architecture Behavioral of Modified_Miller_Decoder is
    -- State definitions
    type state_type is (IDLE, SOC1, SOC2, DECODE1, DECODE2, DECODE3, SAVE1, SAVE2, SAVE3, SAVE4, SAVE5, SAVE6, PROC_DONE);
    signal STATE, NEXT_STATE : state_type := IDLE;

    -- Internal signals
    signal counter          : integer range 0 to 128 := 0; -- Bit duration counter
    signal bit_counter      : integer range 0 to 9 := 0;
    
    signal decoded_bit      : std_logic := '0';            -- Current decoded bit
    signal prev_decoded_bit : std_logic := '1';            -- Previous decoded bit
    signal eoc_flag         : std_logic := '0';            -- End of communication flag
    signal start_sample     : std_logic_vector(4 downto 0) := (others => '0'); -- 5 samples
    signal end_sample       : std_logic_vector(4 downto 0) := (others => '0'); -- 5 samples
    signal start_miller     : std_logic := '1';            -- Miller_in at start of bit
    signal end_miller       : std_logic := '1';            -- Miller_in at end of bit
    
    signal carry_start      : std_logic_vector(3 downto 0) := (others => '0');
    signal sum_start        : std_logic_vector(3 downto 0) := (others => '0');
    signal carry_end        : std_logic_vector(3 downto 0) := (others => '0');
    signal sum_end          : std_logic_vector(3 downto 0) := (others => '0');
    
    signal data_buff        : std_logic_vector(8 downto 0) := (others => '0'); -- buffer data to store the data before parity computing
    signal s_data_out       : std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bits      : std_logic_vector(63 downto 0):= (others => '0');
    signal par_xor          : std_logic_vector(8 downto 0); -- Data blok 8-bit
    signal s_parity, r_parity         : std_logic := '0';
    signal s_done           : std_logic;

    -- Constants for counter positions
    constant START_CAPTURE : integer := 4;  -- Position to capture start of bit
    constant END_CAPTURE   : integer := 67; -- Position to capture end of bit
    constant FULL_BIT      : integer := 126; -- Full bit duration
begin
    -- addition start sample
    -- First stage: Add start_sample(0) and start_sample(1)
    sum_start(0) <= start_sample(0) XOR start_sample(1);
    carry_start(0) <= start_sample(0) AND start_sample(1);
    -- Second stage: Add sum_start(0) and start_sample(2)
    sum_start(1) <= sum_start(0) XOR start_sample(2) XOR carry_start(0);
    carry_start(1) <= (sum_start(0) AND start_sample(2)) OR (carry_start(0) AND (sum_start(0) XOR start_sample(2)));
    -- Third stage: Add sum_start(1) and start_sample(3)
    sum_start(2) <= sum_start(1) XOR start_sample(3) XOR carry_start(1);
    carry_start(2) <= (sum_start(1) AND start_sample(3)) OR (carry_start(1) AND (sum_start(1) XOR start_sample(3)));
    -- Final stage: Add sum_start(2) and start_sample(4)
    sum_start(3) <= sum_start(2) XOR start_sample(4);
    carry_start(3) <= (sum_start(2) AND start_sample(4)) OR (carry_start(2) AND (sum_start(2) XOR start_sample(4)));
    
    start_miller <= carry_start(3) OR (carry_start(2) AND sum_start(3));
    
    
    -- addition end sample
    -- First stage: Add end_sample(0) and end_sample(1)
    sum_end(0) <= end_sample(0) XOR end_sample(1);
    carry_end(0) <= end_sample(0) AND end_sample(1);
    -- Second stage: Add sum_end(0) and end_sample(2)
    sum_end(1) <= sum_end(0) XOR end_sample(2) XOR carry_end(0);
    carry_end(1) <= (sum_end(0) AND end_sample(2)) OR (carry_end(0) AND (sum_end(0) XOR end_sample(2)));
    -- Third stage: Add sum_end(1) and end_sample(3)
    sum_end(2) <= sum_end(1) XOR end_sample(3) XOR carry_end(1);
    carry_end(2) <= (sum_end(1) AND end_sample(3)) OR (carry_end(1) AND (sum_end(1) XOR end_sample(3)));
    -- Final stage: Add sum_end(2) and end_sample(4)
    sum_end(3) <= sum_end(2) XOR end_sample(4);
    carry_end(3) <= (sum_end(2) AND end_sample(4)) OR (carry_end(2) AND (sum_end(2) XOR end_sample(4)));
    
    end_miller <= carry_end(3) OR (carry_end(2) AND sum_end(3));
    
    -- decoded bit
    decoded_bit <= not end_miller;
    
    -- Parity block Process
    s_parity <= (not par_xor(8)) xor par_xor(7) xor par_xor(6)xor par_xor(5) xor par_xor(4) xor par_xor(3) xor
              par_xor(2) xor par_xor(1) xor par_xor(0);
    
    parity_out <= r_parity;

    --end of communication flag
    eoc_flag <= '1' when (prev_decoded_bit = '0' and 
                      start_miller = '1' and 
                      end_miller = '1') else '0';
    
    -- done assigment
    done <= s_done;
    -- State transition process
    state_transition: process(clk, reset)
    begin
        if reset = '1' then
            STATE <= IDLE;
        elsif rising_edge(clk) then
            STATE <= NEXT_STATE;
        end if;
    end process;

    -- Control unit to determine next state
    control_unit: process(STATE, reset, counter, bit_counter, eoc_flag, serial_in, data_buff, i_fifo_empty, s_done)
    begin
        case STATE is
            when IDLE =>
                if serial_in = '0' then
                    NEXT_STATE <= SOC1; -- Start of communication bit
                else
                    NEXT_STATE <= IDLE;
                end if;
            when SOC1 =>
                if counter = FULL_BIT then
                    NEXT_STATE <= SOC2;
                 else
                    NEXT_STATE <= SOC1;
                end if;
            when SOC2 =>
                NEXT_STATE <= DECODE1;
            when DECODE1 =>
                if counter = FULL_BIT then
                    if eoc_flag = '1' then
                        NEXT_STATE <= SAVE3;
                    else
                        if bit_counter < 8 then
                            NEXT_STATE <= SAVE1;
                        else
                            NEXT_STATE <= SAVE2;
                        end if;
                    end if;
                else
                    NEXT_STATE <= DECODE1; -- Keep decoding
                end if;
            when DECODE2 =>
                if counter = FULL_BIT then
                    if eoc_flag = '1' then
                        NEXT_STATE <= SAVE3; -- End of communication detected
                    else
                        if bit_counter < 8 then
                            NEXT_STATE <= SAVE1;
                        else
                            NEXT_STATE <= SAVE2;
                        end if;
                    end if;
                else
                    NEXT_STATE <= DECODE3; -- Keep decoding
                end if;
            when DECODE3 =>
                if counter = FULL_BIT then
                    if eoc_flag = '1' then
                        NEXT_STATE <= SAVE3; -- End of communication detected
                    else
                        if bit_counter < 8 then
                            NEXT_STATE <= SAVE1;
                        else
                            NEXT_STATE <= SAVE2;
                        end if;
                    end if;
                else
                    NEXT_STATE <= DECODE1; -- Keep decoding
                end if;
            when SAVE1 =>
                NEXT_STATE <= DECODE1; -- Move back to decoding
            when SAVE2 =>
                NEXT_STATE <= DECODE2;
            when SAVE3 =>
                NEXT_STATE <= SAVE4;
            when SAVE4 =>
                if bit_counter > 1 then
                    NEXT_STATE <= SAVE5;
                else
                    NEXT_STATE <= SAVE6;
                end if;
            when SAVE5 =>
                NEXT_STATE <= PROC_DONE;
            when SAVE6 =>
                NEXT_STATE <= PROC_DONE;
            when PROC_DONE =>
                if reset = '1' then
                    NEXT_STATE <= IDLE;
                else
                    if serial_in = '0' then
                        NEXT_STATE <= SOC1;
                    elSif ((i_fifo_empty = '1') and (s_done = '1')) then
                        NEXT_STATE <= IDLE;
                    else
                        NEXT_STATE <= PROC_DONE;
                    end if;
                end if;
        end case;
    end process;

    -- Sequential process for main operations
    seq_proc: process(clk)
    begin
        if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    counter <= 0; -- Reset counter
                    bit_counter <= 0;
                    last_bit <= '0';
                    par_xor <= (others => '0');
                    r_parity <= '0';
                    
                    prev_decoded_bit <= '1';
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '0';
                    o_data_out <= (others => '0');
                    o_lenght_out <= (others => '0');
                when SOC1 =>
                    counter <= counter + 1;                    
                    s_done <= '0';
                    run <= '1';
                when SOC2 =>
                    counter <= 0;                    
                    s_done <= '0';
                    run <= '1';
                when DECODE1 =>
                    counter <= counter + 1;
                    -- Capture start and end miller values
                    if (counter >= START_CAPTURE - 2) and (counter <= START_CAPTURE + 2)then
                        start_sample <= start_sample(3 downto 0) & serial_in;
                    elsif (counter >= END_CAPTURE - 2) and (counter <= END_CAPTURE + 2) then
                        end_sample <= end_sample(3 downto 0) & serial_in;
                    else
                    end if;
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when SAVE1 =>
                    counter <= 0;            -- Reset counter for next bit
                    bit_counter <= bit_counter + 1;
                    data_buff(bit_counter) <= decoded_bit; -- Output decoded bit
                    --data_buff <= decoded_bit & data_buff(8 downto 1);
                    last_bit <= prev_decoded_bit;
                    prev_decoded_bit <= decoded_bit;
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when SAVE2 =>
                    counter <= 0;
                    bit_counter <= 0;
                    o_lenght_out <= std_logic_vector(to_unsigned(bit_counter, o_lenght_out'length));
                    --bit_counter <= bit_counter + 1;
                    data_buff(bit_counter) <= decoded_bit; -- Output decoded bit
                    --data_buff <= decoded_bit & data_buff(8 downto 1);
                    last_bit <= prev_decoded_bit;
                    prev_decoded_bit <= decoded_bit;
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when DECODE2 =>
                     counter <= counter + 1;
                    -- Capture start and end miller values
                    if (counter >= START_CAPTURE - 2) and (counter <= START_CAPTURE + 2)then
                        start_sample <= start_sample(3 downto 0) & serial_in;
                    elsif (counter >= END_CAPTURE - 2) and (counter <= END_CAPTURE + 2) then
                        end_sample <= end_sample(3 downto 0) & serial_in;
                     else
                    end if;
                   
                    par_xor <= data_buff;
                    o_data_out <= data_buff(7 downto 0);
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when DECODE3 =>
                     counter <= counter + 1;
                    -- Capture start and end miller values
                    if (counter >= START_CAPTURE - 2) and (counter <= START_CAPTURE + 2)then
                        start_sample <= start_sample(3 downto 0) & serial_in;
                    elsif (counter >= END_CAPTURE - 2) and (counter <= END_CAPTURE + 2) then
                        end_sample <= end_sample(3 downto 0) & serial_in;
                     else
                    end if;
  
                    if s_parity = '1' then
                        r_parity <= '1';
                    else
                        r_parity <= r_parity;
                    end if;
                    
                    inc_head <= '1';
                    s_done <= '0';
                    run <= '1';
                when SAVE3 =>
                    counter <= 0;
                    data_buff(bit_counter) <= decoded_bit; -- Output decoded bit
                    --data_buff <= decoded_bit & data_buff(8 downto 1);
                    --last_bit <= prev_decoded_bit;
                    prev_decoded_bit <= decoded_bit;
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when SAVE4 =>
                    bit_counter <= 0;
                    o_data_out <= data_buff(7 downto 0);
                    o_lenght_out <= std_logic_vector(to_unsigned(bit_counter, o_lenght_out'length));
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when SAVE5 =>           -- Increment fifo head jika counter > 0
                    inc_head <= '1';
                    s_done <= '0';
                    run <= '1';
                when SAVE6 =>           -- jangan increment head jika counter = 0
                    inc_head <= '0';
                    s_done <= '0';
                    run <= '1';
                when PROC_DONE =>
                    counter <= 0; -- Reset counter
                    bit_counter <= 0;
                    par_xor <= (others => '0');
                    r_parity <= '0';
                    data_buff <= (others => '0');
                    prev_decoded_bit <= '1';
                    inc_head <= '0';
                    s_done <= '1';
                    run <= '0';    
            end case;
        end if;
    end process;
end Behavioral;