----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : FSM_keyschedule_2
-- Fungsi      : mengendalikan proses keyscheduling kedua BC3
-- dibuat oleh : Hidayat
-- tgl. revisi : 17 sept 2008
----------------------------------------------------
-- FSM_keyschedule_2 berfungsi untuk melakukan proses pembuatan subkey
-- yaitu subkey KE - KG, K1 - K11, KW1 - KW4, KF1, KF2. 
-- adapun proses yang dilakukan pada tiap State:
-- 1. State ST_SCHE2_1  :
--    state untuk menghasilkan nilai subkey KF dan KG
-- 2. State ST_SCHE2_2  :
--    state untuk menghasilkan nilai subkey KE
-- 3. State ST_SCHE2_3  :
--    state untuk menghasilkan nilai subkey KW1 dan KW2
-- 4. State ST_SCHE2_4  :
--    state untuk menghasilkan nilai subkey K1 dan K2
-- 5. State ST_SCHE2_5  :
--    state untuk menghasilkan nilai subkey K3
-- 6. State ST_SCHE2_6  :
--    state untuk menghasilkan nilai subkey K4 dan K5
-- 7. State ST_SCHE2_7  :
--    state untuk menghasilkan nilai subkey KF1 dan K6
-- 8. State ST_SCHE2_8  :
--    state untuk menghasilkan nilai subkey KF2 dan K7
-- 9. State ST_SCHE2_9  :
--    state untuk menghasilkan nilai subkey K8 dan K11
--10. State ST_SCHE2_10  :
--    state untuk menghasilkan nilai subkey K9 dan K10
--11. State ST_SCHE2_11  :
--    state untuk menghasilkan nilai subkey KW3 dan KW4
--12. State ST_SCHE2_12  :
--    state untuk memberikan tanda bahwa proses keyscheduling selesai


library ieee;
use ieee.std_logic_1164.all;
-- port-port yang dibutuhkan
--		reset                : untuk proses reset '0'  
--    clk                  : 
--		sche_2_enable        : untuk mengaktifkan proses scheduling II
--		sche_2_ok            : untuk menandakan proses scheduling II selesai	
--		seq_B_key_selector   : untuk memilih subkey yang aktif pada bagian B
--                         : "00000000001" mengambil data subkey KC, KD dan KA
--                         : "00000000010" mengambil data subkey KA, KB dan KC
--                         : "00000000100" mengambil data subkey KF, KG dan KE
--                         : "00000001000" mengambil data subkey KE, KF dan KW1
--                         : "00000010000" mengambil data subkey KW1, KW2 dan K2
--                         : "00000100000" mengambil data subkey K1, KW2 dan K3
--                         : "00001000000" mengambil data subkey K1, K2 dan K5
--                         : "00010000000" mengambil data subkey K6, KW2 dan KF1
--                         : "00100000000" mengambil data subkey C3, K3 dan K7
--                         : "01000000000" mengambil data subkey dan K3
--                         : "10000000000" mengambil data subkey K9, K4 dan K6
--		AND_OR_out_selector  : untuk memilih output yang akan diproses
--                         : "001" memilih output AND
--                         : "010" memilih output OR
--                         : "100" memilih output ROTR
--		seq_A_key_selector   : untuk memilih subkey yang aktif pada bagian A
--                         : "000000001" mengambil data subkey KA, KB dan KD
--                         : "000000010" mengambil data subkey KE, KF dan KG
--                         : "000000100" mengambil data subkey KE, KW2 dan KF
--                         : "000001000" mengambil data subkey C1, KW2 dan K3
--                         : "000010000" mengambil data subkey C2, KE dan K4
--                         : "000100000" mengambil data subkey K1, K5 dan K6
--                         : "001000000" mengambil data subkey K3, K5 dan K6
--                         : "010000000" mengambil data subkey K8, K4 dan K5
--                         : "100000000" mengambil data subkey K2, K8 dan K9
--    KE_enable, KF_enable, KG_enable, 
--    K1_enable, K2_enable, K3_enable ,K4_enable, K5_enable, K6_enable, 
--    K7_enable, K8_enable, K9_enable ,K10_enable, K11_enable,
--    KW1_enable, KW2_enable, KW3_enable ,KW4_enable, 
--    KF1_enable, KF2_enable   
--                         : '1' untuk mengaktifkan masing-masing register subkey

