----------------------------------------------------------------------------------
-- Company: ITB 
-- Engineer: Ganang Aditya Pratama
-- 
-- Create Date: 07.03.2025 13:41:20
-- Design Name: 
-- Module Name: ISO14443_wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - Adding register
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ISO14443_wrapper is
    Port ( 
        -- to external port
        clk         : in  std_logic;       -- 13.56 MHz clock
        reset       : in  std_logic;       -- Reset signal
        miller_in   : in  std_logic;       -- Modified Miller encoded input (external port)
        serial_out  : out std_logic;
        
        -- CRC port
        i_COPCRCINIT_1  : in std_logic_vector(7 downto 0);  -- initial value CRC
        i_COPCRCINIT_2  : in std_logic_vector(7 downto 0);
        i_COPCRCI_1     : in std_logic_vector(7 downto 0);  -- input CRC
        i_COPCRCI_2     : in std_logic_vector(7 downto 0);
        i_COPCRCEN      : in std_logic_vector(7 downto 0);  -- CRC start/enable
        o_COPCRCSTAT    : out std_logic_vector(7 downto 0); -- status CRC
        o_COPCRCO_1      : out std_logic_vector(7 downto 0);  -- output CRC
        o_COPCRCO_2      : out std_logic_vector(7 downto 0);
        
        
        -- to SFR Write
        i_COPWR     : in std_logic_vector(7 downto 0);
        i_COPWRLN   : in std_logic_vector(7 downto 0);
        i_COPWREN   : in std_logic_vector(7 downto 0); 
        o_COPWRSTAT : out std_logic_vector(7 downto 0);
        
        
        -- to SFR read
        i_COPRDEN   : in  std_logic_vector(7 downto 0);  -- read enable
        o_COPRD     : out std_logic_vector(7 downto 0); -- data out
        o_COPRDLN   : out std_logic_vector(7 downto 0);
        o_COPRDSTAT : out std_logic_vector(7 downto 0)
    );
end ISO14443_wrapper;

architecture Behavioral of ISO14443_wrapper is
    component top_sipo is
    generic (
        g_WIDTH : natural := 8;
        g_DEPTH : integer := 32
    );
    Port ( 
        clk         : in  std_logic;       -- 13.56 MHz clock
        reset       : in  std_logic;       -- Reset signal
        serial_in   : in  std_logic;       -- Modified Miller encoded input (external port)
        parity_out  : out std_logic;        -- parity flag (external port)
        last_bit    : out std_logic;        -- last_bit(external port)
        run         : out std_logic;        -- Valid output signal (external port)
        done        : out std_logic;        -- Valid output signal (external port)
         -- FIFO Read Interface
        i_rd_en   : in  std_logic;  -- read enable
        o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0); -- data out
        o_empty   : out std_logic;   -- empty flag
        o_full    : out std_logic
    );
    end component;
    
    component top_ptos is
    Port (
        clk           : in  std_logic;                     -- clock untuk kedua modul
        reset         : in  std_logic;                     -- sinyal reset untuk kedua modul
        exec_valid    : in  std_logic;                     -- sinyal valid untuk eksekusi di PtoS
        
        -- Port untuk antarmuka penulisan data ke FIFO dari 8051
        i_wr_en       : in  std_logic;
        i_wr_data0    : in  std_logic_vector(7 downto 0);   -- data
        i_wr_data1    : in  std_logic_vector(7 downto 0);   -- data lebght
        o_full        : out std_logic;                     -- flag FIFO full
        o_empty       : out std_logic;                     -- flag FIFO full
        
        -- Output dari PtoS
        serial_out    : out std_logic;                     -- serial output (Manchester encoder)
        busy          : out std_logic;                     -- sinyal busy dari PtoS
        o_empty_error : out std_logic;                     -- error flag jika FIFO kosong dan PtoS berjalan
        done          : out std_logic                      -- sinyal proses selesai dari PtoS
    );
    end component;
    
    component FDT is
    Port (
        clk         : in  std_logic;       -- 13.56 MHz clock
        reset       : in  std_logic;       -- Reset signal
        last_bit_in : in  std_logic;       -- Bit terakhir dari modified miller decoder (0/1)
        valid_in    : in std_logic;        -- sambung ke sinyal 'done' dari modified miller decoder
        miller_in   : in std_logic;        
        valid       : out std_logic        -- sinyal valid untuk ke menchester encoder
    );
    end component;
    
    -- Deklarasi komponen CRC_16
    component CRC_16
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            i_start    : in  std_logic_vector(1 downto 0);
            i_init_val : in  std_logic_vector(15 downto 0);
            i_data     : in  std_logic_vector(15 downto 0);
            o_crc      : out std_logic_vector(15 downto 0);
            o_run      : out std_logic;
            o_done     : out std_logic
        );
    end component;
    
    signal tx_valid     : std_logic;
    signal last_bit     : std_logic;
    signal parity_out   : std_logic;
    signal rd_en, wr_en : std_logic;
    signal s_miller     : std_logic;
    signal rx_flag      : std_logic_vector(7 downto 0);
    signal tx_flag      : std_logic_vector(7 downto 0);
    signal miller_help  : std_logic;
    signal s_COPRDLN    : std_logic_vector(7 downto 0) := (others => '0');
    
    -- sinyal untuk CRC
    signal s_CRC_start      : std_logic_vector(1 downto 0);
    signal s_CRC_init_val   : std_logic_vector(15 downto 0);
    signal s_CRC_input      : std_logic_vector(15 downto 0);
    signal s_CRC_output     : std_logic_vector(15 downto 0);
    signal s_CRC_run        : std_logic;
    signal s_CRC_done       : std_logic;
