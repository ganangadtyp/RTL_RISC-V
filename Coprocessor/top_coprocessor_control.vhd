library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity top_coprocessor_control is
port (
  DataIn            : in std_logic_vector(7 downto 0);  -- Write Data
  CommandIn         : in std_logic_vector(7 downto 0);  -- Perintah (COPCOM)
  AdThIn            : in std_logic_vector(15 downto 0); -- Batas atas alamat, digunakan pada instruksi read
  AdSrcIn           : in std_logic_vector(15 downto 0); -- Alamat untuk read data
  AdDestIn          : in std_logic_vector(15 downto 0); -- Alamat untuk write data
  DataOut           : out std_logic_vector(7 downto 0); -- Read data
  StatusOut         : out std_logic_vector(7 downto 0); -- Status Koprosesor
  StatusOut2        : out std_logic_vector(7 downto 0); -- Status Koprosesor
  clk, reset        : in std_logic                      -- Clock dan reset
  );
end top_coprocessor_control;

architecture circuit of top_coprocessor_control is
    --TAMBAHAN : Sinyal untuk counter
    signal counter, next_counter          : std_logic_vector(7 downto 0) := (others => '0');
    signal reset_counter, start_counter : std_logic;
    --TAMBAHAN END
    component counter_up_8bit is
        port (
            clk    : in std_logic;              -- Sinyal clock
            start  : in std_logic;              -- Sinyal start untuk memulai counter
            reset  : in std_logic;              -- Sinyal reset untuk mereset counter
            count  : out std_logic_vector(7 downto 0)  -- Keluaran 8-bit counter
            );
    end component;
  
    signal RNG_buf : std_logic_vector(31 downto 0);  -- buffer RNG out
    
    type state_RNG_type is(RNG_IDLE, RNG_PROCESS, RNG_OUTPUT_DATA, RNG_DONE);
    signal RNG_STATE, NEXT_RNG_STATE : state_RNG_type:= RNG_IDLE;
    
    component RNG is
    port (
        clk: in std_logic;
        RNG_out: out std_logic_vector(31 downto 0)
        );
    end component RNG;
 
 --TAMBAHAN : sinyal untuk AES
  signal aes_data_in, aes_key_in                        : std_logic_vector(7 downto 0); -- 8 bit plaintext/key in
  signal aes_data_out                                   : std_logic_vector(127 downto 0); -- 128 bit encrypted text
  signal aes_dec_data_out                               : std_logic_vector(127 downto 0); -- 128bit decrypted text
  signal aes_valid_data_in, aes_valid_key_in            : std_logic; -- valid in flag
  signal aes_key_ready, aes_valid_out                   : std_logic; -- encrypt key ready flag
  signal aes_dec_key_ready, aes_dec_valid_out           : std_logic; -- decrypt key ready flag
  signal reset_AES                                      : std_logic; -- reset
  signal aes_ce, aes_dec_ce                             : std_logic; -- enable encrypt/decrypt
  signal s_AES_DONE                                     : std_logic; -- done flag
  --TAMBAHAN END
  
  --TAMBAHAN : ditambahkan sinyal untuk state machine AES
  type state_AES_type is (AES_IDLE,
                          AES_INPUT_KEY, AES_DEC_INPUT_KEY, AES_KEY_PROCESSING, AES_DEC_KEY_PROCESSING, AES_KEY_DONE, 
                          AES_INPUT_DATA, AES_DEC_INPUT_DATA, AES_DATA_PROCESSING, AES_DEC_DATA_PROCESSING,
                          AES_OUTPUT_DATA, AES_DONE);
  signal AES_STATE, NEXT_AES_STATE : state_AES_type := AES_IDLE;
 --TAMBAHAN END
 
 --TAMBAHAN : Aes Component
   component aes_enc is
   generic
      (
      KEY_SIZE             :  in    integer range 0 to 2 := 2            -- 0-128; 1-192; 2-256
      );
   port
      (
      DATA_I               :  in    std_logic_vector(7 downto 0);
      VALID_DATA_I         :  in    std_logic;
      KEY_I                :  in    std_logic_vector(7 downto 0);
      VALID_KEY_I          :  in    std_logic;
      RESET_I              :  in    std_logic;
      CLK_I                :  in    std_logic;
      CE_I                 :  in    std_logic;

      KEY_READY_O          :  out   std_logic;

      VALID_O              :  out   std_logic;
      DATA_O               :  out   std_logic_vector(127 downto 0)
      );
  end component;
  
  component aes_dec is
   generic
      (
      KEY_SIZE             :  in    integer range 0 to 2 := 2            -- 0-128; 1-192; 2-256
      );
   port
      (
      DATA_I               :  in    std_logic_vector(7 downto 0);
      VALID_DATA_I         :  in    std_logic;
      KEY_I                :  in    std_logic_vector(7 downto 0);
      VALID_KEY_I          :  in    std_logic;
      RESET_I              :  in    std_logic;
      CLK_I                :  in    std_logic;
      CE_I                 :  in    std_logic;

      KEY_READY_O          :  out   std_logic;

      VALID_O              :  out   std_logic;
      DATA_O               :  out   std_logic_vector(127 downto 0)
      );
  end component;
