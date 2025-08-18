#include "hal.h"

void main(void) {
	// Variable to increment loop
    uint16_t i;
    uint16_t P0 = 0xFF;

    // Initializing input ports of Coprocessors
	coprocessor_init();
	
    // write key BC3
	for (i = 0; i < 8; i++) {
		write_data_sequential(i, i);
  }
	// write _data BC3
	for (i = 8; i < 16; i++) {
		write_data_sequential(i, i);
  }
	
	// write key aes	
	for (i = 16; i < 48; i++) {
		write_data_sequential(i, i);
  }
	// write _data aes
	for (i = 48; i < 64; i++) {
		write_data_sequential(i, i);
  }
	
	// write _data hash
	for (i = 64; i < 128; i++) {
		write_data_sequential(i, i);
  }
	
	AES_keygen_sequential();
	//write add a
	write_data_independent(0x9f, 0x05);
	//write add b
	write_data_sequential(0xBf, 0x05);
	
	
	//write mul a
	write_data_sequential(0xdf, 0x05);
	//write mul b
	write_data_sequential(0xff, 0x03);
	
	//write div a
	write_data_sequential(0x1f, 0x06);
	//write div b
	write_data_sequential(0x3f, 0x03);
	
	//write xor a
	write_data_sequential(0x015f, 0xa5);
	//write xor b
	write_data_sequential(0x017f, 0x55);
	// Execute following operations :
    BC3_encrypt_k_sequential();
	HASH_independent();
	Addition_independent();
	Multiplication_independent();
	Division_independent();
	
    // read add result
    P0 = read_data_sequential(0x01D7);
	// execute AES encryption
	AES_encrypt_sequential();
    // read mul
	P0 = read_data_independent(0x0217);
    // execute BC3 encryption
	BC3_encrypt_independent();
    //Execute substraction
	Subtraction_independent();
	
	//copy aes decrypt result to aes _data in
	copy_data_block_sequential(0x0188, 0x0197, 0x0030);
	AES_dec_keygen_sequential();
	
    //copy BC3 decrypt reseult to BC3 _data in
	copy_data_block_independent(0x0180, 0x0187, 0x0008);
	BC3_decrypt_k_sequential();
	AES_decrypt_independent();
	BC3_decrypt_sequential();
	
	while(1);
}