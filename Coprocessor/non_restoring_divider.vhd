library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity division is
    Port (
        clk       : in  STD_LOGIC;
        clk_en    : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        done      : out STD_LOGIC;
        
        a         : in  STD_LOGIC_VECTOR(255 downto 0);
        b         : in  STD_LOGIC_VECTOR(255 downto 0);
        p         : out STD_LOGIC_VECTOR(255 downto 0);
        r         : out STD_LOGIC_VECTOR(255 downto 0)
    );
end division;

architecture Behavioral of division is
    -- State machine states
    type STATE_TYPE is (IDLE, SHIFT_A, CALC_DONE);
    signal STATE, NEXT_STATE : STATE_TYPE := IDLE;

    -- Internal signals
    signal M, acc, buff_acc, Q      : STD_LOGIC_VECTOR(256 downto 0);
    signal buff_Q                   : STD_LOGIC;
    signal AM_min, AM_plus          : STD_LOGIC_VECTOR(256 downto 0);
    signal count                    : INTEGER range 0 to 256;

begin

    -- Combinational process for AM_min and AM_plus
    buff_acc <= acc(255 downto 0) & Q(256);
    AM_min <= buff_acc - M;
   
    -- State transition process
    state_transition: process(clk, reset)
    begin
        if reset = '1' then
            STATE <= IDLE;
        elsif rising_edge(clk) then
            STATE <= NEXT_STATE;
        end if;
    end process;

    -- Control unit to manage state transitions
    control_unit: process(clk, clk_en, start, STATE, count)
    begin
        case STATE is
            when IDLE =>
                if start = '1' and clk_en = '1' then
                    NEXT_STATE <= SHIFT_A;
                else 
                    NEXT_STATE <= IDLE;
                end if;
            when SHIFT_A =>
                if clk_en = '1' then
                    if clk_en = '1' and count < 256 then
                        NEXT_STATE <= SHIFT_A;
                    elsif clk_en = '1' and count = 256 then
                        NEXT_STATE <= CALC_DONE;
                    end if;
                end if;
--            when SHIFT_Q =>
--                if clk_en = '1' then
--                    NEXT_STATE <= AM;
--                end if;
--            when AM =>
--                if clk_en = '1' then
--                    NEXT_STATE <= QUO;
--                end if;
--            when QUO =>
--                if clk_en = '1' and count < 256 then
--                    NEXT_STATE <= SHIFT_A;
--                elsif clk_en = '1' and count = 256 then
--                    NEXT_STATE <= CALC_DONE;
--                end if;
            when CALC_DONE =>
                if clk_en = '1' then
                    NEXT_STATE <= IDLE;
                end if;
            when others =>
                NEXT_STATE <= IDLE;
        end case;
    end process;

    -- Counter process
--    counter_proc: process(clk)
--    begin
--        if reset = '1' then
--            count <= 0;
--        elsif rising_edge(clk) then
--            if STATE = QUO then
--                count <= count + 1;
--            elsif STATE = IDLE then
--                count <= 0;
--            end if;
--        end if;
--    end process;

    -- Sequential process for the main operations
    seq_proc: process(clk)
    begin
        if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    M <= '0' & b;
                    acc <= (others => '0');
                    Q <= '0' & a;
                    count <= 0;
                    done <= '0';
                when SHIFT_A =>
                    --acc <= acc(255 downto 0) & Q(256);  -- Shift left acc
                    --Q <= Q(255 downto 0) & '0';  -- Shift left Q
                    if AM_min(256) = '0' then
                       Q <= Q(255 downto 0) & '1';  -- Shift left Q
                       acc <= AM_min; 
                    else
                        acc <= buff_acc;
                       Q <= Q(255 downto 0) & '0';  -- Shift left Q
                    end if;  
                    count <= count + 1;
--                    buff_Q <= Q(255);
--                when SHIFT_Q =>
----                    acc(0) <= buff_Q;
--                    --Q <= Q(255 downto 0) & '0';  -- Shift left Q
--                when AM =>
--                    --buff_acc <= AM_min;

--                when QUO =>
--                    if AM_min(256) = '0' then
--                       Q(0) <= '1';
--                       acc <= AM_min; 
--                    else
--                       Q(0) <= '0';
--                    end if;  
                when CALC_DONE =>
                    done <= '1';
                    p <= Q(255 downto 0);
                    r <= acc(255 downto 0);
            end case;
        end if;
    end process;

end Behavioral;
