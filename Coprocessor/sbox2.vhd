----------------------------------------------------
-- Disain : Kriptografi BC3
-- Entity : sbox
-- Fungsi : kotak subtitusi 8 bit
-- dibuat oleh : Hidayat
----------------------------------------------------

	library ieee;
	use ieee.std_logic_1164.all;

	entity sbox is port (
		sbox_in  : in  std_logic_vector (7 downto 0);
		sbox_out 	: out std_logic_vector (7 downto 0));
	end entity;

	architecture behavior of sbox is
	begin
		process (sbox_in)
		begin 
		case sbox_in is
-- 0xbb,0x8b,0x9e,0xdf,0x42,0xd8,0xf7,0x1f, 0x52,0xd7,0x26,0x80,0x3e,0x20,0x17,0x5b, OK
				when "00000000"  => sbox_out <= X"BB";
				when "00000001"  => sbox_out <= X"8B";
				when "00000010"  => sbox_out <= X"9E";
				when "00000011"  => sbox_out <= X"DF";
				when "00000100"  => sbox_out <= X"42";
				when "00000101"  => sbox_out <= X"D8";
				when "00000110"  => sbox_out <= X"F7";
				when "00000111"  => sbox_out <= X"1F";
	
				when "00001000"  => sbox_out <= X"52";
				when "00001001"  => sbox_out <= X"D7";
				when "00001010"  => sbox_out <= X"26";
				when "00001011"  => sbox_out <= X"80";
				when "00001100"  => sbox_out <= X"3E";
				when "00001101"  => sbox_out <= X"20";
				when "00001110"  => sbox_out <= X"17";
				when "00001111"  => sbox_out <= X"5B";
	
-- 0xf1,0x94,0x5e,0xee,0x78,0x91,0x7a,0x3c, 0x62,0x53,0x24,0xf6,0xc2,0x97,0xe3,0x8d, OK
				when "00010000"  => sbox_out <= X"F1";
				when "00010001"  => sbox_out <= X"94";
				when "00010010"  => sbox_out <= X"5E";
				when "00010011"  => sbox_out <= X"EE";
				when "00010100"  => sbox_out <= X"78";
				when "00010101"  => sbox_out <= X"91";
				when "00010110"  => sbox_out <= X"7A";
				when "00010111"  => sbox_out <= X"3C";

				when "00011000"  => sbox_out <= X"62";
				when "00011001"  => sbox_out <= X"53";
				when "00011010"  => sbox_out <= X"24";
				when "00011011"  => sbox_out <= X"F6";
				when "00011100"  => sbox_out <= X"C2";
				when "00011101"  => sbox_out <= X"97";
				when "00011110"  => sbox_out <= X"E3";
				when "00011111"  => sbox_out <= X"8D";

-- 0xc4,0xfc,0x5f,0xad,0x40,0x2b,0xa4,0x16, 0x4c,0x50,0xbc,0x09,0xca,0x60,0x96,0x05, OK
				when "00100000"  => sbox_out <= X"C4";
				when "00100001"  => sbox_out <= X"FC";
				when "00100010"  => sbox_out <= X"5F";
				when "00100011"  => sbox_out <= X"AD";
				when "00100100"  => sbox_out <= X"40";
				when "00100101"  => sbox_out <= X"2B";
				when "00100110"  => sbox_out <= X"A4";
				when "00100111"  => sbox_out <= X"16";

				when "00101000"  => sbox_out <= X"4C";
				when "00101001"  => sbox_out <= X"50";
				when "00101010"  => sbox_out <= X"BC";
				when "00101011"  => sbox_out <= X"09";
				when "00101100"  => sbox_out <= X"CA";
				when "00101101"  => sbox_out <= X"60";
				when "00101110"  => sbox_out <= X"96";
				when "00101111"  => sbox_out <= X"05";

-- 0x81,0xba,0x4e,0x10,0xc0,0xd5,0x49,0xc3, 0x48,0x3d,0xf0,0xb0,0xde,0x76,0xdb,0xf4, OK
				when "00110000"  => sbox_out <= X"81";
				when "00110001"  => sbox_out <= X"BA";
				when "00110010"  => sbox_out <= X"4E";
				when "00110011"  => sbox_out <= X"10";
				when "00110100"  => sbox_out <= X"C0";
				when "00110101"  => sbox_out <= X"D5";
				when "00110110"  => sbox_out <= X"49";
				when "00110111"  => sbox_out <= X"C3";

				when "00111000"  => sbox_out <= X"48";
				when "00111001"  => sbox_out <= X"3D";
				when "00111010"  => sbox_out <= X"F0";
				when "00111011"  => sbox_out <= X"B0";
				when "00111100"  => sbox_out <= X"DE";
				when "00111101"  => sbox_out <= X"76";
				when "00111110"  => sbox_out <= X"DB";
				when "00111111"  => sbox_out <= X"F4";

