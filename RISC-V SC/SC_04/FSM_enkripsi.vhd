----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : FSM_enkripsi
-- Fungsi      : mengendalikan proses enkripsi BC3
-- dibuat oleh : Hidayat
-- revisi      : 17 September 2008
----------------------------------------------------
-- FSM_enkripsi berfungsi untuk mengendalikan proses enkripsi
-- terdapat 11 ronde untuk proses enkripsi dengan urutan subkey dari K1 - K11
-- berikut state-state pada FSM_enkripsi:
--  ST_ENC1 :
--    menunggu sinyal enc_dec = '0' dan input_ready = '1'
--    menjalankan ronde 1 jika sinyal enc_dec = '0' dan input_ready = '1'
--  ST_ENC2 :
--    menjalankan ronde 2
--  ST_ENC3 :
--    menjalankan ronde 3
--  ST_ENC4 :
--    menjalankan ronde 4
--  ST_ENC5 :
--    menjalankan ronde 5
--  ST_ENC6 :
--    menjalankan ronde 6
--  ST_ENC7 :
--    menjalankan ronde 7
--  ST_ENC8 :
--    menjalankan ronde 8
--  ST_ENC9 :
--    menjalankan ronde 9
--  ST_ENC10 :
--    menjalankan ronde 10
--  ST_ENC11 :
--    menjalankan ronde 11

library ieee;
use ieee.std_logic_1164.all;

-- port-port yang digunakan
--		reset            : untuk proses reset '0'
--		clk              : 
--    enc_enable       : in std_logic;
--		enc_ok           : out std_logic;
--		data_selector    : untuk memilih data input yang akan diproses (4 bit)
--		KW_first_selector: untuk memilih subkey yang akan diproses 
--                       '1' untuk KW1 dan KW3
--                       '0' untuk KW2 dan KW4        
--		KW_last_selector : untuk memilih subkey yang akan diproses (4 bit)
--                       "0001" untuk KW1 dan KW3
--                       "0010" untuk KW2 dan KW4        
--                       "0100" untuk ..
--                       "1000" untuk ..        
--		XOR_pre_fround   : '1' untuk meng XOR kan data dengan subkey KW
--		XOR_last_fround  : '1' untuk meng XOR kan data dengan subkey KW
--		subkey_selector  : untuk memilih subkey yang aktif (11 bit)
--                       "00000000001" untuk K1
--                       "00000000010" untuk K2        
--                       "00000000100" untuk K3
--                       "00000001000" untuk K4        
--                       "00000010000" untuk K5
--                       "00000100000" untuk K6  
--                       "00001000000" untuk K7  
--                       "00010000000" untuk K8  
--                       "00100000000" untuk K9  
--                       "01000000000" untuk K10  
--                       "10000000000" untuk K11 
      
--		key_selector     : untuk memilih subkey yang akan diproses
--                       '1' untuk Subkey K1 s.d. K11
--                       '0' untuk konstanta C1 .. C6        
--		function_selector: untuk memilih nilai fungsi yang aktif	
--                       '1' untuk FA
--                       '0' untuk FA inverse        
--		out_enable       : '1' untuk mengaktifkan reg. output crypto 



entity FSM_enkripsi is port(
		reset, 
		clk, 
		enc_enable         : in std_logic;
		enc_ok             : out std_logic;
		data_selector      : out std_logic_vector(4 downto 1); 
		KW_first_selector  : out std_logic;
		KW_last_selector   : out std_logic_vector(4 downto 1);
		XOR_pre_fround     : out std_logic;
		XOR_last_fround    : out std_logic;
		subkey_selector    : out std_logic_vector(11 downto 1);
		key_selector       : out std_logic;
		function_selector  : out std_logic;	
		out_enable         : out std_logic); 
		
end entity;

architecture dataflow of FSM_enkripsi is
	type ST_ENC_FSM is (ST_ENC1, ST_ENC2, ST_ENC3, 
	                    ST_ENC4, ST_ENC5, ST_ENC6, ST_ENC7, 
	                    ST_ENC8, ST_ENC9, ST_ENC10, ST_ENC11);
	
	signal current_st, next_st    : ST_ENC_FSM;


begin
   FSM_ENC : 
	process (clk, enc_enable)
	begin 

	   if (clk'event and clk ='1') then          -- cek saat raising edge clock
	      case (current_st) is

	      when ST_ENC1 => 
		      enc_ok <= '0';
		      XOR_last_fround <= '0';
	         KW_last_selector <="0000";				
		      if (enc_enable = '1') then
		         next_st <= ST_ENC2;
		         data_selector <= "0001";         -- mengambil data input sebagai output 
		         KW_first_selector <= '1';        -- mengambil data KW1 dan KW2
		         XOR_pre_fround <= '1';
		         subkey_selector <="00000000001"; -- mengambil K1 sebagai kunci 
		         key_selector <= '1';             -- pilih subkey
		         out_enable <= '1';
		         else
		         next_st <= ST_ENC1;
		         data_selector <= "0000";         
		         KW_first_selector <= '0';	
		         XOR_pre_fround <= '0';
		         subkey_selector <="00000000000"; 
		         key_selector <= '0';
		         function_selector <= '0';
		         out_enable <= '0';  
		      end if;
	
	      when ST_ENC2 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      KW_first_selector <= '0';
		      XOR_pre_fround <= '0';             -- 
		      subkey_selector <="00000000010";   -- mengambil K2 sebagai kunci
  		      next_st <= ST_ENC3;
		
	      when ST_ENC3 => 
		      subkey_selector <="00000000100";   -- mengambil K3 sebagai kunci
  		      next_st <= ST_ENC4;

	      when ST_ENC4 => 
		      subkey_selector <="00000001000";   -- mengambil K4 sebagai kunci
		      function_selector <= '1';          -- mengambil output FA 
  		      next_st <= ST_ENC5;

	      when ST_ENC5 => 
		      data_selector <= "0100";           -- mengambil output FA sebagai output
		      subkey_selector <="00000010000";   -- mengambil K5 sebagai kunci
  		      next_st <= ST_ENC6;

	      when ST_ENC6 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      subkey_selector <="00000100000";   -- mengambil K6 sebagai kunci
 		      next_st <= ST_ENC7;

	      when ST_ENC7 => 
		      subkey_selector <="00001000000";   -- mengambil K7 sebagai kunci
		      function_selector <= '0';          -- mengambil output FA inverse
  		      next_st <= ST_ENC8;

	      when ST_ENC8 => 
		      data_selector <= "0100";           -- mengambil output FAinverse sebagai output
		      subkey_selector <="00010000000";   -- mengambil K8 sebagai kunci
  		      next_st <= ST_ENC9;

	      when ST_ENC9 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      subkey_selector <="00100000000";   -- mengambil K9 sebagai kunci
  		      next_st <= ST_ENC10;

	      when ST_ENC10 => 
		      subkey_selector <="01000000000";   -- mengambil K10 sebagai kunci
  		      next_st <= ST_ENC11;

	      when ST_ENC11 => -- OK 
		      KW_last_selector <="1000";         -- mengambil data KW3 dan KW4
		      XOR_last_fround <= '1';
		      subkey_selector <="10000000000";   -- mengambil K11 sebagai kunci
  		      enc_ok <= '1'; -- 
  		      next_st <= ST_ENC1;

	      end case;
      end if;

   end process FSM_ENC;

   FSMinit: process(clk, reset)
   begin
      if reset = '0' then
		   current_st <= ST_ENC1;
	      else
	      if (clk'event and clk ='0') then
			current_st <= next_st;
		   end if;
	   end if;
   end process FSMinit;

end dataflow;