--TAMBAHAN END

    signal reg_to_hash :std_logic_vector(511 downto 0);
    signal block_ready, gen_hash : std_logic:= '0';
    signal hash : std_logic_vector(255 downto 0);
    signal reset_HASH : std_logic :='1';
    signal HASH_REQUEST : std_logic := '0';
    signal s_HASHDONE : std_logic := '0';
    
    type state_HASH_type is ( HASH_IDLE, HASH_INPUT_DATA, HASH_OUTPUT_DATA, HASH_PROCESS, HASH_DONE);
    signal HASH_STATE, NEXT_HASH_STATE : state_HASH_type:= HASH_IDLE;
    
    component sha_256 is
    port(
        clk  : in std_logic;
		rst : in std_logic;
		gen_hash : in std_logic;
		msg_0 : in std_logic_vector(31 downto 0);
		msg_1 : in std_logic_vector(31 downto 0);
		msg_2 : in std_logic_vector(31 downto 0);  
		msg_3 : in std_logic_vector(31 downto 0);
		msg_4 : in std_logic_vector(31 downto 0);
		msg_5 : in std_logic_vector(31 downto 0);
		msg_6 : in std_logic_vector(31 downto 0);
		msg_7 : in std_logic_vector(31 downto 0);
		msg_8 : in std_logic_vector(31 downto 0);
		msg_9 : in std_logic_vector(31 downto 0);
		msg_10 : in std_logic_vector(31 downto 0);
		msg_11 : in std_logic_vector(31 downto 0);
		msg_12 : in std_logic_vector(31 downto 0);
		msg_13 : in std_logic_vector(31 downto 0);
		msg_14 : in std_logic_vector(31 downto 0);
		msg_15 : in std_logic_vector(31 downto 0);

		block_ready : out std_logic;
		hash : out std_logic_vector(255 downto 0));
	end component sha_256;
	
	--TAMBAHAN : sinyal untuk adder
    signal add_a, add_b : STD_LOGIC_VECTOR(255 downto 0);
    signal r_add_a, r_add_b : STD_LOGIC_VECTOR(255 downto 0);
    signal add_sum, r_add_sum : STD_LOGIC_VECTOR(255 downto 0);
    signal add_cout, add_sub, add_cin, s_ADD_done : STD_LOGIC;
    
    type state_ADD_type is (ADD_IDLE, ADD_FETCH, SUB_FETCH, ADD_RUN, SUB_RUN, ADD_DONE);
    signal ADD_STATE, NEXT_ADD_STATE : state_ADD_type := ADD_IDLE;
   -- TAMBAHAN END
	-- TAMBAHAN : Komponen adder dan subtract
    component add_sub_256bit
        Port (
            a : in STD_LOGIC_VECTOR(255 downto 0);
            b : in STD_LOGIC_VECTOR(255 downto 0);
            sub : in STD_LOGIC;
            sum : out STD_LOGIC_VECTOR(255 downto 0);
            cout : out STD_LOGIC
        );
    end component;
    
    --TAMBAHAN : sinyal untuk multiplier
    signal s_mul_reset                  : STD_LOGIC := '0'; -- signal reset
    signal s_mul_start                  : STD_LOGIC := '0'; -- signal start
    signal s_mul_a, s_mul_b             : STD_LOGIC_VECTOR(255 downto 0); -- input wire
    signal s_mul_p                      : STD_LOGIC_VECTOR(511 downto 0); -- output wire
    signal r_mul_p                      : STD_LOGIC_VECTOR(511 downto 0); -- output reg
    signal s_MUL_done_temp, s_MUL_done  : STD_LOGIC;  -- block done & procces done
  
  type state_MUL_type is (MUL_IDLE, MUL_RUN, MUL_WAIT, MUL_DONE);
  signal MUL_STATE, NEXT_MUL_STATE : state_MUL_type := MUL_IDLE;
  -- TAMBAHAN END
    --TAMBAHAN : Komponen multiplier 256
    component fast_multiplier_256x256
        Port (
            clk     : in STD_LOGIC;
            reset   : in STD_LOGIC;
            start   : in STD_LOGIC;
 
            a       : in STD_LOGIC_VECTOR(255 downto 0);
            b       : in STD_LOGIC_VECTOR(255 downto 0);
            p       : out STD_LOGIC_VECTOR(511 downto 0);
            
            Run     : out STD_LOGIC;        -- Run signal
            Done    : out STD_LOGIC         -- Operation complete signal
        );
    end component;
    -- TAMBAHAN END    
    
    
    --TAMBAHAN : sinyal untuk division
    signal DIV_reset  : STD_LOGIC := '0';
    signal DIV_start  : STD_LOGIC := '0';
    -- a : dividend, b : divisor, p : quotient, r : remainder
    signal s_div_a, s_div_b, s_div_p, s_div_r : STD_LOGIC_VECTOR(255 downto 0);
    signal r_div_a, r_div_b, r_div_p, r_div_r : STD_LOGIC_VECTOR(255 downto 0);
    signal s_DIV_Done, s_DIV_Done_temp  : std_logic; 
  
    type state_DIV_type is (DIV_IDLE, DIV_RUN, DIV_WAIT, DIV_DONE);
    signal DIV_STATE, NEXT_DIV_STATE : state_DIV_type := DIV_IDLE;
    -- TAMBAHAN END
    
    --TAMBAHAN : Komponen division/modulus
    component division
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
    end component;
    
    signal reset_BC3                                            : std_logic :='1';
    signal s_key_done                                           : std_logic;
    signal key_BC3, input_BC3, enc_dec_BC3, ack_BC3, done_BC3   : std_logic;
    signal BC3_Mux                                              : std_logic := '0';
    signal status_BC3, clear_BC3                                : std_logic_vector(6 downto 0):= "0000000";
    signal data_in_BC3, data_out_BC3                            : std_logic_vector(63 downto 0);
    signal s_BC3DONE                                            : std_logic := '0';
    
    type state_BC3_type is(BC3_IDLE, BC3_DECRYPT_DATA_IN_INIT, BC3_DECRYPT_DATA_IN, BC3_DECRYPT_KEY, BC3_DECRYPT_PROCESS,
    BC3_ENCRYPT_DATA_IN_INIT, BC3_ENCRYPT_DATA_IN, BC3_ENCRYPT_KEY, BC3_ENCRYPT_PROCESS, BC3_OUTPUT, BC3_DONE,
    BC3_INPUT_KEY_ENCRYPT, BC3_INPUT_KEY_DECRYPT);
    signal BC3_STATE, NEXT_BC3_STATE : state_BC3_type:= BC3_IDLE;
    
	component  Kriptografi_BC3 is
        port (
            reset        : in  std_logic;
            clk          : in  std_logic;
            input_data   : in  std_logic_vector(63 downto 0);
            key_ready    : in  std_logic;
            input_ready  : in  std_logic;
            enc_dec      : in  std_logic;
            data_ack     : in  std_logic;
            output_ready : out std_logic;
            key_done     : out std_logic;
            out_crypto   : out std_logic_vector(63 downto 0)
            );
    end component;

    -- sinyal untuk instruction Buffer
	signal s_DataMEM, s_CommandIn, s_CommandIn_valid    : std_logic_vector(7 downto 0):= x"FF"; -- input ins buffer
	signal s_DataBuffer                                 : std_logic_vector(7 downto 0):= x"FF"; -- output data
    signal s_CommandBuffer                              : std_logic_vector(3 downto 0) := "1111"; -- output command
    signal s_commandBuffer2                             : std_logic_vector(2 downto 0) := "111";  -- output command
    signal s_AdDestBuffer, s_AdSrcBuffer, s_AdThBuffer  : std_logic_vector(15 downto 0); -- output address
    signal s_status                                     : std_logic; -- sequential/independent flag
    signal s_WEBuffer, s_REBuffer                       : std_logic :='0'; -- read/write contol
    signal s_EmptyBuffer, s_FullBuffer                  : std_logic :='0'; -- empty/full flag

    component InsBuffer2 is
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
            i_Data	    : in  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);
            i_Command	: in  STD_LOGIC_VECTOR (g_WIDTH-1 downto 0);
            i_AdTh	    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
            i_AdSrc	    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH-1 downto 0);
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
	end component;
    -- TAMBAHAN : sinyal untuk XOR unit
    signal s_XOR_a, s_XOR_b, s_XOR_out : std_logic_vector(255 downto 0);
    -- TAMBAHAN END
    
    -- SINYAL RUNNING COPROCESSOR
    signal s_HASHRunning, s_SHDMEMRunning, s_BC3Running : std_logic;
  
    --TAMBAHAN : Sinyal Running AES
    signal s_AESRunning : std_logic;
    --TAMBAHAN END
  
    --TAMBAHAN : sinyal running multiplier
    signal s_MULRunning        : std_logic; -- sinyal running dari state machine
    signal x_MULRunning        : std_logic; -- sinyal running dari block multiplier
    -- TAMBAHAN END
  
    --TAMBAHAN : sinyal running adder
    signal s_ADDRunning        : std_logic;
    -- TAMBAHAN END
  
    --TAMBAHAN : sinyal running divisor
    signal s_DIVRunning        : std_logic;
    -- TAMBAHAN END
  
    signal s_IncTail :std_logic :='0';
    signal s_IncTailBC3, s_IncTailHASH, s_IncTailSHDMEM :std_logic :='0';
  
    --TAMBAHAN : sinyal Increment Tail untuk FIFO InsBuffer
    signal s_IncTailAES     : std_logic := '0';
    --TAMBAHAN END
  
    -- TAMBAHAN : Sinyal Increment Tail FIFO dari adder
    signal s_IncTailAdder   : std_logic := '0';
    --TAMBAHAN END
  
    -- TAMBAHAN : Sinyal Increment Tail FIFO dari multiplier
    signal s_IncTailMult    : std_logic := '0';
    --TAMBAHAN END
  
    -- TAMBAHAN : Sinyal Increment Tail FIFO dari divisor
    signal s_IncTailDIV     : std_logic := '0';
    --TAMBAHAN END

    -- Shared memory
    type ram_type is array (0 to 651) of std_logic_vector(7 downto 0);
    signal shd_mem : ram_type:= (others=>X"00");
    
    -- shared memory controller
    signal s_src_addr, s_dest_addr, s_th_addr   : std_logic_vector(15 downto 0) := X"FFFF"; -- memoty addres signal
    signal n_RNG, n_HASH, n_AES, n_BC3, n_ADD, n_MULT, n_DIV          : integer range 1 to 64;
    signal s_SHDMEMDONE                         : std_logic := '0';
    
    type state_SHD_MEM_type is(SHD_MEM_IDLE, SHD_MEM_CPY_INIT, SHD_MEM_CPY_PROCESSING, SHD_MEM_CPY_BLOCK_PROCESSING,
    SHD_MEM_CPY_BLOCK_INIT, SHD_MEM_READ_INIT, SHD_MEM_READ_PROCESSING, SHD_MEM_READ_BLOCK_INIT,
    SHD_MEM_READ_BLOCK_PROCESSING, SHD_MEM_WRITE_INIT, SHD_MEM_WRITE_PROCESSING, SHD_MEM_WRITE_BLOCK_INIT,
    SHD_MEM_WRITE_BLOCK_PROCESSING, SHD_MEM_DONE);
    signal SHD_MEM_STATE, NEXT_SHD_MEM_STATE : state_SHD_MEM_type:= SHD_MEM_IDLE;
      
    -- instruction fetch control signal
    signal command_access   : std_logic := '1';
    signal coproc_done      : std_logic := '0';
     signal coproc_run      : std_logic := '0';
    signal s_TransferReady  : std_logic := '0';

