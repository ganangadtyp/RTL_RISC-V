----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : FSM_dekripsi
-- Fungsi      : mengendalikan proses Dekripsi BC3
-- dibuat oleh : Hidayat
-- direvisi    : 25 September 2008
----------------------------------------------------
-- FSM_dekripsi berfungsi untuk mengendalikan proses dekripsi
-- terdapat 11 ronde untuk proses dekripsi dengan urutan subkey dari K11 - K1
-- berikut state-state pada FSM_enkripsi:
--  ST_DEC1 :
--    menunggu sinyal DEC_dec = '0' dan input_ready = '1'
--    menjalankan ronde 1 jika sinyal DEC_dec = '0' dan input_ready = '1'
--  ST_DEC2 :
--    menjalankan ronde 2
--  ST_DEC3 :
--    menjalankan ronde 3
--  ST_DEC4 :
--    menjalankan ronde 4
--  ST_DEC5 :
--    menjalankan ronde 5
--  ST_DEC6 :
--    menjalankan ronde 6
--  ST_DEC7 :
--    menjalankan ronde 7
--  ST_DEC8 :
--    menjalankan ronde 8
--  ST_DEC9 :
--    menjalankan ronde 9
--  ST_DEC10 :
--    menjalankan ronde 10
--  ST_DEC11 :
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


entity FSM_dekripsi is port(
		reset, 
		clk, 
		dec_enable        : in std_logic;
		dec_ok            : out std_logic;
		data_selector     : out std_logic_vector(4 downto 1); 
		KW_first_selector : out std_logic;
		KW_last_selector  : out std_logic_vector(4 downto 1);
		XOR_pre_fround    : out std_logic;
		XOR_last_fround   : out std_logic;
		subkey_selector   : out std_logic_vector(11 downto 1);
		key_selector      : out std_logic;
		function_selector : out std_logic;	
		out_enable        : out std_logic); --utk KA KB/ KC KD/ out crypto
		
end entity;

architecture dataflow of FSM_dekripsi is
	type ST_DEC_FSM is (--ST_DEC0, 
	                    ST_DEC1, ST_DEC2, ST_DEC3, 
	                    ST_DEC4, ST_DEC5, ST_DEC6, ST_DEC7, 
	                    ST_DEC8, ST_DEC9, ST_DEC10, ST_DEC11);
	
	signal current_st, next_st    : ST_DEC_FSM;

begin
   FSM_DEC : 
	process (clk, dec_enable)
	begin 

      if (clk'event and clk ='1') then

   	     case (current_st) is

	      when ST_DEC1 => 
		      dec_ok <= '0';
   		      if (dec_enable = '1') then
		         next_st <= ST_DEC2;
		         data_selector <= "0001";           -- mengambil data input sebagai output
		         KW_first_selector <= '0';          -- mengambil data KW3 dan KW4
		         XOR_pre_fround <= '1';
		         subkey_selector <="10000000000";   -- mengambil K11 sebagai kunci
		         key_selector <= '1'; -- pilih subkey
		         out_enable <= '1';

		         else
		         next_st <= ST_DEC1;
		         data_selector <= "0000";
		         KW_first_selector <= '0';
		         KW_last_selector <="0000";
		         XOR_pre_fround <= '0';
		         XOR_last_fround <= '0';
		         subkey_selector <="00000000000";
		         key_selector <= '0';
		         function_selector <= '0';	
		         out_enable <= '0';
		      end if;
	
	      when ST_DEC2 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      KW_first_selector <= '0';          -- mengambil data KW3 dan KW4
		      XOR_pre_fround <= '0';             -- 
		      subkey_selector <="01000000000";   -- mengambil K10 sebagai kunci
  		      next_st <= ST_DEC3;
		
	      when ST_DEC3 => 
		      subkey_selector <="00100000000";   -- mengambil K9 sebagai kunci
  		      next_st <= ST_DEC4;

	      when ST_DEC4 => 
		      subkey_selector <="00010000000";   -- mengambil K8 sebagai kunci
		      function_selector <= '1';          -- mengambil output FA sebagai output
  		      next_st <= ST_DEC5;

	      when ST_DEC5 => 
		      data_selector <= "0100";           -- mengambil output FA sebagai output
		      subkey_selector <="00001000000";   -- mengambil K7 sebagai kunci
  		      next_st <= ST_DEC6;

	      when ST_DEC6 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      subkey_selector <="00000100000";   -- mengambil K6 sebagai kunci
 		      next_st <= ST_DEC7;

	      when ST_DEC7 => 
	         subkey_selector <="00000010000";   -- mengambil K5 sebagai kunci
		      function_selector <= '0';          -- mengambil output FA inverse sebagai output
  		      next_st <= ST_DEC8;

	      when ST_DEC8 => 
		      data_selector <= "0100";           -- mengambil output FA inverse sebagai output
		      subkey_selector <="00000001000";   -- mengambil K4 sebagai kunci
  		      next_st <= ST_DEC9;

	      when ST_DEC9 => 
		      data_selector <= "1000";           -- mengambil output ronde sebagai output
		      subkey_selector <="00000000100";   -- mengambil K3 sebagai kunci
  		      next_st <= ST_DEC10;

	      when ST_DEC10 => 
	   	     subkey_selector <="00000000010";   -- mengambil K2 sebagai kunci
  		      next_st <= ST_DEC11;

	      when ST_DEC11 => -- OK 
		      KW_last_selector <="0100";         -- mengambil data KW1 dan KW2
		      XOR_last_fround <= '1';
		      subkey_selector <="00000000001";   -- mengambil K1 sebagai kunci
  		      dec_ok <= '1'; -- ?????? masih belum jelas
  		      next_st <= ST_DEC1;

	      end case;
      end if;
end process FSM_DEC;

FSMinit: process(clk, reset)
begin
   if reset = '0' then
		current_st <= ST_DEC1;
	else
	   if (clk'event and clk ='0') then
			current_st <= next_st;
		end if;
	end if;
end process FSMinit;

end dataflow;
