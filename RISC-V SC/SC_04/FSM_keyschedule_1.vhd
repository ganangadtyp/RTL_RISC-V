----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : FSM_keyschedule_1
-- Fungsi      : mengendalikan proses keyscheduling awal BC3
-- dibuat oleh : Hidayat
-- tgl. revisi : 17 sept 2008
----------------------------------------------------
-- FSM_keyschedule_1 berfungsi untuk melakukan proses pembuatan subkey awal
-- yaitu subkey KA, KB, KC dan KD. 
-- adapun proses yang dilakukan pada tiap State:
-- 1. State ST_SCHE_A : 
--    state awal, pada state ini semua sinyal kendali diinisialisasi
--    dan menunggu sinyal sche_1_enable untuk mengaktifkan pembacaan keymaster 1
--    dan membaca untuk melanjutkan ke state berikutnya
-- 2. State ST_SCHE_B : 
--    state kedua, untuk menunggu sinyal sche_1_enable untuk mengaktifkan pembacaan keymaster 1 
-- 3. State ST_SCHE1  :
--    state untuk mengerjakan ronde 1 keysheduling 
-- 4. State ST_SCHE2  :
--    state untuk mengerjakan ronde 2 keysheduling 
-- 5. State ST_SCHE3  :
--    state untuk mengerjakan ronde 3 keysheduling 
-- 6. State ST_SCHE4  :
--    state untuk mengerjakan ronde 4 keysheduling sekaligus menyimpan data subkey KA dan KB
-- 7. State ST_SCHE5  :
--    state untuk mengerjakan ronde 1 keysheduling 
-- 8. State ST_SCHE6  :
--    state untuk mengerjakan ronde 1 keysheduling sekaligus menyimpan data subkey KC dan KD


library ieee;
use ieee.std_logic_1164.all;
--    port-port yang digunakan
--		reset            : untuk proses reset '0'
--		clk              : 
--		sche_1_enable    : untuk mengaktifkan proses scheduling I
--		sche_1_ok        : untuk menandakan proses scheduling I selesai	
--		data_selector    : untuk memilih data input yang akan diproses (4 bit)
--		keymaster1_en    : untuk mengaktifkan reg. 1
--		keymaster2_en    : untuk mengaktifkan reg. 2
--		KW_first_selector: untuk memilih subkey yang akan diproses 
--                       '1' untuk KW1 dan KW3
--                       '0' untuk KW2 dan KW4        
--		KW_last_selector : untuk memilih subkey yang akan diproses (4 bit)
--                       '0001' untuk KW1 dan KW3
--                       '0010' untuk KW2 dan KW4        
--                       '0100' untuk ..
--                       '1000' untuk ..        
--		XOR_pre_fround   : '1' untuk meng XOR kan data dengan subkey KW
--		XOR_last_fround  : '1' untuk meng XOR kan data dengan subkey KW
--		const_selector   : untuk memilih nilai konstanta (6 bit)
--                       '000001' untuk C1
--                       '000010' untuk C2        
--                       '000100' untuk C3
--                       '001000' untuk C4        
--                       '010000' untuk C5
--                       '100000' untuk C6        
--		key_selector     : untuk memilih subkey yang akan diproses
--                       '1' untuk Subkey K1 s.d. K11
--                       '0' untuk konstanta C1 .. C6        
--		out_enable       : '1' untuk mengaktifkan reg. output crypto 
--   	KAKB_enable      : '1' untuk mengaktifkan reg. KA	dan KB	
--		KCKD_enable      : '1' untuk mengaktifkan reg. KC dan KD	
		
entity FSM_keyschedule_1 is port(
		reset, clk : in std_logic;
		sche_1_enable : in std_logic;
		sche_1_ok : out std_logic;	
		data_selector : out std_logic_vector(4 downto 1);
		keymaster1_en : out std_logic;
		keymaster2_en : out std_logic;
		KW_first_selector : out std_logic;
		KW_last_selector : out std_logic_vector(4 downto 1);
		XOR_pre_fround : out std_logic;
		XOR_last_fround : out std_logic;
		const_selector : out std_logic_vector(6 downto 1);
		key_selector : out std_logic;
		out_enable : out std_logic; --utk KA&KB/ KC&KD/ output crypto
		KAKB_enable : out std_logic;			
		KCKD_enable : out std_logic);			