begin

    theInsBuffer: InsBuffer2 
    port map (
        i_rst_sync      => reset,
        i_clk           => clk,
        i_wr_en         => s_WEBuffer,
        i_Data          => DataIn,
        i_Command       => s_CommandIn_valid,
        i_AdTh          => AdThIn,
        i_AdSrc         => AdSrcIn,
        i_AdDest        => AdDestIn,
        o_full          => s_FullBuffer,
        i_rd_en         => s_IncTail,
        o_Data          => s_DataBuffer,
        o_Command(3 downto 0) => s_CommandBuffer,
        o_Command(6 downto 4) => s_CommandBuffer2,
        o_Command(7)    => s_status,
        o_AdTh          => s_AdThBuffer,
        o_AdSrc         => s_AdSrcBuffer,
        o_AdDest        => s_AdDestBuffer,
        o_empty         => s_EmptyBuffer
    );
    
    theSim: Kriptografi_BC3 port map(
		reset => reset_BC3,
		clk           => clk,
		input_data    => data_in_BC3,
		key_ready     => key_BC3,
		input_ready   => input_BC3, 
		enc_dec       => enc_dec_BC3, 
		data_ack      => ack_BC3,
		output_ready  => done_BC3,
		key_done      => s_key_done,
		out_crypto    => data_out_BC3);

    
  --TAMBAHAN : instantiasi modul AES		
  AES_Encrypt: aes_enc
   generic map(
      KEY_SIZE => 2 -- Set this to the appropriate key size (0 for 128-bit, 1 for 192-bit, 2 for 256-bit)
   )
   port map(
      DATA_I       => aes_data_in,
      VALID_DATA_I => aes_valid_data_in,
      KEY_I        => aes_key_in,
      VALID_KEY_I  => aes_valid_key_in,
      RESET_I      => reset_AES,
      CLK_I        => clk,
      CE_I         => aes_ce,
      KEY_READY_O  => aes_key_ready,
      VALID_O      => aes_valid_out,
      DATA_O       => aes_data_out
   );
   
   AES_Decrypt: aes_dec
   generic map(
      KEY_SIZE => 2 -- Set this to the appropriate key size (0 for 128-bit, 1 for 192-bit, 2 for 256-bit)
   )
   port map(
      DATA_I       => aes_data_in,
      VALID_DATA_I => aes_valid_data_in,
      KEY_I        => aes_key_in,
      VALID_KEY_I  => aes_valid_key_in,
      RESET_I      => reset_AES,
      CLK_I        => clk,
      CE_I         => aes_dec_ce,
      KEY_READY_O  => aes_dec_key_ready,
      VALID_O      => aes_dec_valid_out,
      DATA_O       => aes_dec_data_out
   );
  --TAMBAHAN END
  theCounter : counter_up_8bit
        port map (
            clk    => clk,
            start  => start_counter,
            reset  => reset_counter,
            count  => counter
        );
        
   -- TAMBAHAN : instantiasi adder
   TheAdder : add_sub_256bit
        Port map (
            a => r_add_a,
            b => r_add_b,
            sub => add_sub,
            sum => add_sum,
            cout => add_cout
        );
  -- TAMBAHAN END
  
  -- TAMBAHAN : instantiasi multiplier
    TheMult : fast_multiplier_256x256
        Port map (
            clk     => clk,
            reset   => s_mul_reset,
            start   => s_mul_start,
            a       => s_mul_a,
            b       => s_mul_b,
            p       => s_mul_p,
            Run     => x_MULRunning,
            Done    => s_mul_Done_temp
        );
   -- TAMBAHAN END
   
   -- TAMBAHAN : divisor
       
    theDivisor : division
        Port map (
            clk       => clk,
            clk_en    => '1',
            reset     => DIV_reset,
            start     => DIV_start,
            done      => s_DIV_done_temp,
            a         => r_div_a,
            b         => r_div_b,
            p         => s_div_p,
            r         => s_div_r
        );
					
    theRNG: RNG port map(
                    clk => clk,
					RNG_out => RNG_buf
					);

    theHash: sha_256 port map(
        clk            => clk,
		rst            => reset_HASH,
		gen_hash       => gen_hash,
		msg_0          => reg_to_hash(511 downto 480),
		msg_1          => reg_to_hash(479 downto 448),
		msg_2          => reg_to_hash(447 downto 416),  
		msg_3          => reg_to_hash(415 downto 384),
		msg_4          => reg_to_hash(383 downto 352),
		msg_5          => reg_to_hash(351 downto 320),
		msg_6          => reg_to_hash(319 downto 288),
		msg_7          => reg_to_hash(287 downto 256),
		msg_8          => reg_to_hash(255 downto 224),
		msg_9          => reg_to_hash(223 downto 192),
		msg_10         => reg_to_hash(191 downto 160),
		msg_11         => reg_to_hash(159 downto 128),
		msg_12         => reg_to_hash(127 downto 96),
		msg_13         => reg_to_hash(95 downto 64),
		msg_14         => reg_to_hash(63 downto 32),
		msg_15         => reg_to_hash(31 downto 0),
		block_ready    => block_ready,
		hash           => hash
		);  

				
    Prefetch: process(clk, reset)
    begin
        if reset ='1' then
            s_WEBuffer <= '0';
        elsif rising_edge(clk) then
            s_CommandIn <= CommandIn;
          
            case s_CommandIn is
                -- for independent run
                when x"01"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"02"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"03"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"04"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"05"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"06"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"07"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"08"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"09"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"0A"=>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN : Command x"0B" menjadi valid. Digunakan untuk AES input key encrypt
                when x"0B" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"0C" menjadi valid. Digunakan untuk Addition
                when x"0C" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"0D" menjadi valid. Digunakan untuk Subtraction
                when x"0D" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"0E" menjadi valid. Digunakan untuk Multiplication
                when x"0E" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"12" menjadi valid. Digunakan untuk divisor
                when x"12" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"1B" menjadi valid. Digunakan untuk AES input data encrypt
                when x"1B" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"1C" menjadi valid. Digunakan untuk AES input key decrypt
                when x"1C" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"1D" menjadi valid. Digunakan untuk AES input data decrypt
                when x"1D" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                
                -- for sequential run
                when x"81"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"82"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"83"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"84"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"85"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"86"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"87"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"88"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"89"=>
                s_CommandIn_valid <= s_CommandIn;
                when x"8A"=>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN : Command x"8B" menjadi valid. Digunakan untuk AES input key encrypt
                when x"8B" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"8C" menjadi valid. Digunakan untuk Adder
                when x"8C" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"8D" menjadi valid. Digunakan untuk subtraction
                when x"8D" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"*E" menjadi valid. Digunakan untuk Multiplication
                when x"8E" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"92" menjadi valid. Digunakan untuk divisor
                when x"92" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"9B" menjadi valid. Digunakan untuk AES input data encrypt
                when x"9B" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"9C" menjadi valid. Digunakan untuk AES input key decrypt
                when x"9C" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                --TAMBAHAN : Command x"9D" menjadi valid. Digunakan untuk AES input data decrypt
                when x"9D" =>
                s_CommandIn_valid <= s_CommandIn;
                --TAMBAHAN END
                when x"FF" =>
                s_CommandIn_valid <= s_CommandIn;
                when others =>
            end case;
              
            If ((CommandIn = x"FF") and (s_CommandIn /= x"FF") and (s_CommandIn_valid /= x"FF") and (s_WEBuffer = '0')) then
            --If ((s_CommandIn = x"FF") and (s_CommandIn_valid /= x"FF")) then
                s_WEBuffer <= '1';
            else
                s_WEBuffer <= '0';
            end if;
        end if;
    end process;

    FETCH: process(reset, s_IncTailHASH, s_IncTailSHDMEM, s_IncTailAES, s_IncTailAdder, s_IncTailMult, s_IncTailDiv, s_IncTailBC3,
                    s_REBuffer, s_EmptyBuffer)
    begin
        if reset ='1' then
            s_REBuffer <= '0';
        else
            s_IncTail <= s_IncTailHASH  or s_IncTailSHDMEM or
                         s_IncTailAES or s_IncTailAdder or s_IncTailMult or s_IncTailDiv or s_IncTailBC3;
            if s_EmptyBuffer = '0' then
                s_REBuffer <='1';
            else 
                s_REBuffer <='0';
            end if;
        end if;
    end process;

    DECODE: process(clk, reset)
    begin
    -- Modified by Ganang Aditya Pratama, May 2025
        if reset ='1' then
            --coproc_done <= '0';
            command_access <= '1';
        elsif rising_edge(clk) then
    --	if coproc_done = '0' then
    --	coproc_done <= s_HASHDONE or s_SHDMEMDONE or s_AES_DONE or s_ADD_done or
    --	               s_MUL_done  or s_DIV_done or s_BC3DONE;
    --	end if;
        
    --	if coproc_run = '0' then
    --	   coproc_run <=s_HASHRunning or s_SHDMEMRunning or
    --			    s_AESRunning or s_MULRunning or s_ADDRunning or s_DIVRunning or s_BC3Running;
    --	end if;
        
            --if s_status = '1' then
                if (s_HASHRunning or s_SHDMEMRunning or
                    s_AESRunning or s_MULRunning or s_ADDRunning or s_DIVRunning or s_BC3Running) = '0' then
                    command_access <= '1';
                else
                    command_access <= '0';
                end if;
    --		if coproc_done = '1' then
    --		    command_access <= '1';
    --			if s_IncTail ='1' then
    --				command_access <= '0';
    --				coproc_done <= '0';
    --			end if;
    --		else
    --			if (s_HASHRunning or s_SHDMEMRunning or
    --			    s_AESRunning or s_MULRunning or s_ADDRunning or s_DIVRunning or s_BC3Running) = '0' then
    --			command_access <= '1';
    --			else
    --			command_access <= '0';
    --			end if;
    --		end if;
            --end if;
        end if;
    end process;

    Execute: process(clk, reset)
        begin
        if reset ='1' then
            SHD_MEM_STATE <= SHD_MEM_IDLE;
            HASH_STATE <= HASH_IDLE;
            BC3_STATE <= BC3_IDLE;
            --TAMBAHAN : 
            AES_STATE <= AES_IDLE;
            ADD_STATE <= ADD_IDLE;
            MUL_STATE <= MUL_IDLE;
            DIV_STATE <= DIV_IDLE;
            --TAMBAHAN END
        elsif rising_edge(clk) then
            SHD_MEM_STATE <= NEXT_SHD_MEM_STATE;
            HASH_STATE <= NEXT_HASH_STATE;
            BC3_STATE <= NEXT_BC3_STATE;
            --TAMBAHAN
            AES_STATE <= NEXT_AES_STATE;
            ADD_STATE <= NEXT_ADD_STATE;
            MUL_STATE <= NEXT_MUL_STATE;
            DIV_STATE <= NEXT_DIV_STATE;
            --TAMBAHAN END
        end if;
    end process;

    WRITEBACK: process(clk, reset)
    begin
        if reset ='1' then
            StatusOut <= x"FF";
            StatusOut2 <= x"FF";
        elsif rising_edge(clk) then
            StatusOut <= s_MULRunning & s_SHDMEMRunning & s_AESRunning & s_ADDRunning & s_TransferReady & s_FullBuffer & s_EmptyBuffer & '0';
            StatusOut2 <= s_DIVRunning & s_HASHRunning & s_BC3Running & "00000";
        end if;
    end process;

