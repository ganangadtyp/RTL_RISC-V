library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fast_multiplier_64x64 is
    Port (
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        start   : in STD_LOGIC;
 
        a : in STD_LOGIC_VECTOR(63 downto 0);
        b : in STD_LOGIC_VECTOR(63 downto 0);
        p : out STD_LOGIC_VECTOR(127 downto 0);
        
        Run     : out STD_LOGIC;                        -- Run signal
        Done    : out STD_LOGIC                         -- Operation complete signal

    );
end fast_multiplier_64x64;

architecture Behavioral of fast_multiplier_64x64 is
    signal ac, bc : STD_LOGIC_VECTOR(63 downto 0);
    signal psum : STD_LOGIC_VECTOR(64 downto 0);
    
       
    -- signal untuk multiplier
    signal mul_a, mul_b : STD_LOGIC_VECTOR(31 downto 0);
    signal mul_p : STD_LOGIC_VECTOR(63 downto 0);
    
    -- signal untuk adder
    signal add_a, add_b : STD_LOGIC_VECTOR(127 downto 0);
    signal add_p : STD_LOGIC_VECTOR(127 downto 0);
    signal add_cout : std_logic;
    
    -- register input
    signal r_a0, r_a1, r_b0, r_b1 : STD_LOGIC_VECTOR(31 downto 0);
    
    
    
    type STATE_TYPE is (IDLE, CALC_AC, CALC_BC, CALC_AD, CALC_BD, 
                        ADD1, ADD2, CALC_DONE);
    signal STATE, NEXT_STATE : STATE_TYPE := IDLE;

   component fast_multiplier_32x32
        Port (
            a : in STD_LOGIC_VECTOR(31 downto 0);
            b : in STD_LOGIC_VECTOR(31 downto 0);
            p : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;
    component add_128bit
        Port (
            a : in STD_LOGIC_VECTOR(127 downto 0);
            b : in STD_LOGIC_VECTOR(127 downto 0);
            cin : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(127 downto 0);
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
     
    control_unit: process(start, STATE, NEXT_STATE)
    begin
        case STATE is
            when IDLE =>
                if (start = '1') then
                    NEXT_STATE <= CALC_BC;
                else 
                    NEXT_STATE <= IDLE;
                end if;
            when CALC_BC =>
                NEXT_STATE <= CALC_AD;
            when CALC_AD =>
                NEXT_STATE <= CALC_AC;
            when CALC_AC =>
                NEXT_STATE <= CALC_BD;
            when CALC_BD =>
                NEXT_STATE <= ADD1;  
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
                    r_a1 <= a(63 downto 32);
                    r_b1 <= b(63 downto 32);
                    
                    r_a0 <= a(31 downto 0);
                    r_b0 <= b(31 downto 0);
                    Done <= '0';
                    Run <= '0';
                when CALC_BC =>
                    -- input BC
                    mul_a <=r_a0;
                    mul_b <= r_b1;
                    
                    Done <= '0';
                    Run <= '1';
                when CALC_AD =>
                    bc <= mul_p;
                    
                    -- input AD
                    mul_a <=r_a1;
                    mul_b <= r_b0;
                    
                    Done <= '0';
                    Run <= '1';
                when CALC_AC =>
                    -- input ac
                    mul_a <=r_a1;
                    mul_b <= r_b1;
                    
                    add_a(127 downto 64) <= (others => '0'); add_a(63 downto 0) <= mul_p; -- ad
                    add_b(127 downto 64) <= (others => '0'); add_b(63 downto 0) <= bc;
                    
                    Done <= '0';
                    Run <= '1';
                when CALC_BD =>
                    ac <= mul_p;
                    -- input BD
                    mul_a <=r_a0;
                    mul_b <= r_b0;
                
                    psum(64 downto 0) <= add_p(64 downto 0);
                    
                    Done <= '0';
                    Run <= '1';
                when ADD1 =>
                    add_a(127 downto 64) <= (others => '0');
                    add_a(63 downto 0) <= mul_p; --bd
                    add_b(127 downto 64) <= ac;
                    add_b(63 downto 0) <= (others => '0');
                    
                    Done <= '0';
                    Run <= '1';
                when ADD2 =>
                    add_a <= add_p;
                    add_b(127 downto 97) <= (others => '0');
                    add_b(96 downto 32) <= psum;
                    add_b(31 downto 0) <= (others => '0');
                    
                    Done <= '0';
                    Run <= '1';
                when CALC_DONE =>
                    p <= add_p;
                    Done <= '1';
                    Run <= '1';
            end case;
        end if;
    end process;

    -- Instansiasi fast_multiplier_128x128
    mult: fast_multiplier_32x32
        Port map (
            a => mul_a,
            b => mul_b,
            p => mul_p
        );
        
    i_add: add_128bit
        Port map (
            a => add_a,
            b => add_b,
            cin => '0',
            sum => add_p,
            cout => add_cout
            );
end Behavioral;