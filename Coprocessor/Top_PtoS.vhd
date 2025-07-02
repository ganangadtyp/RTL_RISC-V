library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_ptos is
    Port (
        clk           : in  std_logic;                     -- clock untuk kedua modul
        reset         : in  std_logic;                     -- sinyal reset untuk kedua modul
        exec_valid    : in  std_logic;                     -- sinyal valid untuk eksekusi di PtoS
        
        -- Port untuk antarmuka penulisan data ke FIFO dari 8051
        i_wr_en       : in  std_logic;
        i_wr_data0    : in  std_logic_vector(7 downto 0);   -- data
        i_wr_data1    : in  std_logic_vector(7 downto 0);   -- data lenght
        o_full        : out std_logic;                     -- flag FIFO full
        o_empty       : out std_logic;                     -- flag FIFO full
        
        -- Output dari PtoS
        serial_out    : out std_logic;                     -- serial output (Manchester encoder)
        busy          : out std_logic;                     -- sinyal busy dari PtoS
        o_empty_error : out std_logic;                     -- error flag jika FIFO kosong dan PtoS berjalan
        done          : out std_logic                      -- sinyal proses selesai dari PtoS
    );
end top_ptos;

architecture Behavioral of top_ptos is

    -- Deklarasi komponen untuk entity PtoS
    component PtoS is
        Port ( 
            clk         : in std_logic;                     
            reset       : in std_logic;                     
            start       : in std_logic;                     
            exec_valid  : in std_logic;                     
            data_empty  : in std_logic;                    
            data_in     : in std_logic_vector(7 downto 0);  
            lenght_in     : in std_logic_vector(7 downto 0);  
            serial_out  : out std_logic;                    
            busy        : out std_logic;                    
            o_inc_tail  : out std_logic;                    
            o_empty_error   : out std_logic;                
            done        : out std_logic                     
        );
    end component;

    -- Deklarasi komponen untuk entity module_fifo_regs_no_flags
    component module_fifo_regs_no_flags2 is
        generic (
            g_WIDTH : natural := 8;
            g_DEPTH : integer := 32
        );
       port (
            i_rst_sync : in std_logic;  -- general reset
            i_clk      : in std_logic;  -- clock input
         
            -- FIFO Write Interface
            i_wr_en   : in  std_logic;  -- write enable
            i_wr_data0: in  std_logic_vector(g_WIDTH-1 downto 0);   -- data input
            i_wr_data1: in  std_logic_vector(g_WIDTH-1 downto 0);   -- data input
            o_full    : out std_logic;  -- full flag
         
            -- FIFO Read Interface
            i_rd_en   : in  std_logic;  -- read enable
            o_rd_data0: out std_logic_vector(g_WIDTH-1 downto 0); -- data out
            o_rd_data1: out std_logic_vector(g_WIDTH-1 downto 0); -- data out
            o_almost_empty : out std_logic; -- count < 2
            o_empty   : out std_logic   -- empty flag
        );
    end component;

    -- Sinyal internal untuk koneksi antara FIFO dan PtoS
    signal fifo_rd_data0: std_logic_vector(7 downto 0);  -- Data keluaran dari FIFO
    signal fifo_rd_data1: std_logic_vector(7 downto 0);  -- Data keluaran dari FIFO
    signal fifo_empty   : std_logic;                     -- Flag FIFO empty
    signal fifo_almost_empty   : std_logic;
    signal fifo_rd_en   : std_logic;                     -- Sinyal read enable untuk FIFO (dari PtoS)
    signal fifo_wr_en   : std_logic;
    signal wr_en_flag   : std_logic;
    signal start_ptos   : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (i_wr_en = '1') then
                if (fifo_wr_en = '0') and (wr_en_flag = '0') then
                    fifo_wr_en <= '1';
                    wr_en_flag <= '1';
                else
                    fifo_wr_en <= '0';
                end if;
            else
                fifo_wr_en <= '0';
                wr_en_flag <= '0';
            end if;
        end if;
    end process;
    o_empty <= fifo_empty;
    start_ptos <= not fifo_empty;
    -- Instansiasi PtoS menggunakan deklarasi komponen
    Encoder: PtoS
        port map (
            clk         => clk,
            reset       => reset,
            start       => start_ptos,
            exec_valid  => exec_valid,
            data_empty  => fifo_empty,       -- Terhubung dengan flag FIFO empty
            data_in     => fifo_rd_data0,     -- Data dari FIFO
            lenght_in   => fifo_rd_data1,
            serial_out  => serial_out,
            busy        => busy,
            o_inc_tail  => fifo_rd_en,       -- Menghasilkan sinyal read enable untuk FIFO
            o_empty_error => o_empty_error,
            done        => done
        );

    -- Instansiasi FIFO menggunakan deklarasi komponen
    FIFO: module_fifo_regs_no_flags2
        generic map (
            g_WIDTH => 8,
            g_DEPTH => 32
        )
        port map (
            i_rst_sync => reset,
            i_clk      => clk,
            -- Antarmuka Write FIFO (dari luar)
            i_wr_en    => fifo_wr_en,
            i_wr_data0  => i_wr_data0,
            i_wr_data1  => i_wr_data1,
            o_full     => o_full,
            -- Antarmuka Read FIFO (terkoneksi dengan PtoS)
            i_rd_en    => fifo_rd_en,
            o_rd_data0  => fifo_rd_data0,
            o_rd_data1  => fifo_rd_data1,
            o_almost_empty => fifo_almost_empty,
            o_empty   => fifo_empty
        );

end Behavioral;