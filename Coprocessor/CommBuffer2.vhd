-------------------------------------------------------------------------------
-- Modified Synchronous FIFO with unsigned pointers and count
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity module_fifo_regs_no_flags2 is
  generic (
    g_WIDTH : natural := 8;
    g_DEPTH : natural := 32
  );
  port (
    i_clk           : in  std_logic;
    i_rst_sync      : in  std_logic;

    -- FIFO Write Interface
    i_wr_en         : in  std_logic;
    i_wr_data0      : in  std_logic_vector(g_WIDTH-1 downto 0);
    i_wr_data1      : in  std_logic_vector(g_WIDTH-1 downto 0);

    -- FIFO Read Interface
    i_rd_en         : in  std_logic;
    o_rd_data0      : out std_logic_vector(g_WIDTH-1 downto 0);
    o_rd_data1      : out std_logic_vector(g_WIDTH-1 downto 0);

    -- Status Flags
    o_full          : out std_logic;
    o_empty         : out std_logic;
    o_almost_empty  : out std_logic
  );
end module_fifo_regs_no_flags2;

architecture rtl of module_fifo_regs_no_flags2 is
  constant C_ADDR_WIDTH : integer := 8;

  -- FIFO memory arrays
  type t_fifo_data is array(0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
  signal r_fifo_data0 : t_fifo_data := (others => (others => '0'));
  signal r_fifo_data1 : t_fifo_data := (others => (others => '0'));

  -- Write and read pointers as unsigned
  signal r_wr_ptr : unsigned(C_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal r_rd_ptr : unsigned(C_ADDR_WIDTH-1 downto 0) := (others => '0');

  -- Count of items (one extra bit to represent full depth)
  signal r_count  : unsigned(C_ADDR_WIDTH downto 0)   := (others => '0');

  -- Internal flags
  signal w_full, w_empty, w_almost_empty : std_logic;
begin
  process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_rst_sync = '1' then
        -- Synchronous reset
        r_wr_ptr <= (others => '0');
        r_rd_ptr <= (others => '0');
        r_count  <= (others => '0');
      else
        -- Read operation: decrement count, advance read pointer
        if i_rd_en = '1' and w_empty = '0' then
          r_count <= r_count - 1;
          if r_rd_ptr = to_unsigned(g_DEPTH-1, C_ADDR_WIDTH) then
            r_rd_ptr <= (others => '0');
          else
            r_rd_ptr <= r_rd_ptr + 1;
          end if;
        end if;

        -- Write operation: store data, increment count, advance write pointer
        if i_wr_en = '1' and w_full = '0' then
          r_fifo_data0(to_integer(r_wr_ptr)) <= i_wr_data0;
          r_fifo_data1(to_integer(r_wr_ptr)) <= i_wr_data1;
          r_count <= r_count + 1;
          if r_wr_ptr = to_unsigned(g_DEPTH-1, C_ADDR_WIDTH) then
            r_wr_ptr <= (others => '0');
          else
            r_wr_ptr <= r_wr_ptr + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Output the current read data
  o_rd_data0 <= r_fifo_data0(to_integer(r_rd_ptr));
  o_rd_data1 <= r_fifo_data1(to_integer(r_rd_ptr));

  -- Update flags based on count
  w_full         <= '1' when r_count = to_unsigned(g_DEPTH, r_count'length) else '0';
  w_empty        <= '1' when r_count = 0                              else '0';
  w_almost_empty <= '1' when r_count = to_unsigned(1, r_count'length) else '0';

  o_full         <= w_full;
  o_empty        <= w_empty;
  o_almost_empty <= w_almost_empty;
end rtl;
