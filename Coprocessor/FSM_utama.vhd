----------------------------------------------------
-- Disain      : Kriptografi BC3
-- Entity      : FSM_utama
-- Fungsi      : 
-- mengendalikan proses keyshedule, enkripsi dan dekripsi BC3
-- 1. proses awal akan dilakukan keyschedule 1 dan keyschedule 2 
--    untuk menghasilkan subkey
-- 2. selanjutnya akan dilakukan proses sesuai input enc_dec
--    jika data enc_dec '0' proses enkripsi yang dikerjakan
--    jika data enc_dec '1' proses dekripsi yang dikerjakan
-- 3. selanjutnya proses pengiriman data hasil enkripsi/dekripsi  
    
-- dibuat oleh : Hidayat
----------------------------------------------------
-- State-state yang digunakan :
-- 1. ST_WAIT           : 
--    state untuk menunggu sinyal dari luar (INPUT_READY, KEY_READY, ENC_DEC)
--    jika INPUT_READY = '1' dan KEY_READY = '1', state (membaca keymaster 1)
--    dan akan pindah ke state ST_SCHE1
--    jika INPUT_READY = '1' dan KEY_READY = '0' dan ENC_DEC = '0', 
--    state akan pindah ke state ST_WAIT_ENC_OK
--    jika INPUT_READY = '1' dan KEY_READY = '0' dan ENC_DEC = '1', 
--    state akan pindah ke state ST_WAIT_DEC_OK
-- 2. ST_SCHE1          : 
--    state proses keyschedule 1 (membaca keymaster 2)
-- 3. ST_WAIT_SCHE_1_OK :
--    state untuk menunggu proses keyscheduling I selesai
-- 4. ST_SCHE2          : 
--    state untuk melakukan proses keyscheduling II 
--	5. ST_WAIT_SCHE_2_OK : 
--    state untuk menunggu proses keyscheduling II selesai
--	6. ST_WAIT_ENC_OK    :
--    state untuk menunggu proses Enkripsi selesai
-- 7. ST_WAIT_DEC_OK    : 
--    state untuk menunggu proses Enkripsi selesai
--	8. ST_SEND           : 
--    state untuk proses pengiriman data hasil enkripsi/ dekripsi


library ieee;
use ieee.std_logic_1164.all;
-- port-port yang digunakan :
--		reset          : 
--		clk            :   
--		key_ready      : '1' untuk sinyal bahwa data input adalah data kunci
--		input_ready    : '1' untuk sinyal data input siap dibaca
--		enc_dec        : untuk sinyal enkripsi '0' atau sinyal dekripsi '1' 
--		data_ack       : '1' sinyal data output sudah diterima
--		sche_1_ok      : '1' sinyal keyschedule 1 selesai
--		sche_2_ok      : '1' sinyal keyschedule 2 selesai
--		enc_ok,        : '1' sinyal enkripsi selesai
--		dec_ok         : '1' sinyal dekripsi selesai
--		sche_1_enable  : '1' sinyal untuk menjalankan proses keysechedule 1
--		sche_2_enable  : '1' sinyal untuk menjalankan proses keysechedule 2
--		enc_enable     : '1' sinyal untuk menjalankan proses enkripsi
--		dec_enable     : '1' sinyal untuk menjalankan proses dekripsi
--		output_ready   : '1' sinyal data output siap dikirim

entity FSM_utama is port(
		reset, 
		clk,   
		key_ready,                    
		input_ready,                  
		enc_dec,                       
		data_ack     : in std_logic;	 
		sche_1_ok,                    
		sche_2_ok,                    
		enc_ok,                      
		dec_ok       : in std_logic;  
		sche_1_enable,                
		sche_2_enable,                
		enc_enable,                   
		dec_enable,                   
		output_ready : out std_logic);
				
end entity;

architecture dataflow of FSM_utama is
	type ST_MAIN_FSM is (ST_WAIT,         
	                     ST_SCHE1,        
	                     ST_WAIT_SCHE_1_OK,
	                     ST_SCHE2,         
	                     ST_WAIT_SCHE_2_OK,
	                     ST_WAIT_ENC_OK,
	                     ST_WAIT_DEC_OK,
	                     ST_SEND);        
	
	signal current_st, next_st    : ST_MAIN_FSM;