entity FSM_keyschedule_2 is port(
		reset, clk : in std_logic;
		sche_2_enable : in std_logic;
		sche_2_ok : out std_logic;
		
		seq_B_key_selector : out std_logic_vector(11 downto 1);
		AND_OR_out_selector : out std_logic_vector(3 downto 1);
		seq_A_key_selector : out std_logic_vector(9 downto 1);
		
      KE_enable, KF_enable, KG_enable, 
      K1_enable, K2_enable, K3_enable ,K4_enable, K5_enable, K6_enable, 
      K7_enable, K8_enable, K9_enable ,K10_enable, K11_enable,
      KW1_enable, KW2_enable, KW3_enable ,KW4_enable, 
      KF1_enable, KF2_enable  :  out std_logic);

end entity;

architecture dataflow of FSM_keyschedule_2 is
	type ST_SCHE_FSM is (ST_SCHE2_1, ST_SCHE2_2, 
	                     ST_SCHE2_3, ST_SCHE2_4, ST_SCHE2_5,
	                     ST_SCHE2_6, ST_SCHE2_7, ST_SCHE2_8,
	                     ST_SCHE2_9, ST_SCHE2_10, ST_SCHE2_11, ST_SCHE2_12);
	signal current_st, next_st    : ST_SCHE_FSM;