--TAMBAHAN : AES
     control_unit_AES : process(AES_STATE, NEXT_AES_STATE, counter, s_CommandBuffer, aes_key_ready, aes_valid_out,
                                aes_dec_key_ready, aes_dec_valid_out, s_status, s_IncTail)
     begin
        if (AES_STATE = AES_IDLE) and ((s_CommandBuffer = x"b") and (s_CommandBuffer2 = "000") and ((command_access = '1') or (s_status = '0'))
            and (s_IncTail = '0')) then
            NEXT_AES_STATE <= AES_INPUT_KEY;
        elsif (AES_STATE = AES_IDLE) and ((s_CommandBuffer = x"b") and (s_CommandBuffer2 = "001") and ((command_access = '1') or (s_status = '0'))
            and (s_IncTail = '0')) then
            NEXT_AES_STATE <= AES_INPUT_DATA;
            
        elsif (AES_STATE = AES_IDLE) and ((s_CommandBuffer = x"c") and (s_CommandBuffer2 = "001") and ((command_access = '1') or (s_status = '0'))
            and (s_IncTail = '0')) then
            NEXT_AES_STATE <= AES_DEC_INPUT_KEY;
        elsif (AES_STATE = AES_IDLE) and ((s_CommandBuffer = x"d") and (s_CommandBuffer2 = "001") and ((command_access = '1') or (s_status = '0'))
            and (s_IncTail = '0')) then
            NEXT_AES_STATE <= AES_DEC_INPUT_DATA;
            
        elsif (AES_STATE = AES_INPUT_KEY) and (counter = x"1F") then
            NEXT_AES_STATE <= AES_KEY_PROCESSING;
        elsif (AES_STATE = AES_KEY_PROCESSING) and (aes_key_ready = '1') then
            NEXT_AES_STATE <= AES_KEY_DONE;
        elsif (AES_STATE = AES_KEY_DONE) then
            NEXT_AES_STATE <= AES_IDLE;
        
        elsif (AES_STATE = AES_DEC_INPUT_KEY) and (counter = x"1F") then
            NEXT_AES_STATE <= AES_DEC_KEY_PROCESSING;
        elsif (AES_STATE = AES_DEC_KEY_PROCESSING) and (aes_dec_key_ready = '1') then
            NEXT_AES_STATE <= AES_KEY_DONE;
            
        elsif (AES_STATE = AES_INPUT_DATA) and (counter = x"0F") then
            NEXT_AES_STATE <= AES_DATA_PROCESSING;
        elsif (AES_STATE = AES_DATA_PROCESSING) and (aes_valid_out = '1') then
            NEXT_AES_STATE <= AES_OUTPUT_DATA;
            
        elsif (AES_STATE = AES_DEC_INPUT_DATA) and (counter = x"0F") then
            NEXT_AES_STATE <= AES_DEC_DATA_PROCESSING;
        elsif (AES_STATE = AES_DEC_DATA_PROCESSING) and (aes_dec_valid_out = '1') then
            NEXT_AES_STATE <= AES_OUTPUT_DATA;    
            
        elsif (AES_STATE = AES_OUTPUT_DATA) then
            NEXT_AES_STATE <= AES_DONE; 
        elsif (AES_STATE = AES_DONE) then
            NEXT_AES_STATE <= AES_IDLE;    
        end if;
     end process;
 
    state_AES: process(clk)
    begin
        case AES_STATE is
            when AES_IDLE =>
                reset_AES <='1';
                aes_ce <= '1';
                aes_dec_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '0';
                reset_counter <= '1';
                start_counter <= '0';
                --if (NEXT_AES_STATE = AES_INPUT_KEY) or (NEXT_AES_STATE = AES_INPUT_DATA) then
                if (NEXT_AES_STATE = AES_IDLE) then
                  s_IncTailAES <= '0';
                else s_IncTailAES <= '1';
                end if;
            when AES_INPUT_KEY =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_dec_ce <= '0';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '1';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';		    
                reset_counter <= '0';
                start_counter <= '1';	
                aes_key_in <= shd_mem(55 - CONV_INTEGER(counter));
            when AES_DEC_INPUT_KEY =>
                reset_AES <='0';
                aes_ce <= '0';
                aes_dec_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '1';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';		    
                reset_counter <= '0';
                start_counter <= '1';	
                aes_key_in <= shd_mem(55 - CONV_INTEGER(counter));	    
            when AES_KEY_PROCESSING =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_dec_ce <= '0';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
             when AES_DEC_KEY_PROCESSING =>
                reset_AES <='0';
                aes_ce <= '0';
                aes_dec_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
             when AES_INPUT_DATA =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_dec_ce <= '0';
                aes_valid_data_in <= '1';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '0';
                start_counter <= '1';
                aes_data_in <= shd_mem(71 - CONV_INTEGER(counter));
             when AES_DEC_INPUT_DATA =>
                reset_AES <='0';
                aes_ce <= '0';
                aes_dec_ce <= '1';
                aes_valid_data_in <= '1';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '0';
                start_counter <= '1';
                aes_data_in <= shd_mem(71 - CONV_INTEGER(counter));
             when AES_DATA_PROCESSING =>
                reset_AES <='0';
                 aes_ce <= '1';
                aes_dec_ce <= '0';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
             when AES_DEC_DATA_PROCESSING =>
                reset_AES <='0';
                aes_ce <= '0';
                aes_dec_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
             when AES_OUTPUT_DATA =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
              when AES_DONE =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '1';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
              when AES_KEY_DONE =>
                reset_AES <='0';
                aes_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '1';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
              when others =>
                reset_AES <='1';
                aes_ce <= '1';
                aes_valid_data_in <= '0';
                aes_valid_key_in <= '0';
                s_AES_done <= '0';
                s_AESRunning <= '1';
                s_IncTailAES <= '0';
                reset_counter <= '1';
                start_counter <= '0';
        end case;
    end process;
