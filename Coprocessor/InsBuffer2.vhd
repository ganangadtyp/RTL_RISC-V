-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
--
-- Description: Creates a Synchronous FIFO made out of registers.
--              Generic: g_WIDTH sets the width of the FIFO created.
--              Generic: g_DEPTH sets the depth of the FIFO created.
--
--              Total FIFO register usage will be width * depth
--              Note that this fifo should not be used to cross clock domains.
--              (Read and write clocks NEED TO BE the same clock domain)
--
--              FIFO Full Flag will assert as soon as last word is written.
--              FIFO Empty Flag will assert as soon as last word is read.
--
--              FIFO is 100% synthesizable.  It uses assert statements which do
--              not synthesize, but will cause your simulation to crash if you
--              are doing something you shouldn't be doing (reading from an
--              empty FIFO or writing to a full FIFO).
--
--              No Flags = No Almost Full (AF)/Almost Empty (AE) Flags
--              There is a separate module that has programmable AF/AE flags.
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity InsBuffer2 is
  generic (
    g_WIDTH : natural := 8;
    constant ADDRESS_WIDTH  : natural := 16;
    g_DEPTH : integer := 32
    );
  port (
    i_rst_sync : in std_logic;  -- general reset
    i_clk      : in std_logic;  -- clock input
 
    -- FIFO Write Interface
    i_wr_en     : in  std_logic;  -- write enable
    i_Data	    : in  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);         -- data to be written on shared memory
    i_Command	: in  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);         -- instruction to accelerator and shared memory controller
	i_AdTh	    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);   -- Upper data limit
	i_AdSrc	    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);   -- Lower data limit (Addres)
	i_AdDest	: in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
    o_full    : out std_logic;  -- full flag
 
    -- FIFO Read Interface
    i_rd_en   : in  std_logic;  -- read enable
    o_Data	    : out  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);
    o_Command	: out  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);
	o_AdTh	    : out  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
	o_AdSrc	    : out  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
	o_AdDest	: out  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
    o_empty   : out std_logic   -- empty flag
    );
end InsBuffer2;
 
architecture rtl of InsBuffer2 is
 
    type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
    signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));
  
    --TAMBAHAN : menambahakan tipe variabel baru karena perubahan lebar address
    type FIFO_Address is array (0 to g_DEPTH - 1) of std_logic_vector (ADDRESS_WIDTH-1 downto 0);
    --TAMBAHA END
    
    signal r_Data : t_FIFO_DATA:=(others=>x"FF");
    signal r_Command : t_FIFO_DATA:=(others=>x"FF");
	--PERUBAHAN : Mengubah tupe variabel dari FIFO_Memory menjadi FIFO_Address
	signal r_AdTh : FIFO_Address:=(others=>x"FFFF");
	signal r_AdSrc : FIFO_Address:=(others=>x"FFFF");
	signal r_AdDest : FIFO_Address:=(others=>x"FFFF");
	--PERUBAHAN END
 
    -- TAMBAHAN : sinyal r_wr_en dan r_rd_en untuk delta delay
    signal r_wr_en, r_rd_en : std_logic;
    signal s_wr_en, s_rd_en : std_logic;
    
    signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 := 0;
    signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 := 0;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_COUNT : integer range -1 to g_DEPTH+1 := 0;
 
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
   
begin
 
 -- TAMBAHAN : delta delayed assigment
 s_wr_en <= i_wr_en and (not r_wr_en);
 s_rd_en <= i_rd_en and (not r_rd_en);
 -- TAMBAHAN end
 
  p_CONTROL : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst_sync = '1' then
        r_FIFO_COUNT <= 0;
        r_WR_INDEX   <= 0;
        r_RD_INDEX   <= 0;
      else
        
        --delta delay increment tail and head
        r_wr_en <= i_wr_en;
        r_rd_en <= i_rd_en;
        
        -- Keeps track of the total number of words in the FIFO
        if (s_wr_en = '1' and s_rd_en = '0') then
          r_FIFO_COUNT <= r_FIFO_COUNT + 1;
        elsif (s_wr_en = '0' and s_rd_en = '1') then
          r_FIFO_COUNT <= r_FIFO_COUNT - 1;
        end if;

 
        -- Keeps track of the write index (and controls roll-over)
        if (s_wr_en = '1' and w_FULL = '0') then
          if r_WR_INDEX = g_DEPTH-1 then
            r_WR_INDEX <= 0;
          else
            r_WR_INDEX <= r_WR_INDEX + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)        
        if (s_rd_en = '1' and w_EMPTY = '0') then
          if r_RD_INDEX = g_DEPTH-1 then
            r_RD_INDEX <= 0;
          else
            r_RD_INDEX <= r_RD_INDEX + 1;
          end if;
        end if;
 
        -- Registers the input data when there is a write
        if (s_wr_en = '1') then
          r_Data(r_WR_INDEX) <= i_Data;
          r_Command(r_WR_INDEX) <= i_Command;
          r_AdTh(r_WR_INDEX) <= i_AdTh;
          r_AdSrc(r_WR_INDEX) <= i_AdSrc;
          r_AdDest(r_WR_INDEX) <= i_AdDest;
        end if;
        if (s_rd_en = '1') then
            if r_RD_INDEX = 0 then
                r_Data(g_DEPTH-1) <= (others => '1');
                r_Command(g_DEPTH-1) <= (others => '1');
                r_AdTh(g_DEPTH-1) <= (others => '1');
                r_AdSrc(g_DEPTH-1) <= (others => '1');
                r_AdDest(g_DEPTH-1) <= (others => '1');    
            else
                r_Data(r_RD_INDEX-1) <= (others => '1');
                r_Command(r_RD_INDEX-1) <= (others => '1');
                r_AdTh(r_RD_INDEX-1) <= (others => '1');
                r_AdSrc(r_RD_INDEX-1) <= (others => '1');
                r_AdDest(r_RD_INDEX-1) <= (others => '1');
            end if; 
        end if;
      end if;                           -- sync reset
    end if;                             -- rising_edge(i_clk)
  end process p_CONTROL;
   
  o_Data    <= r_data(r_RD_INDEX);
  o_Command <= r_Command(r_RD_INDEX);
  o_AdTh    <= r_AdTh(r_RD_INDEX);
  o_AdSrc   <= r_AdSrc(r_RD_INDEX);
  o_AdDest  <= r_AdDest(r_RD_INDEX);
 
  w_FULL  <= '1' when r_FIFO_COUNT >= g_DEPTH else '0';
  w_EMPTY <= '1' when r_FIFO_COUNT <= 0       else '0';
 
  o_full  <= w_FULL;
  o_empty <= w_EMPTY;
end rtl;