begin
   FSM_SCHE : 
	process (clk, sche_2_enable)
	begin 

	   if (clk'event and clk ='1') then

	    case (current_st) is

	    when ST_SCHE2_1 => 
            KE_enable  <= '0'; 
            K1_enable  <= '0';
            K2_enable  <= '0';
            K3_enable  <= '0';
            K4_enable  <= '0';
            K5_enable  <= '0';
            K6_enable  <= '0';
            K7_enable  <= '0';
            K8_enable  <= '0';
            K9_enable  <= '0';
            K10_enable <= '0';
            K11_enable <= '0';
            KW1_enable <= '0';
            KW2_enable <= '0';
            KW3_enable <= '0';
            KW4_enable <= '0';
            KF1_enable <= '0';
            KF2_enable <= '0';
            sche_2_ok <= '0';

		      if (sche_2_enable = '1') then
		         next_st <= ST_SCHE2_2;
--    state untuk menghasilkan nilai subkey KF dan KG
		         seq_A_key_selector <= "000000001"; 
		         seq_B_key_selector <= "00000000001"; 
		         AND_OR_out_selector <= "001"; 
               KF_enable  <= '1'; 
               KG_enable  <= '1';
		
		         else
		         next_st <= ST_SCHE2_1;
		         seq_A_key_selector <= "000000000"; 
		         seq_B_key_selector <= "00000000000"; 
		         AND_OR_out_selector <= "000"; 
               KF_enable  <= '0'; 
               KG_enable  <= '0'; 
		      end if;

--    state untuk menghasilkan nilai subkey KE
	    when ST_SCHE2_2 => --ok
		      seq_A_key_selector <= "000000000"; 
		      seq_B_key_selector <= "00000000010"; 
		      AND_OR_out_selector <= "010"; 
            KE_enable  <= '1'; 
            KF_enable  <= '0'; 
            KG_enable  <= '0';
            next_st <= ST_SCHE2_3;

--    state untuk menghasilkan nilai subkey KW1 dan KW2
	    when ST_SCHE2_3 => --ok
		      seq_A_key_selector <= "000000010"; 
		      seq_B_key_selector <= "00000000100"; 
--		      AND_OR_out_selector <= "010"; 
	         KE_enable  <= '0';  
            KW1_enable <= '1';
            KW2_enable <= '1';
 		      next_st <= ST_SCHE2_4;

--    state untuk menghasilkan nilai subkey K1 dan K2
	    when ST_SCHE2_4 => --ok
		      seq_A_key_selector <= "000000100"; 
		      seq_B_key_selector <= "00000001000"; 
		      AND_OR_out_selector <= "001"; 
            KW1_enable <= '0';
            KW2_enable <= '0';
            K1_enable  <= '1';
            K2_enable  <= '1';   
		      next_st <= ST_SCHE2_5;

--    state untuk menghasilkan nilai subkey K3
	    when ST_SCHE2_5 => 
		      seq_A_key_selector <= "000000000"; 
		      seq_B_key_selector <= "00000010000"; 
		      AND_OR_out_selector <= "010"; 
            K1_enable <= '0';
            K2_enable <= '0';
            K3_enable <= '1';
  		      next_st <= ST_SCHE2_6;

--    state untuk menghasilkan nilai subkey K4 dan K5
	    when ST_SCHE2_6 => 
		      seq_A_key_selector <= "000001000"; 
		      seq_B_key_selector <= "00000100000"; 
		      AND_OR_out_selector <= "010"; 
            K3_enable <= '0';
            K4_enable <= '1';
            K5_enable <= '1';
  		      next_st <= ST_SCHE2_7;
  		
 --    state untuk menghasilkan nilai subkey KF1 dan K6
 	    when ST_SCHE2_7 => 
		      seq_B_key_selector <= "00001000000"; 
		      AND_OR_out_selector <= "010"; 
		      seq_A_key_selector <= "000010000"; 
            K4_enable <= '0';
            K5_enable <= '0';
            KF1_enable <= '1';
            K6_enable <= '1';
  		      next_st <= ST_SCHE2_8;
  		
  --    state untuk menghasilkan nilai subkey KF2 dan K7
 	   when ST_SCHE2_8 => 
		      seq_B_key_selector <= "00010000000"; 
		      AND_OR_out_selector <= "001"; 
		      seq_A_key_selector <= "000100000"; 
            KF1_enable <= '0';
            K6_enable <= '0';
            KF2_enable <= '1';
            K7_enable <= '1';
  		      next_st <= ST_SCHE2_9;
  		 			
--    state untuk menghasilkan nilai subkey K11 dan K8
 	   when ST_SCHE2_9 => 
		      seq_B_key_selector <= "00100000000"; 
		      AND_OR_out_selector <= "001"; 
		      seq_A_key_selector <= "001000000";
            KF2_enable <= '0';
            K7_enable <= '0';
            K11_enable <= '1';
            K8_enable <= '1';
  		      next_st <= ST_SCHE2_10;
  
--    state untuk menghasilkan nilai subkey K1 dan K10
	   when ST_SCHE2_10 => 
		      seq_B_key_selector <= "01000000000"; 
		      AND_OR_out_selector <= "100"; 
		      seq_A_key_selector <= "010000000"; 
            K11_enable <= '0';
            K8_enable <= '0';
            K9_enable <= '1';
            K10_enable <= '1';
  		      next_st <= ST_SCHE2_11;
  
--    state untuk menghasilkan nilai subkey KW3 dan KW4
       when ST_SCHE2_11 => 
		      seq_B_key_selector <= "10000000000"; 
		      AND_OR_out_selector <= "001"; 
		      seq_A_key_selector <= "100000000"; 
            K9_enable <= '0';
            K10_enable <= '0';
            KW3_enable <= '1';
            KW4_enable <= '1';
  		      next_st <= ST_SCHE2_12;

--    state untuk mengaktifkan tanda keyscheduling selesai
       when ST_SCHE2_12 => 
		      seq_B_key_selector <= "00000000000"; 
		      AND_OR_out_selector <= "000"; 
		      seq_A_key_selector <= "000000000"; 
            KW3_enable <= '0';
            KW4_enable <= '0';
            sche_2_ok <= '1';
  		      next_st <= ST_SCHE2_1;
   		 			
	   end case;
   end if;

   end process FSM_SCHE;

-- proses untuk membaca reset 
   FSMinit: process(clk, reset)
   begin
      if reset = '0' then
		   current_st <= ST_SCHE2_1;
	      else
	      if (clk'event and clk ='0') then
			   current_st <= next_st;
		   end if;
	   end if;
   end process FSMinit;

end dataflow;