-- 0xe6,0xcd,0x56,0xed,0x6c,0xf8,0xb6,0x0c, 0x36,0x82,0x2e,0x7c,0xda,0x4a,0x92,0xdd, OK
				when "01000000"  => sbox_out <= X"E6";
				when "01000001"  => sbox_out <= X"CD";
				when "01000010"  => sbox_out <= X"56";
				when "01000011"  => sbox_out <= X"ED";
				when "01000100"  => sbox_out <= X"6C";
				when "01000101"  => sbox_out <= X"F8";
				when "01000110"  => sbox_out <= X"B6";
				when "01000111"  => sbox_out <= X"0C";
				
				when "01001000"  => sbox_out <= X"36";
				when "01001001"  => sbox_out <= X"82";
				when "01001010"  => sbox_out <= X"2E";
				when "01001011"  => sbox_out <= X"7C";
				when "01001100"  => sbox_out <= X"DA";
				when "01001101"  => sbox_out <= X"4A";
				when "01001110"  => sbox_out <= X"92";
				when "01001111"  => sbox_out <= X"DD";
				
-- 0x7f,0xd4,0x99,0xb8,0x71,0x28,0xe9,0x33, 0xac,0x68,0x66,0x9f,0x1b,0x7d,0x88,0x00, OK
				when "01010000"  => sbox_out <= X"7F";
				when "01010001"  => sbox_out <= X"D4";
				when "01010010"  => sbox_out <= X"99";
				when "01010011"  => sbox_out <= X"B8";
				when "01010100"  => sbox_out <= X"71";
				when "01010101"  => sbox_out <= X"28";
				when "01010110"  => sbox_out <= X"E9";
				when "01010111"  => sbox_out <= X"33";
				
				when "01011000"  => sbox_out <= X"AC";
				when "01011001"  => sbox_out <= X"68";
				when "01011010"  => sbox_out <= X"66";
				when "01011011"  => sbox_out <= X"9F";
				when "01011100"  => sbox_out <= X"1B";
				when "01011101"  => sbox_out <= X"7D";
				when "01011110"  => sbox_out <= X"88";
				when "01011111"  => sbox_out <= X"00";
				
-- 0xa8,0x43,0xc1,0x1c,0x34,0xfd,0x59,0x8f, 0xcf,0xd9,0x0f,0xc5,0xbd,0x46,0x31,0x14, OK
				when "01100000"  => sbox_out <= X"A8";
				when "01100001"  => sbox_out <= X"43";
				when "01100010"  => sbox_out <= X"C1";
				when "01100011"  => sbox_out <= X"1C";
				when "01100100"  => sbox_out <= X"34";
				when "01100101"  => sbox_out <= X"FD";
				when "01100110"  => sbox_out <= X"59";
				when "01100111"  => sbox_out <= X"8F";
				
				when "01101000"  => sbox_out <= X"CF";
				when "01101001"  => sbox_out <= X"D9";
				when "01101010"  => sbox_out <= X"0F";
				when "01101011"  => sbox_out <= X"C5";
				when "01101100"  => sbox_out <= X"BD";
				when "01101101"  => sbox_out <= X"46";
				when "01101110"  => sbox_out <= X"31";
				when "01101111"  => sbox_out <= X"14";
				
-- 0x1e,0xf3,0xc6,0x58,0x3b,0x87,0xe5,0x6e, 0x6f,0xdc,0xa9,0xb4,0x21,0x5d,0x03,0x39, OK
				when "01110000"  => sbox_out <= X"1E";
				when "01110001"  => sbox_out <= X"F3";
				when "01110010"  => sbox_out <= X"C6";
				when "01110011"  => sbox_out <= X"58";
				when "01110100"  => sbox_out <= X"3B";
				when "01110101"  => sbox_out <= X"87";
				when "01110110"  => sbox_out <= X"E5";
				when "01110111"  => sbox_out <= X"6E";
				
				when "01111000"  => sbox_out <= X"6F";
				when "01111001"  => sbox_out <= X"DC";
				when "01111010"  => sbox_out <= X"A9";
				when "01111011"  => sbox_out <= X"B4";
				when "01111100"  => sbox_out <= X"21";
				when "01111101"  => sbox_out <= X"5D";
				when "01111110"  => sbox_out <= X"03";
				when "01111111"  => sbox_out <= X"39";
				
