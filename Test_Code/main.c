#include <hal.h>
#include <reg51.h>

void main(void) {
	unsigned char i;
	init_HW();
	P0 = 0xFF;
	// write key BC3
	for (i = 0; i < 8; i++) {
		write_data_sequential(0x00, i, i);
  }
	// write _data BC3
	for (i = 8; i < 16; i++) {
		write_data_sequential(0x00, i, i);
  }
	
	// write key aes	
	for (i = 16; i < 48; i++) {
		write_data_sequential(0x00, i, i);
  }
	// write _data aes
	for (i = 48; i < 64; i++) {
		write_data_sequential(0x00, i, i);
  }
	
	// write _data hash
	for (i = 64; i < 128; i++) {
		write_data_sequential(0x00, i, i);
  }
	
	AES_keygen_sequential();
	//write add a
	write_data_independent(0x00, 0x9f, 0x05);
	//write add b
	write_data_sequential(0x00, 0xBf, 0x05);
	
	
	//write mul a
	write_data_sequential(0x00, 0xdf, 0x05);
	//write mul b
	write_data_sequential(0x00, 0xff, 0x03);
	
	//write div a
	write_data_sequential(0x01, 0x1f, 0x06);
	//write div b
	write_data_sequential(0x01, 0x3f, 0x03);
	
	//write xor a
	write_data_sequential(0x01, 0x5f, 0xa5);
	//write xor b
	write_data_sequential(0x01, 0x7f, 0x55);
	BC3_encrypt_k_sequential();
	HASH_independent();
	Addition_independent();
	Multiplication_independent();
	Division_independent();
	P0 = read_data_sequential(0x01, 0xD7); // read add
	
	AES_encrypt_sequential();
	P0 = read_data_independent(0x02, 0x17); // read mul
	BC3_encrypt_independent();
	Subtraction_independent();
	
	//copy aes decrypt result to aes _data in
	copy_data_block_sequential(0x01, 0x88, 0x01, 0x97, 0x00, 0x30);
	AES_dec_keygen_sequential();
	//copy BC3 decrypt reseult to BC3 _data in
	copy_data_block_independent(0x01, 0x80, 0x01, 0x87, 0x00, 0x08);
	BC3_decrypt_k_sequential();
	AES_decrypt_independent();
	BC3_decrypt_sequential();
	
	while(1);
}