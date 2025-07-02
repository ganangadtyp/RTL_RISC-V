----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.02.2025 13:59:44
-- Design Name: 
-- Module Name: top_sipo - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_sipo is
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
end top_sipo;

architecture Behavioral of top_sipo is
    -- Deklarasi komponen untuk entity module_fifo_regs_no_flags
    component module_fifo_regs_no_flags is
        generic (
            g_WIDTH : natural := 8;
            g_DEPTH : integer := 32
        );
       port (
            i_rst_sync : in std_logic;  -- general reset
            i_clk      : in std_logic;  -- clock input
         
            -- FIFO Write Interface
            i_wr_en   : in  std_logic;  -- write enable
            i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);   -- data input
            o_full    : out std_logic;  -- full flag
         
            -- FIFO Read Interface
            i_rd_en   : in  std_logic;  -- read enable
            o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0); -- data out
            o_empty   : out std_logic   -- empty flag
        );
    end component;
    
    component  Modified_Miller_Decoder is
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
    end component;
    
    -- Sinyal internal untuk koneksi antara FIFO dan PtoS
    signal fifo_wr_data : std_logic_vector(7 downto 0);  -- Input fifo from decoder
    signal fifo_wr_lenght : std_logic_vector(7 downto 0);
    signal fifo_full   : std_logic;                     -- Flag FIFO empty
    signal fifo_rd_en   : std_logic;                     -- Sinyal read enable untuk FIFO (dari PtoS)
    signal fifo_wr_en   : std_logic;
    signal rd_en_reg   : std_logic;
    signal fifo_empty   : std_logic;
begin
    o_full <= fifo_full;
    o_empty <= fifo_empty;
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fifo_rd_en <= '0';
                rd_en_reg <= '0';
            else
                fifo_rd_en <= i_rd_en and (not rd_en_reg);
                rd_en_reg <= i_rd_en;
            end if;
        end if;
    end process;
    
    decoder : Modified_Miller_Decoder
        port map (
            clk     => clk,
            reset   => reset,
            serial_in   => serial_in,
            i_fifo_empty => fifo_empty,
            o_data_out => fifo_wr_data,
            o_lenght_out => fifo_wr_lenght,
            parity_out => parity_out,
            last_bit => last_bit,
            inc_head => fifo_wr_en,
            run => run,
            done => done
        );
    
    -- Instansiasi FIFO menggunakan deklarasi komponen
    FIFO: module_fifo_regs_no_flags
        generic map (
            g_WIDTH => 8,
            g_DEPTH => 32
        )
        port map (
            i_rst_sync => reset,
            i_clk      => clk,
            -- Antarmuka Write FIFO (dari luar)
            i_wr_en    => fifo_wr_en,
            i_wr_data  => fifo_wr_data,
            o_full     => fifo_full,
            -- Antarmuka Read FIFO (terkoneksi dengan PtoS)
            i_rd_en    => fifo_rd_en,
            o_rd_data  => o_rd_data,
            o_empty   => fifo_empty
        );
end Behavioral;