-- 0x9d,0xcc,0x6b,0x23,0x0d,0x65,0x98,0x9a, 0x73,0x77,0x7b,0x69,0x70,0xd0,0x37,0x64, OK
				when "10000000"  => sbox_out <= X"9D";
				when "10000001"  => sbox_out <= X"CC";
				when "10000010"  => sbox_out <= X"6B";
				when "10000011"  => sbox_out <= X"23";
				when "10000100"  => sbox_out <= X"0D";
				when "10000101"  => sbox_out <= X"65";
				when "10000110"  => sbox_out <= X"98";
				when "10000111"  => sbox_out <= X"9A";
				
				when "10001000"  => sbox_out <= X"73";
				when "10001001"  => sbox_out <= X"77";
				when "10001010"  => sbox_out <= X"7B";
				when "10001011"  => sbox_out <= X"69";
				when "10001100"  => sbox_out <= X"70";
				when "10001101"  => sbox_out <= X"D0";
				when "10001110"  => sbox_out <= X"37";
				when "10001111"  => sbox_out <= X"64";
				
-- 0xea,0x57,0xe1,0xeb,0x8a,0xce,0x0e,0xf5, 0x4d,0xe4,0x5c,0x45,0x54,0xab,0x83,0x9c, OK
				when "10010000"  => sbox_out <= X"EA";
				when "10010001"  => sbox_out <= X"57";
				when "10010010"  => sbox_out <= X"E1";
				when "10010011"  => sbox_out <= X"EB";
				when "10010100"  => sbox_out <= X"8A";
				when "10010101"  => sbox_out <= X"CE";
				when "10010110"  => sbox_out <= X"0E";
				when "10010111"  => sbox_out <= X"F5";
				
				when "10011000"  => sbox_out <= X"4D";
				when "10011001"  => sbox_out <= X"E4";
				when "10011010"  => sbox_out <= X"5C";
				when "10011011"  => sbox_out <= X"45";
				when "10011100"  => sbox_out <= X"54";
				when "10011101"  => sbox_out <= X"AB";
				when "10011110"  => sbox_out <= X"83";
				when "10011111"  => sbox_out <= X"9C";
				
-- 0x8e,0x2f,0x04,0x74,0xcb,0x07,0x55,0x2d, 0x86,0xaa,0xb3,0xa3,0x29,0xec,0x51,0xe0, OK
				when "10100000"  => sbox_out <= X"8E";
				when "10100001"  => sbox_out <= X"2F";
				when "10100010"  => sbox_out <= X"04";
				when "10100011"  => sbox_out <= X"74";
				when "10100100"  => sbox_out <= X"CB";
				when "10100101"  => sbox_out <= X"07";
				when "10100110"  => sbox_out <= X"55";
				when "10100111"  => sbox_out <= X"2D";
				
				when "10101000"  => sbox_out <= X"86";
				when "10101001"  => sbox_out <= X"AA";
				when "10101010"  => sbox_out <= X"B3";
				when "10101011"  => sbox_out <= X"A3";
				when "10101100"  => sbox_out <= X"29";
				when "10101101"  => sbox_out <= X"EC";
				when "10101110"  => sbox_out <= X"51";
				when "10101111"  => sbox_out <= X"E0";
				
-- 0xfb,0x8c,0xe2,0xd6,0x12,0xe8,0x01,0xa5, 0xa0,0xd2,0xef,0x9b,0x93,0x11,0x35,0xd3, OK
				when "10110000"  => sbox_out <= X"FB";
				when "10110001"  => sbox_out <= X"8C";
				when "10110010"  => sbox_out <= X"E2";
				when "10110011"  => sbox_out <= X"D6";
				when "10110100"  => sbox_out <= X"12";
				when "10110101"  => sbox_out <= X"E8";
				when "10110110"  => sbox_out <= X"01";
				when "10110111"  => sbox_out <= X"A5";
				
				when "10111000"  => sbox_out <= X"A0";
				when "10111001"  => sbox_out <= X"D2";
				when "10111010"  => sbox_out <= X"EF";
				when "10111011"  => sbox_out <= X"9B";
				when "10111100"  => sbox_out <= X"93";
				when "10111101"  => sbox_out <= X"11";
				when "10111110"  => sbox_out <= X"35";
				when "10111111"  => sbox_out <= X"D3";
				
