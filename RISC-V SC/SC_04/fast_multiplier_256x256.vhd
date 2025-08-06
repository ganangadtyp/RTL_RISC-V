library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fast_multiplier_256x256 is
    Port (
        clk     : in STD_LOGIC;                     
        reset   : in STD_LOGIC;
        start   : in STD_LOGIC;                 -- mulai menghitung
 
        a : in STD_LOGIC_VECTOR(255 downto 0);  -- input a
        b : in STD_LOGIC_VECTOR(255 downto 0);  -- input b
        p : out STD_LOGIC_VECTOR(511 downto 0); -- output
        
        Run     : out STD_LOGIC;                -- run flag
        Done    : out STD_LOGIC                 -- done flag

    );
end fast_multiplier_256x256;

architecture Behavioral of fast_multiplier_256x256 is
    signal ac, bc, ad, bd : STD_LOGIC_VECTOR(255 downto 0);
    signal t1, t2 : STD_LOGIC_VECTOR(511 downto 0);
    signal psum : STD_LOGIC_VECTOR(256 downto 0);
    
       
    -- signal untuk multiplier
    signal mul_a, mul_b : STD_LOGIC_VECTOR(127 downto 0);
    signal mul_p : STD_LOGIC_VECTOR(255 downto 0);
    signal mul_start, mul_run, mul_done : STD_LOGIC;
    
    -- signal untuk adder
    signal add_a, add_b : STD_LOGIC_VECTOR(511 downto 0);
    signal add_p : STD_LOGIC_VECTOR(511 downto 0);
    
    -- register input
    signal r_a0, r_a1, r_b0, r_b1 : STD_LOGIC_VECTOR(127 downto 0);
    
    signal s_a0, s_a1, s_b0, s_b1 : STD_LOGIC_VECTOR(127 downto 0);
    
    signal carry_mid : STD_LOGIC;
    
    type STATE_TYPE is (IDLE, CALC_AC, WAIT_AC, OUT_AC, CALC_BC, WAIT_BC, OUT_BC, CALC_AD, WAIT_AD, OUT_AD, CALC_BD, WAIT_BD, 
                        ADD1, ADD2, CALC_DONE);
    signal STATE, NEXT_STATE : STATE_TYPE := IDLE;

    component fast_multiplier_128x128
        Port (
            clk     : in STD_LOGIC;
            reset   : in STD_LOGIC;
            start   : in STD_LOGIC;
     
            a : in STD_LOGIC_VECTOR(127 downto 0);
            b : in STD_LOGIC_VECTOR(127 downto 0);
            p : out STD_LOGIC_VECTOR(255 downto 0);
            
            Run     : out STD_LOGIC;                        -- Run signal
            Done    : out STD_LOGIC                         -- Operation complete signal
        );
    end component;
    component cla_512bit
        Port (
            a : in STD_LOGIC_VECTOR(511 downto 0);
            b : in STD_LOGIC_VECTOR(511 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(511 downto 0);
            cout : out STD_LOGIC
        );
    end component;

begin
        
    state_transition: process(clk, reset)
    begin
        if reset = '1' then
            STATE <= IDLE;
        elsif rising_edge(clk) then
            STATE <= NEXT_STATE;
        end if;
     end process;
     
    control_unit: process(start, mul_done, STATE, NEXT_STATE)
    begin
        case STATE is
            when IDLE =>
                if (start = '1') then
                    NEXT_STATE <= CALC_BC;
                else 
                    NEXT_STATE <= IDLE;
                end if;
            when CALC_BC =>
                NEXT_STATE <= WAIT_BC;
            when WAIT_BC =>
                if (mul_done = '1') then
                    NEXT_STATE <= OUT_BC;
                else 
                    NEXT_STATE <= WAIT_BC;
                end if;
            when OUT_BC =>
                NEXT_STATE <= CALC_AD;
            when CALC_AD =>
                NEXT_STATE <= WAIT_AD;
            when WAIT_AD =>
                if (mul_done = '1') then
                    NEXT_STATE <= OUT_AD;
                else 
                    NEXT_STATE <= WAIT_AD;
                end if;
            when OUT_AD =>
                NEXT_STATE <= CALC_AC;
            when CALC_AC =>
                NEXT_STATE <= WAIT_AC;
            when WAIT_AC =>
                if (mul_done = '1') then
                    NEXT_STATE <= OUT_AC;
                else 
                    NEXT_STATE <= WAIT_AC;
                end if;
            when OUT_AC =>
                NEXT_STATE <= CALC_BD;
            
            when CALC_BD =>
                NEXT_STATE <= WAIT_BD;
            when WAIT_BD =>
                if (mul_done = '1') then
                    NEXT_STATE <= ADD1;
                else 
                    NEXT_STATE <= WAIT_BD;
                end if;
            when ADD1 =>
                NEXT_STATE <= ADD2;
            when ADD2 =>
                NEXT_STATE <= CALC_DONE;
            when CALC_DONE =>
                NEXT_STATE <= IDLE;
            when others =>
                NEXT_STATE <= STATE;
         end case;
    end process;
 
    seq_proc: process(clk)
    begin
         if rising_edge(clk) then
            case STATE is
                when IDLE =>
                    r_a1 <= s_a1;
                    r_b1 <= s_b1;
                    
                    r_a0 <= s_a0;
                    r_b0 <= s_b0;
                    
                    -- input BC
                    mul_a <= s_a0;
                    mul_b <= s_b1;
                    
                    ac <= (others => '0');
                    bc <= (others => '0');
                    
                    Done <= '0';
                    Run <= '0';
                    mul_start <= '0';
                when CALC_BC =>
                    -- start multiplier
                    mul_start <= '1';
                    Done <= '0';
                    Run <= '1';
                when WAIT_BC =>
                    mul_start <= '0';
                    Done <= '0';
                    Run <= '1';
                when OUT_BC =>
                    bc <= mul_p;
                    
                    -- input ad
                   mul_a <=r_a1;
                   mul_b <= r_b0;
                   Done <= '0';
                   Run <= '1';
                when CALC_AD =>
                    mul_start <= '1';
                    Done <= '0';
                    Run <= '1';
                when WAIT_AD =>
                    mul_start <= '0';
                    Done <= '0';
                    Run <= '1';
                when OUT_AD =>
                    ad <= mul_p;
                    
                    --next input
                    -- input ac
                    mul_a <=r_a1;
                    mul_b <= r_b1;
                    Done <= '0';
                    Run <= '1';
                when CALC_AC =>
                    mul_start <= '1';
                    
                    add_a(511 downto 256) <= (others => '0'); add_a(255 downto 0) <= ad; -- ad
                    add_b(511 downto 256) <= (others => '0'); add_b(255 downto 0) <= bc;
                    Done <= '0';
                    Run <= '1';
                when WAIT_AC =>
                    mul_start <= '0';
                    Done <= '0';
                    Run <= '1';
                when OUT_AC =>
                    ac <= mul_p;
                    
                    -- input BD
                    mul_a <=r_a0;
                    mul_b <= r_b0;
                    Done <= '0';
                    Run <= '1';
                when CALC_BD =>
                    mul_start <= '1';
                    
                    psum <= add_p(256 downto 0);
                    Done <= '0';
                    Run <= '1';
                when WAIT_BD =>
                    mul_start <= '0';
                    Done <= '0';
                    Run <= '1';
                when ADD1 =>
                    add_a(511 downto 256) <= (others => '0');
                    add_a(255 downto 0) <= mul_p; --bd
                    add_b(511 downto 256) <= ac;
                    add_b(255 downto 0) <= (others => '0');
                    
                    Done <= '0';
                    Run <= '1';
                    Done <= '0';
                    Run <= '1';
                when ADD2 =>
                    add_a <= add_p;
                    add_b(511 downto 385) <= (others => '0');
                    add_b(384 downto 128) <= psum;
                    add_b(127 downto 0) <= (others => '0');
                    
                    Done <= '0';
                    Run <= '1';
                when CALC_DONE =>
                    p <= add_p;
                    Done <= '1';
                    Run <= '1';
            end case;
        end if;
    end process;
    
    -- input parsing
    s_a1 <= a(255 downto 128);
    s_b1 <= b(255 downto 128);
                 
    s_a0 <= a(127 downto 0);
    s_b0 <= b(127 downto 0);

    -- Instansiasi fast_multiplier_128x128
    mult: fast_multiplier_128x128
        Port map (
            clk => clk,
            reset => reset,
            start => mul_start,
            a => mul_a,
            b => mul_b,
            p => mul_p,
            
            Run => mul_run,
            Done => mul_done
        );
        
    CLA_1: cla_512bit
        Port map (
            a => add_a,
            b => add_b,
            cin => '0',
            sum => add_p,
            cout => carry_mid
            );
end Behavioral;