--TAMBAHAN END

    BC3_input_MUX: process(BC3_Mux, shd_mem)
        begin
        if BC3_Mux = '0' then --key
            for n_BC3 in 1 to 8 loop
                data_in_BC3(((8*n_BC3)-1) downto (8*(n_BC3-1))) <= shd_mem(8-n_BC3);
            end loop;
        elsif  BC3_Mux = '1' then--data
            for n_BC3 in 1 to 8 loop
                data_in_BC3(((8*n_BC3)-1) downto (8*(n_BC3-1))) <= shd_mem(16-n_BC3);
            end loop;
        end if;
    end process;
    
    state_BC3: process(command_access, s_key_done, done_BC3, s_CommandBuffer, BC3_STATE,s_status)
  begin
  case BC3_STATE is
		when BC3_IDLE =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			s_BC3Running <='0';
			s_BC3DONE <= '0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			BC3_Mux <= '0';
			s_IncTailBC3 <='0';
			if (command_access = '1') or (s_status = '0') then
				case s_CommandBuffer is
					when "0110" => ---6 
						--s_IncTailBC3 <='1';
						NEXT_BC3_STATE <= BC3_INPUT_KEY_ENCRYPT;
					when "0111" => ---7
						--s_IncTailBC3 <='1';
						NEXT_BC3_STATE <= BC3_INPUT_KEY_DECRYPT;
					when "1001" => ---9 
						--s_IncTailBC3 <='1';
						NEXT_BC3_STATE <= BC3_ENCRYPT_DATA_IN_INIT;
					when "1010" => ---10
						--s_IncTailBC3 <='1';
						NEXT_BC3_STATE <= BC3_DECRYPT_DATA_IN_INIT;
					when others=>
						NEXT_BC3_STATE <= BC3_IDLE;
						--s_IncTailBC3 <='0';
				end case;
				else
			s_IncTailBC3 <='0';
			NEXT_BC3_STATE <= BC3_IDLE;
			end if;
		when BC3_INPUT_KEY_ENCRYPT=>
			clear_BC3 <= "0000000";
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='1';
			reset_BC3 <= '0';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			BC3_Mux <= '0';
			NEXT_BC3_STATE <= BC3_ENCRYPT_KEY;
			
		when BC3_INPUT_KEY_DECRYPT=>
			clear_BC3 <= "0000000";
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='1';
			reset_BC3 <= '0';
			enc_dec_BC3<= '1';
			input_BC3 <= '0';
			key_BC3 <= '0';
			BC3_Mux <= '0';
			NEXT_BC3_STATE <= BC3_DECRYPT_KEY;

		when BC3_ENCRYPT_KEY =>
			clear_BC3 <= "0000000";
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '1';
			key_BC3 <= '1';
			BC3_Mux <= '0';
			if s_key_done = '1' then
			NEXT_BC3_STATE <= BC3_ENCRYPT_DATA_IN;
			else
			NEXT_BC3_STATE <= BC3_ENCRYPT_KEY;
			end if;
			
		when BC3_DECRYPT_KEY =>
			clear_BC3 <= "0000000";
			BC3_Mux <= '0';
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '1';
			key_BC3 <= '1';
			input_BC3 <= '1';
			if s_key_done = '1' then
			NEXT_BC3_STATE <= BC3_DECRYPT_DATA_IN;
			else
			NEXT_BC3_STATE <= BC3_DECRYPT_KEY;
			end if;			
        when BC3_ENCRYPT_DATA_IN_INIT =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			s_BC3Running <='0';
			s_BC3DONE <= '0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			BC3_Mux <= '0';
			s_IncTailBC3 <='1';
			NEXT_BC3_STATE <= BC3_ENCRYPT_DATA_IN;
			
		when BC3_ENCRYPT_DATA_IN =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '1';
			key_BC3 <= '0';
			BC3_Mux <= '1';
			NEXT_BC3_STATE <=BC3_ENCRYPT_PROCESS;

			
		when BC3_ENCRYPT_PROCESS =>
			clear_BC3 <= "1111111";
			BC3_Mux <= '1';
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '1';
			key_BC3 <= '0';
			if done_BC3 = '1' then
			NEXT_BC3_STATE <= BC3_OUTPUT;
			else
			NEXT_BC3_STATE <= BC3_ENCRYPT_PROCESS;
			end if;
		
		when BC3_DECRYPT_DATA_IN_INIT =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			s_BC3Running <='0';
			s_BC3DONE <= '0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			BC3_Mux <= '0';
			s_IncTailBC3 <='1';
			NEXT_BC3_STATE <= BC3_DECRYPT_DATA_IN;
		
		when BC3_DECRYPT_DATA_IN =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '1';
			input_BC3 <= '1';
			key_BC3 <= '0';
			BC3_Mux <= '1';
			NEXT_BC3_STATE <=BC3_DECRYPT_PROCESS;
		
		when BC3_DECRYPT_PROCESS =>
			clear_BC3 <= "1111111";
			BC3_Mux <= '1';
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '1';
			input_BC3 <= '1';
			key_BC3 <= '0';
			if done_BC3 = '1' then
				NEXT_BC3_STATE <= BC3_OUTPUT;
			else
				NEXT_BC3_STATE <= BC3_DECRYPT_PROCESS;
			end if;
			
		when BC3_OUTPUT =>
			clear_BC3 <= "1111111";
			BC3_Mux <= '1';
			ack_BC3 <= '0';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			NEXT_BC3_STATE <= BC3_DONE;
			
		when BC3_DONE =>
			clear_BC3 <= "1111111";
			BC3_Mux <= '1';
			ack_BC3 <= '1';
			s_BC3Running <='1';
			s_IncTailBC3 <='0';
			reset_BC3 <= '1';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			s_BC3DONE <= '1';
			NEXT_BC3_STATE <= BC3_IDLE;
			
		when others =>
			clear_BC3 <= "1111111";
			ack_BC3 <= '0';
			BC3_Mux <= '1';
			s_BC3Running <='1';
			s_BC3DONE <= '0';
			s_IncTailBC3 <='0';
			reset_BC3 <= '0';
			enc_dec_BC3<= '0';
			input_BC3 <= '0';
			key_BC3 <= '0';
			NEXT_BC3_STATE <= BC3_IDLE;
		end case;
  end process;