-- 0x1d,0x79,0x1a,0xb5,0x25,0x18,0xb7,0xaf, 0x2c,0x4f,0xff,0xa2,0xc8,0x13,0x22,0x06, OK
				when "11000000"  => sbox_out <= X"1D";
				when "11000001"  => sbox_out <= X"79";
				when "11000010"  => sbox_out <= X"1A";
				when "11000011"  => sbox_out <= X"B5";
				when "11000100"  => sbox_out <= X"25";
				when "11000101"  => sbox_out <= X"18";
				when "11000110"  => sbox_out <= X"B7";
				when "11000111"  => sbox_out <= X"AF";
				
				when "11001000"  => sbox_out <= X"2C";
				when "11001001"  => sbox_out <= X"4F";
				when "11001010"  => sbox_out <= X"FF";
				when "11001011"  => sbox_out <= X"A2";
				when "11001100"  => sbox_out <= X"C8";
				when "11001101"  => sbox_out <= X"13";
				when "11001110"  => sbox_out <= X"22";
				when "11001111"  => sbox_out <= X"06";
				
-- 0xe7,0xbf,0x44,0x3a,0xc7,0x41,0xbe,0xd1,0x15,0xfa,0x6a,0x67,0x95,0x08,0xb2,0xa1, OK
				when "11010000"  => sbox_out <= X"E7";
				when "11010001"  => sbox_out <= X"BF";
				when "11010010"  => sbox_out <= X"44";
				when "11010011"  => sbox_out <= X"3A";
				when "11010100"  => sbox_out <= X"C7";
				when "11010101"  => sbox_out <= X"41";
				when "11010110"  => sbox_out <= X"BE";
				when "11010111"  => sbox_out <= X"D1";
				
				when "11011000"  => sbox_out <= X"15";
				when "11011001"  => sbox_out <= X"FA";
				when "11011010"  => sbox_out <= X"6A";
				when "11011011"  => sbox_out <= X"67";
				when "11011100"  => sbox_out <= X"95";
				when "11011101"  => sbox_out <= X"08";
				when "11011110"  => sbox_out <= X"B2";
				when "11011111"  => sbox_out <= X"A1";
				
-- 0x19,0xae,0x4b,0x7e,0xc9,0xfe,0x85,0x0b, 0x38,0x5a,0x27,0x0a,0x89,0x47,0x84,0x75, OK
				when "11100000"  => sbox_out <= X"19";
				when "11100001"  => sbox_out <= X"AE";
				when "11100010"  => sbox_out <= X"4B";
				when "11100011"  => sbox_out <= X"7E";
				when "11100100"  => sbox_out <= X"C9";
				when "11100101"  => sbox_out <= X"FE";
				when "11100110"  => sbox_out <= X"85";
				when "11100111"  => sbox_out <= X"0B";
				
				when "11101000"  => sbox_out <= X"38";
				when "11101001"  => sbox_out <= X"5A";
				when "11101010"  => sbox_out <= X"27";
				when "11101011"  => sbox_out <= X"0A";
				when "11101100"  => sbox_out <= X"89";
				when "11101101"  => sbox_out <= X"47";
				when "11101110"  => sbox_out <= X"84";
				when "11101111"  => sbox_out <= X"75";
				
-- 0xb1,0xa6,0x3f,0x30,0x02,0x63,0x72,0xf2, 0xa7,0x2a,0xf9,0x61,0x32,0x6d,0xb9,0x90, OK
				when "11110000"  => sbox_out <= X"B1";
				when "11110001"  => sbox_out <= X"A6";
				when "11110010"  => sbox_out <= X"3F";
				when "11110011"  => sbox_out <= X"30";
				when "11110100"  => sbox_out <= X"02";
				when "11110101"  => sbox_out <= X"63";
				when "11110110"  => sbox_out <= X"72";
				when "11110111"  => sbox_out <= X"F2";
				
				when "11111000"  => sbox_out <= X"A7";
				when "11111001"  => sbox_out <= X"2A";
				when "11111010"  => sbox_out <= X"F9";
				when "11111011"  => sbox_out <= X"61";
				when "11111100"  => sbox_out <= X"32";
				when "11111101"  => sbox_out <= X"6D";
				when "11111110"  => sbox_out <= X"B9";
				when others 	    => sbox_out <= X"90"; 
		end case;
	 end process;
	end behavior;