end entity;

architecture dataflow of FSM_keyschedule_1 is
	type ST_SCHE_FSM is (ST_SCHE_A, ST_SCHE_B, 
	                     ST_SCHE1, ST_SCHE2, ST_SCHE3, 
	                     ST_SCHE4, ST_SCHE5, ST_SCHE6);

	signal current_st, next_st    : ST_SCHE_FSM;

begin
   FSM_SCHE : 
	process (clk, sche_1_enable)
	begin 

	if (clk'event and clk ='1') then

      case (current_st) is
-- pada state ini semua sinyal kendali diinisialisasikan dengan nilai 0
	   when ST_SCHE_A => 
		   sche_1_ok <= '0'; 
		   KW_first_selector <= '0';
		   KW_last_selector <="0000";
		   XOR_pre_fround <= '0';
		   XOR_last_fround <= '0';
		   const_selector <="000000";
		   key_selector <= '0'; 
		   out_enable <= '0'; 
		   KAKB_enable <= '0';			
		   KCKD_enable <= '0';	

-- menunggu sinyal sche_1_enable = '1' dari FSM_utama
-- untuk memulai proses keyscheduling awal	
		   if (sche_1_enable = '1') then
		      next_st <= ST_SCHE_B; 
		      data_selector <= "0001";
		      keymaster1_en <= '1';
		      keymaster2_en <= '0';
		      else
		      next_st <= ST_SCHE_A;
		      data_selector <= "0000";
		      keymaster1_en <= '0';
		      keymaster2_en <= '0';
		   end if;

	   when ST_SCHE_B => 
		   if (sche_1_enable = '1') then
		      next_st <= ST_SCHE1; 
		      data_selector <= "0001";
		      keymaster1_en <= '0';
		      keymaster2_en <= '1';
		      else
		      next_st <= ST_SCHE_B;
		      data_selector <= "0000";
		      keymaster1_en <= '0';
		      keymaster2_en <= '0';
		   end if;
		
	   when ST_SCHE1 => 
		   data_selector <= "0010";
		   keymaster1_en <= '0';
		   keymaster2_en <= '0';
		   XOR_pre_fround <= '0';
		   XOR_last_fround <= '0';
		   const_selector <="000001";
		   key_selector <= '0';
		   out_enable <= '1'; 
  		   next_st <= ST_SCHE2;

	   when ST_SCHE2 => 
		   data_selector <= "1000";
		   KW_last_selector <="0001";
		   XOR_last_fround <= '1';
		   const_selector <="000010";
  		   next_st <= ST_SCHE3;

	   when ST_SCHE3 => 
		   KW_last_selector <="0000";
		   XOR_last_fround <= '0';
		   const_selector <="000100";
  		   next_st <= ST_SCHE4;

-- pada state ini output diambil sebagai nilai subkey KA dan KB
-- yang disimpan pada register KA dan register KB
	   when ST_SCHE4 => 
		   KW_last_selector <="0010";
		   XOR_last_fround <= '1';
		   const_selector <="001000";
		   KAKB_enable <= '1';			
 		   next_st <= ST_SCHE5;

	   when ST_SCHE5 => 
		   XOR_last_fround <= '0';
		   const_selector <="010000";
		   KAKB_enable <= '0';			
		   next_st <= ST_SCHE6;

-- pada state ini output diambil sebagai nilai subkey KC dan KD
-- yang disimpan pada register KC dan register KD
	   when ST_SCHE6 => 
		   const_selector <="100000";
		   KCKD_enable <= '1';	  		
-- memberikan tanda proses keyschedule1 selesai ke FSM_utama
		   sche_1_ok <= '1';       
  		   next_st <= ST_SCHE_A;

	end case;
end if;

end process FSM_SCHE;

-- untuk proses pembacaan sinyal reset
FSMinit: process(clk, reset)
begin
   if reset = '0' then
		current_st <= ST_SCHE_A;
	   else
	   if (clk'event and clk ='0') then
			current_st <= next_st;
		end if;
	end if;
end process FSMinit;

end dataflow;