--  control_BC3: process(command_access, s_key_done, done_BC3, s_CommandBuffer, s_CommandBuffer2, BC3_STATE, NEXT_BC3_STATE,
--  s_status)
--  begin
--  case BC3_STATE is
--		when BC3_IDLE =>		
--			if ((command_access = '1') or (s_status = '0')) and (s_CommandBuffer2 = "000")  then
--				case s_CommandBuffer is
--					when "0110" => ---6 						
--						NEXT_BC3_STATE <= BC3_INPUT_KEY_ENCRYPT;
--					when "0111" => ---7						
--						NEXT_BC3_STATE <= BC3_INPUT_KEY_DECRYPT;
--					when "1001" => ---9 						
--						NEXT_BC3_STATE <= BC3_ENCRYPT_DATA_IN;
--					when "1010" => ---10						
--						NEXT_BC3_STATE <= BC3_DECRYPT_DATA_IN;
--					when others=>
--						NEXT_BC3_STATE <= BC3_IDLE;
--				end case;
--				else			
--			NEXT_BC3_STATE <= BC3_IDLE;
--			end if;
--		when BC3_INPUT_KEY_ENCRYPT=>			
--			NEXT_BC3_STATE <= BC3_ENCRYPT_KEY;
			
--		when BC3_INPUT_KEY_DECRYPT=>			
--			NEXT_BC3_STATE <= BC3_DECRYPT_KEY;

--		when BC3_ENCRYPT_KEY =>
--			if s_key_done = '1' then
--			NEXT_BC3_STATE <= BC3_ENCRYPT_DATA_IN;
--			else
--			NEXT_BC3_STATE <= BC3_ENCRYPT_KEY;
--			end if;
			
--		when BC3_DECRYPT_KEY =>			
--			if s_key_done = '1' then
--			NEXT_BC3_STATE <= BC3_DECRYPT_DATA_IN;
--			else
--			NEXT_BC3_STATE <= BC3_DECRYPT_KEY;
--			end if;			

--		when BC3_ENCRYPT_DATA_IN =>			
--			NEXT_BC3_STATE <=BC3_ENCRYPT_PROCESS;

			
--		when BC3_ENCRYPT_PROCESS =>			
--			if done_BC3 = '1' then
--			NEXT_BC3_STATE <= BC3_OUTPUT;
--			else
--			NEXT_BC3_STATE <= BC3_ENCRYPT_PROCESS;
--			end if;
		
--		when BC3_DECRYPT_DATA_IN =>
--			NEXT_BC3_STATE <=BC3_DECRYPT_PROCESS;
		
--		when BC3_DECRYPT_PROCESS =>			
--			if done_BC3 = '1' then
--				NEXT_BC3_STATE <= BC3_OUTPUT;
--			else
--				NEXT_BC3_STATE <= BC3_DECRYPT_PROCESS;
--			end if;
			
--		when BC3_OUTPUT =>
--			NEXT_BC3_STATE <= BC3_DONE;
			
--		when BC3_DONE =>
--			NEXT_BC3_STATE <= BC3_IDLE;
			
--		when others =>
--			NEXT_BC3_STATE <= BC3_IDLE;
--		end case;
--  end process;
  
--  state_BC3: process(clk)
--  begin
--  if rising_edge(clk) then
--    case BC3_STATE is
--		when BC3_IDLE =>
--			clear_BC3 <= "1111111";
--			ack_BC3 <= '0';
--			s_BC3Running <='0';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			BC3_Mux <= '0';
--			s_IncTailBC3 <='0';
			
--		when BC3_INPUT_KEY_ENCRYPT=>
--			clear_BC3 <= "0000000";
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '0';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			BC3_Mux <= '0';
--			s_IncTailBC3 <='1';
			
--		when BC3_INPUT_KEY_DECRYPT=>
--			clear_BC3 <= "0000000";
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '0';
--			enc_dec_BC3<= '1';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			BC3_Mux <= '0';
--			s_IncTailBC3 <='1';

--		when BC3_ENCRYPT_KEY =>
--			clear_BC3 <= "0000000";
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '1';
--			key_BC3 <= '1';
--			BC3_Mux <= '0';
--			s_IncTailBC3 <='0';
			
--		when BC3_DECRYPT_KEY =>
--			clear_BC3 <= "0000000";
--			BC3_Mux <= '0';
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '1';
--			key_BC3 <= '1';
--			input_BC3 <= '1';
--            s_IncTailBC3 <='0';			

--		when BC3_ENCRYPT_DATA_IN =>
--			clear_BC3 <= "1111111";
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '1';
--			key_BC3 <= '1';
--			BC3_Mux <= '1';
--			s_IncTailBC3 <='1';
			
--		when BC3_ENCRYPT_PROCESS =>
--			clear_BC3 <= "1111111";
--			BC3_Mux <= '1';
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '1';
--			key_BC3 <= '0';
--			s_IncTailBC3 <='0';
		
--		when BC3_DECRYPT_DATA_IN =>
--			clear_BC3 <= "1111111";
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '1';
--			input_BC3 <= '1';
--			key_BC3 <= '1';
--			BC3_Mux <= '1';
--			s_IncTailBC3 <='1';
		
--		when BC3_DECRYPT_PROCESS =>
--			clear_BC3 <= "1111111";
--			BC3_Mux <= '1';
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '1';
--			input_BC3 <= '1';
--			key_BC3 <= '0';
--			s_IncTailBC3 <='0';
			
--		when BC3_OUTPUT =>
--			clear_BC3 <= "1111111";
--			BC3_Mux <= '1';
--			ack_BC3 <= '0';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			s_IncTailBC3 <='0';
			
--		when BC3_DONE =>
--			clear_BC3 <= "1111111";
--			BC3_Mux <= '1';
--			ack_BC3 <= '1';
--			s_BC3Running <='1';
--			reset_BC3 <= '1';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			s_BC3DONE <= '1';
--			s_IncTailBC3 <='0';
			