begin
    rd_en  <= not i_COPRDEN(0);
    wr_en  <= not i_COPWREN(0);
    rx_flag(7 downto 4) <= (others => '0');
    tx_flag(7 downto 5) <= (others => '0');
    o_COPWRSTAT <= tx_flag;
    o_COPRDSTAT <= rx_flag;
    o_COPRDLN <= s_COPRDLN;
    -- assignment untuk CRC
    
    s_CRC_start(0) <= not i_COPCRCEN(0);
    s_CRC_start(1) <= not i_COPCRCEN(1);
    s_CRC_init_val(7 downto 0) <= i_COPCRCINIT_1;
    s_CRC_init_val(15 downto 8) <= i_COPCRCINIT_2;
    s_CRC_input(7 downto 0) <= i_COPCRCI_1;
    s_CRC_input(15 downto 8) <= i_COPCRCI_2;
    o_COPCRCO_1 <= s_CRC_output(7 downto 0);
    o_COPCRCO_2 <= s_CRC_output(15 downto 8);
    o_COPCRCSTAT(0) <= s_CRC_run;
    o_COPCRCSTAT(1) <= s_CRC_done;
    o_COPCRCSTAT(7 downto 2) <= (others => '0');
    
    --Supaya miller in tetap bernilai '1' pada saat transmisi dari kartu ke reader
    s_miller <= miller_in or tx_flag(0) or tx_flag(1) or miller_help;
    u_rx : top_sipo
    port map (
        clk         => clk,
        reset       => reset,
        serial_in   => s_miller,
        parity_out  => parity_out,
        last_bit    => last_bit,
        run         => rx_flag(0),
        done        => rx_flag(1),
        
        i_rd_en => rd_en,
        o_rd_data => o_COPRD,
        o_empty     => rx_flag(2),
        o_full      => rx_flag(3)
    );
    
    u_tx : top_ptos
    port map(
        clk         => clk,
        reset       => reset,
        exec_valid  => tx_valid,
        i_wr_en     => wr_en,
        i_wr_data0   => i_COPWR,
        i_wr_data1   => i_COPWRLN,
        o_full      => tx_flag(3),
        o_empty     => tx_flag(2),
        serial_out  => serial_out,
        busy        => tx_flag(0),
        o_empty_error => tx_flag(4),
        done        => tx_flag(1)
    );
    
    u_FDT : FDT
    port map (
        clk     => clk,
        reset   => reset,
        last_bit_in => last_bit,
        valid_in    => rx_flag(1),
        miller_in   => s_miller,
        valid       => tx_valid
    );
    reg_bloc : process(clk)
    begin
        if rising_edge(clk) then
            miller_help <= tx_flag(1);
        end if;
    end process;
    
    u_CRC : CRC_16 port map (
        clk        => clk,
        reset      => reset,
        i_start    => s_CRC_start,
        i_init_val => s_CRC_init_val,
        i_data     => s_CRC_input,
        o_crc      => s_CRC_output,
        o_run      => s_CRC_run,
        o_done     => s_CRC_done
    );
end Behavioral;