begin
   FSM_UTAMA : 
	process (clk)
	begin 

	   if (clk'event and clk ='0') then 
	      case (current_st) is

	      when ST_WAIT => 
	          output_ready  <= '0';
      -- jika key_ready dan input_ready bernilai '1'
      -- maka proses selanjutnya adalah keyschedule '1'
      -- jika tidak akan kembali membaca kedua input tersebut
      
 		      if (input_ready = '0') then
               next_st       <= ST_WAIT; 
               sche_1_enable <= '0';
               sche_2_enable <= '0';
               enc_enable    <= '0'; 
               dec_enable    <= '0';
            -- kembali ke state awal (ST_WAIT)
 
 		         else            		          
		         if (key_ready = '1') then      -- untuk memulai proses keyscheduling & membaca keymaster 1
		            next_st       <= ST_SCHE1;
		            sche_1_enable <= '1';
                  sche_2_enable <= '0';
                  enc_enable    <= '0'; 
                  dec_enable    <= '0';
                  
		            else
                  if (enc_dec = '0') then     -- untuk memulai proses enkripsi
		               next_st       <= ST_WAIT_ENC_OK;
	                  sche_1_enable <= '0';
	                  sche_2_enable <= '0';
   		               enc_enable    <= '1';
                     dec_enable    <= '0';
                     
		               else
		               if (enc_dec = '1') then  -- untuk memulai proses dekripsi
                        next_st       <= ST_WAIT_DEC_OK;
		                  sche_1_enable <= '0';
		                  sche_2_enable <= '0';
   	                    enc_enable    <= '0'; 
	                     dec_enable    <= '1';		                  		                  
                     end if;
                  end if;
                end if;
             end if;

	      when ST_SCHE1 =>
	      -- jika key_ready = '1' dan input_ready = '1' berarti proses keymaster 2 siap dibaca 
		      if (key_ready = '1') and (input_ready = '1') then
		         next_st <= ST_WAIT_SCHE_1_OK;
		         sche_1_enable <= '1';
		         else
		         next_st <= ST_SCHE1;
		         sche_1_enable <= '0';
		      end if;
  
         when ST_WAIT_SCHE_1_OK =>  
         -- jika sche_1_ok bernilai '1' berarti proses keyschedule 1 telah selesai
		      if (sche_1_ok = '1') then
		         next_st <= ST_SCHE2;
		         else
		         next_st <= ST_WAIT_SCHE_1_OK;
		         sche_1_enable <= '0';
		      end if;
		
	      when ST_SCHE2 => 
		      sche_2_enable <= '1';
            next_st <= ST_WAIT_SCHE_2_OK;

         when ST_WAIT_SCHE_2_OK =>  
		      sche_2_enable <= '0';
         -- jika sche_2_ok bernilai '1' berarti proses keyschedule 2 telah selesai
		      if (sche_2_ok = '1') then
		         next_st <= ST_WAIT;
		         else
		         next_st <= ST_WAIT_SCHE_2_OK;
            end if;
	
      
         when ST_WAIT_ENC_OK =>  
            enc_enable <= '0';
         -- jika enc_ok bernilai '1' berarti proses enkripsi telah selesai
	         if enc_ok = '1' then
	            next_st <= ST_SEND;
--		output_ready <= '1';
		         else
		         next_st <= ST_WAIT_ENC_OK;
		      end if;
		   
		   when ST_WAIT_DEC_OK =>  
            dec_enable <= '0';
      -- jika dec_ok bernilai '1' berarti proses dekripsi telah selesai
	         if dec_ok = '1' then
	            next_st <= ST_SEND;
--	   output_ready <= '1';
		         else
		         next_st <= ST_WAIT_DEC_OK;
		      end if;
			
	      when ST_SEND => 
            output_ready <= '1';

      -- jika data_ack bernilai '1' berarti proses pengiriman data telah selesai      
	         if data_ack = '1' then
	            next_st <= ST_WAIT;
		         else
		         next_st <= ST_SEND;
		      end if;

	      end case;
   end if;
end process FSM_UTAMA;

FSMinit: process(clk, reset)
begin
   if reset = '0' then
		current_st <= ST_WAIT;
	else
	   if (clk'event and clk ='1') then
			current_st <= next_st;
		end if;
	end if;
end process FSMinit;

end dataflow;