--		when others =>
--			clear_BC3 <= "1111111";
--			ack_BC3 <= '0';
--			BC3_Mux <= '1';
--			s_BC3Running <='1';
--			s_BC3DONE <= '0';
--			reset_BC3 <= '0';
--			enc_dec_BC3<= '0';
--			input_BC3 <= '0';
--			key_BC3 <= '0';
--			s_IncTailBC3 <='0';
--		end case;
--  end if;
--  end process;


    HASH_input:	for n_HASH in 1 to 64 generate
        reg_to_hash(((8*n_HASH)-1) downto (8*(n_HASH-1))) <= shd_mem(152-n_HASH);
	end generate;
  
  state_HASH: process(HASH_STATE,command_access, block_ready,s_CommandBuffer, s_CommandBuffer2, s_status)
  begin
   case HASH_STATE is
		when HASH_IDLE =>
			s_HASHRunning <='0';
			s_HASHDONE <= '0';
			reset_HASH <= '1';
			gen_hash <= '0';
			HASH_REQUEST <= '0';
			s_IncTailHASH <='0';
			if (command_access = '1') or (s_status = '0') then
			case s_CommandBuffer is
				when "0101" =>
				    if s_CommandBuffer2 = "000" then
				        --s_IncTailHASH <='1';
					    NEXT_HASH_STATE <= HASH_INPUT_DATA;
					else
					   --s_IncTailHASH <='0';
					   NEXT_HASH_STATE <= HASH_IDLE;
				    end if;
				when others =>
					--s_IncTailHASH <='0';
					NEXT_HASH_STATE <= HASH_IDLE;
			end case;
			else
				NEXT_HASH_STATE <= HASH_IDLE;
				--s_IncTailHASH <='0';
			end if;

   		when HASH_INPUT_DATA =>
			s_HASHRunning <='1';
			s_HASHDONE <= '0';
			s_IncTailHASH <='1';
			reset_HASH <= '0';
			gen_hash <= '0';
			HASH_REQUEST <= '0';
			NEXT_HASH_STATE <= HASH_PROCESS;
			
		when HASH_PROCESS =>
			s_HASHRunning <='1';
			s_HASHDONE <= '0';
			s_IncTailHASH <='0';
			reset_HASH <= '0';
			gen_hash <= '1';
			HASH_REQUEST <= '0';
			if block_ready = '1' then
			NEXT_HASH_STATE <= HASH_OUTPUT_DATA;
			else
			NEXT_HASH_STATE <= HASH_PROCESS;
			end if;
			
		when HASH_OUTPUT_DATA =>
			s_HASHRunning <='1';
			s_HASHDONE <= '0';
			s_IncTailHASH <='0';
			reset_HASH <= '0';
			gen_hash <= '0';
			HASH_REQUEST <= '1';
			NEXT_HASH_STATE <= HASH_DONE;
			
		when HASH_DONE =>
			s_HASHRunning <='1';
			s_IncTailHASH <='0';
			reset_HASH <= '1';
			HASH_REQUEST <= '0';
			gen_hash <= '0';
			s_HASHDONE <= '1';
			NEXT_HASH_STATE <= HASH_IDLE;
		when others =>
			s_HASHRunning <='1';
			s_HASHDONE <= '0';
			s_IncTailHASH <='0';
			reset_HASH <= '1';
			HASH_REQUEST <= '0';
			gen_hash <= '0';
			NEXT_HASH_STATE <= HASH_IDLE;
        end case;
    end process;
  --TAMBAHAN : Menghubungkan adder ke shared memori
  -- Generate untuk add_a
    input_add_a: for i in 1 to 32 generate
        add_a(i*8-1 downto (i-1)*8) <= shd_mem(216 - i);
    end generate;

    -- Generate untuk add_b
    input_add_b: for i in 1 to 32 generate
        add_b(i*8-1 downto (i-1)*8) <= shd_mem(248 - i);
    end generate;
    
    -- control unit untuk adder
    control_unit_adder: process(s_CommandBuffer, s_CommandBuffer2, ADD_STATE, NEXT_ADD_STATE, s_status, s_IncTail, command_access)
    begin
        case ADD_STATE is
            when ADD_IDLE =>
                if ((command_access = '1') or (s_status = '0')) and (s_IncTail = '0') and ((s_CommandBuffer = x"c") and (s_CommandBuffer2 = "000"))then
                    NEXT_ADD_STATE <= ADD_FETCH;
                elsif ((command_access = '1') or (s_status = '0')) and (s_IncTail = '0') and ((s_CommandBuffer = x"d") and (s_CommandBuffer2 = "000"))then
                    NEXT_ADD_STATE <= SUB_FETCH;
                end if;
            when ADD_FETCH =>
                NEXT_ADD_STATE <= ADD_RUN;
            when SUB_FETCH =>
                NEXT_ADD_STATE <= SUB_RUN;
            when ADD_RUN =>
                NEXT_ADD_STATE <= ADD_DONE;
            when SUB_RUN =>
                NEXT_ADD_STATE <= ADD_DONE;  
            when ADD_DONE =>
                NEXT_ADD_STATE <= ADD_IDLE; 
        end case;
    end process;
    
    -- state machine untuk adder
    state_Adder : process(clk, ADD_STATE, NEXT_ADD_STATE)
    begin
        if rising_edge(clk) then
            case ADD_STATE is
                when ADD_IDLE =>
                    r_add_a <= add_a;
                    r_add_b <= add_b;               
                    add_sub <= '0';
                    s_IncTailAdder <= '0';
                    s_ADDRunning <= '0';
                    s_ADD_done <= '0';
                when ADD_FETCH =>
                    r_add_a <= add_a;
                    r_add_b <= add_b;               
                    add_sub <= '0';
                    s_IncTailAdder <= '1';
                    s_ADDRunning <= '1';
                    s_ADD_done <= '0';
                when SUB_FETCH =>
                    r_add_a <= add_a;
                    r_add_b <= add_b;               
                    add_sub <= '0';
                    s_IncTailAdder <= '1';
                    s_ADDRunning <= '1';
                    s_ADD_done <= '0';
                when ADD_RUN =>
                    add_sub <= '0';
                    
                    s_IncTailAdder <= '0'; 
                    s_ADDRunning <= '1';
                    s_ADD_done <= '0';
                when SUB_RUN =>
                    add_sub <= '1';
                    
                    s_IncTailAdder <= '0'; 
                    s_ADDRunning <= '1';
                    s_ADD_done <= '0';
                when ADD_DONE =>        
                   r_add_sum <= add_sum;   
                   s_IncTailAdder <= '0'; 
                   s_ADDRunning <= '1';
                   s_ADD_done <= '1';
            end case;
        end if;
    end process;
    --TAMBAHAN END
    
    --TAMBAHAN : multiplier
    -- input data multiplier
    input_mul_a : for i in 1 to 32 generate
        s_mul_a(i*8-1 downto (i-1)*8) <= shd_mem(312 - i);
    end generate;
    
    input_mul_b : for i in 1 to 32 generate
        s_mul_b(i*8-1 downto (i-1)*8) <= shd_mem(344 - i);
    end generate;
    
    --control unit untuk multiplier
   control_unit_Mult: process(s_CommandBuffer, s_CommandBuffer2, MUL_STATE, NEXT_MUL_STATE, s_status, s_IncTail, command_access, s_mul_Done_temp)
    begin
            case MUL_STATE is
                when MUL_IDLE =>
                    if ((command_access = '1') or (s_status = '0')) and (s_IncTail = '0') and ((s_CommandBuffer = x"e") and (s_CommandBuffer2 = "000"))then
                        NEXT_MUL_STATE <= MUL_RUN;
                    end if;
                when MUL_RUN =>
                    NEXT_MUL_STATE <= MUL_WAIT;
                when MUL_WAIT =>
                    if s_mul_Done_temp = '1' then
                        NEXT_MUL_STATE <= MUL_DONE; 
                    end if;
                when MUL_DONE =>
                    NEXT_MUL_STATE <= MUL_IDLE; 
            end case;
    end process;
    
    state_Multiplier : process(clk, MUL_STATE, NEXT_MUL_STATE)
    begin
        if rising_edge(clk) then
            case MUL_STATE is
                when MUL_IDLE =>
                    s_mul_start <= '0'; 
                    s_MulRunning <= '0';
                    s_MUL_done <= '0';
                    if (NEXT_MUL_STATE = MUL_RUN) then
                        s_IncTailMult <= '1';
                    else s_IncTailMult <= '0';
                    end if;
                when MUL_RUN =>
                    s_mul_start <= '1';
                    s_IncTailMult <= '0'; 
                    s_MulRunning <= '1';
                    s_MUL_done <= '0';
                when MUL_WAIT =>
                    s_mul_start <= '0';
                    s_IncTailMult <= '0'; 
                    s_MulRunning <= '1';
                    s_MUL_done <= '0';
                when MUL_DONE =>   
                    r_mul_p <= s_mul_p;       
                    
                    s_mul_start <= '0'; 
                    s_IncTailMult <= '0'; 
                    s_MulRunning <= '0';
                    s_MUL_done <= '1';
            end case;
        end if;
    end process;
    --TAMBAHAN END
    
    --control unit untuk Divisor
   control_unit_Div: process(s_CommandBuffer, s_CommandBuffer2, DIV_STATE, NEXT_DIV_STATE, s_status, s_IncTail, command_access, s_div_done_temp)
    begin
            case DIV_STATE is
                when DIV_IDLE =>
                    if ((command_access = '1') or (s_status = '0')) and (s_IncTail = '0') and ((s_CommandBuffer = x"2") and (s_CommandBuffer2 = "001"))then
                        NEXT_DIV_STATE <= DIV_RUN;
                    end if;
                when DIV_RUN =>
                    NEXT_DIV_STATE <= DIV_WAIT;
                when DIV_WAIT =>
                    if s_div_Done_temp = '1' then
                        NEXT_DIV_STATE <= DIV_DONE; 
                    end if;
                when DIV_DONE =>
                    NEXT_DIV_STATE <= DIV_IDLE; 
            end case;
    end process;
        
    input_div_a : for i in 1 to 32 generate
        s_div_a(i*8-1 downto (i-1)*8) <= shd_mem(440 - i);
    end generate;
    
    input_div_b : for i in 1 to 32 generate
        s_div_b(i*8-1 downto (i-1)*8) <= shd_mem(472 - i);
    end generate;
    
    state_divisor : process(clk, DIV_STATE, NEXT_DIV_STATE)
    begin
        if rising_edge(clk) then
            case DIV_STATE is
                when DIV_IDLE =>
                    r_div_a <= s_div_a;
                    r_div_b <= s_div_b;               
                    
                    div_start <= '0';
                    s_DIVRunning <= '0';
                    s_div_done <= '0';
                    if (NEXT_DIV_STATE = DIV_RUN) then
                        s_IncTailDiv <= '1';
                    else s_IncTailDiv <= '0';
                    end if;
                when DIV_RUN =>
                    div_start <= '1';
                    s_IncTailDiv <= '0'; 
                    s_DivRunning <= '1';
                    s_div_done <= '0';
                when DIV_WAIT =>
                    div_start <= '0';
                    s_IncTailDiv <= '0'; 
                    s_DivRunning <= '1';
                    s_div_done <= '0';
                when DIV_DONE =>   
                    r_div_p <= s_div_p;
                    r_div_r <= s_div_r;       
                    
                    div_start <= '0';
                    s_IncTailDiv <= '0'; 
                    s_DivRunning <= '1';
                    s_div_done <= '1';
            end case;
        end if;
    end process;
       
   -- TAMBAHAN END          
   
   -- TAMBAHAN : XOR
   -- input XOR
   input_XOR_a : for i in 1 to 32 generate
        s_XOR_a(i*8-1 downto (i-1)*8) <= shd_mem(568 - i);
    end generate;
    
    input_XOR_b : for i in 1 to 32 generate
        s_XOR_b(i*8-1 downto (i-1)*8) <= shd_mem(600 - i);
    end generate;
    -- proses XOR
    s_XOR_out <= s_XOR_a xor s_XOR_b; 
    
   control_SHD_MEM : process(SHD_MEM_STATE, NEXT_SHD_MEM_STATE, CommandIn, command_access,
                            s_status, s_CommandBuffer, s_CommandBuffer2, s_src_addr, s_th_addr)
   begin
    case SHD_MEM_STATE is
		when SHD_MEM_IDLE =>			
			--TAMBAHAN : s_CommandBuffer2 = "000", supaya hanya memperhatikan s_CommandBuffer
			if (s_CommandBuffer2 = "000") and ((command_access ='1') or (s_status = '0')) then
			--TAMBAHAN END
                case s_CommandBuffer is
                    when "0001" => ---memcpy
                        NEXT_SHD_MEM_STATE <= SHD_MEM_CPY_INIT;
                        
                    when "0010" => ---read
                       
                        NEXT_SHD_MEM_STATE <= SHD_MEM_READ_INIT;
                    
                    when "0011" => ---write
                        
                        NEXT_SHD_MEM_STATE <= SHD_MEM_WRITE_INIT;
        
                    when "0100" =>                        
                        NEXT_SHD_MEM_STATE <= SHD_MEM_CPY_BLOCK_INIT;
                        
                    when others =>
                end case;
		    end if;
		when SHD_MEM_CPY_INIT=>			
			NEXT_SHD_MEM_STATE <= SHD_MEM_CPY_PROCESSING;
			
		when SHD_MEM_CPY_PROCESSING=>			
			NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
			
		when SHD_MEM_READ_INIT =>			
			NEXT_SHD_MEM_STATE <= SHD_MEM_READ_PROCESSING;
			
		when SHD_MEM_READ_PROCESSING=>			
			if CommandIn = x"00" then
			     NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
			else
			     NEXT_SHD_MEM_STATE <= SHD_MEM_READ_PROCESSING;
			end if;
		
		when SHD_MEM_WRITE_INIT =>			
			NEXT_SHD_MEM_STATE <= SHD_MEM_WRITE_PROCESSING;
			
		when SHD_MEM_WRITE_PROCESSING=>
			NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
			
		when SHD_MEM_CPY_BLOCK_INIT=>
			NEXT_SHD_MEM_STATE <= SHD_MEM_CPY_BLOCK_PROCESSING;
			
		when SHD_MEM_CPY_BLOCK_PROCESSING=>
			if s_src_addr = s_th_addr then
				NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
			else
				NEXT_SHD_MEM_STATE <= SHD_MEM_CPY_BLOCK_PROCESSING;
			end if;

		when SHD_MEM_DONE=>
			NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
						
		when others =>
			NEXT_SHD_MEM_STATE <= SHD_MEM_IDLE;
	   end case;
   end process; 
   
   state_SHD_MEM: process(clk)
   begin
   if rising_edge(clk) then
   for n_RNG in 1 to 4 loop
                shd_mem(636-n_RNG) <= RNG_buf(((8*n_RNG)-1) downto (8*(n_RNG-1)));
            end loop;
            
            --BC3 output 
            for n_BC3 in 1 to 8 loop
                shd_mem(24-n_BC3) <= data_out_BC3(((8*n_BC3)-1) downto (8*(n_BC3-1)));
            end loop;
                
            --TAMBAHAN
            --AES output
            for n_AES in 1 to 16 loop
                shd_mem(88 - n_AES) <= aes_data_out(n_AES*8-1 downto (n_AES-1)*8);
                shd_mem(652 - n_AES) <= aes_dec_data_out(n_AES*8-1 downto (n_AES-1)*8);
            end loop;
            
            -- adder output
            for n_ADD in 1 to 32 loop
                shd_mem(280 - n_ADD) <= r_add_sum(n_ADD*8-1 downto (n_ADD-1)*8);
            end loop;
            
            -- multiplier output
            for n_MULT in 1 to 64 loop
                shd_mem(408 - n_MULT) <= r_mul_p(n_MULT*8-1 downto (n_MULT-1)*8);
            end loop;
            
            -- divisor output
            -- quotient
            div_q_out:for n_DIV in 1 to 32 loop
                -- quotient
                shd_mem(504 - n_DIV) <= r_div_p(n_DIV*8-1 downto (n_DIV-1)*8);
                -- remainder
                shd_mem(536 - n_DIV) <= r_div_r(n_DIV*8-1 downto (n_DIV-1)*8);
            end loop;
                
            -- XOR output
            XOR_out: for n_DIV in 1 to 32 loop
                shd_mem(632 - n_DIV) <= s_XOR_out(n_DIV*8-1 downto (n_DIV-1)*8);
            end loop;
            -- TAMBAHAN END
                
                if HASH_REQUEST = '1' then
                    for n_HASH in 1 to 32 loop
                        shd_mem(184-n_HASH) <= hash(((8*n_HASH)-1) downto (8*(n_HASH-1)));
                    end loop;
                end if; 
   	case SHD_MEM_STATE is
		when SHD_MEM_IDLE =>
			DataOut <= x"FF";
			s_SHDMEMRunning <= '0';
			s_SHDMEMDONE <= '0';
			s_TransferReady <= '0';
			s_IncTailSHDMEM <='0';
            s_DataMEM <= s_DataBuffer;
            s_dest_addr <= s_AdDestBuffer;
            s_src_addr  <= s_AdSrcBuffer;
            s_th_addr   <= s_AdThBuffer;             
            
		when SHD_MEM_CPY_INIT=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='1';
			
		when SHD_MEM_CPY_PROCESSING=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='0';
			shd_mem( CONV_INTEGER(s_dest_addr)) <= shd_mem( CONV_INTEGER(s_src_addr));
			
		when SHD_MEM_READ_INIT =>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='1';
			
		when SHD_MEM_READ_PROCESSING=>
			s_TransferReady <= '1';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='0';
			DataOut <= shd_mem( CONV_INTEGER(s_src_addr));
			
		when SHD_MEM_WRITE_INIT =>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='1';
			
		when SHD_MEM_WRITE_PROCESSING=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='0';
			shd_mem( CONV_INTEGER(s_dest_addr)) <= s_DataMEM;
			
		when SHD_MEM_CPY_BLOCK_INIT=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='1';

			
		when SHD_MEM_CPY_BLOCK_PROCESSING=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='0';
			shd_mem( CONV_INTEGER(s_dest_addr)) <= shd_mem( CONV_INTEGER(s_src_addr));
			s_dest_addr <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(s_dest_addr)+1),16);
			s_src_addr <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(s_src_addr)+1),16);
			
		when SHD_MEM_DONE=>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_IncTailSHDMEM <='0';
			s_SHDMEMDONE <= '1';
						
		when others =>
			DataOut <= x"FF";
			s_TransferReady <= '0';
			s_SHDMEMRunning <= '1';
			s_SHDMEMDONE <= '0';
			s_IncTailSHDMEM <='0';
	   end case;
    end if;
   end process;  
   
end circuit;