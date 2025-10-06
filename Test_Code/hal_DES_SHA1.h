// hal.h
// Programmer   : Ganang Aditya Pratama
// Afiliasi     : Lab VLSI, STEI, ITB
// Hardware Abstraction Layer untuk smart card

#include <reg51.h>

#ifndef HAL_H
#define HAL_H

// --- SFR Address Declarations ---
sfr COPSTATR    = 0xF8;
sfr COPMOSI     = 0xF9;
sfr COPMISO     = 0xFA;
sfr COPTH       = 0xFB;
sfr COPTH2      = 0xEB;
sfr COPSRC      = 0xFC;
sfr COPSRC2     = 0xEC;
sfr COPDST      = 0xFD;
sfr COPDST2     = 0xED;
sfr COPCOM      = 0xFF;
sfr COPWR       = 0xF1;
sfr COPWRLN     = 0xE1;
sfr COPWREN     = 0xF2;
sfr COPWRSTAT   = 0xF3;
sfr COPRD       = 0xF4;
sfr COPRDLN     = 0xE4;
sfr COPRDEN     = 0xF5;
sfr COPRDSTAT   = 0xF7;
sfr COPSTATR2   = 0xE8;

// --- CRC SFRs ---
sfr COPCRCINIT_1 = 0xE2;
sfr COPCRCINIT_2 = 0xD2;
sfr COPCRCO_1    = 0xE3;
sfr COPCRCO_2    = 0xD3;
sfr COPCRCEN     = 0xE5;
sfr COPCRCSTAT   = 0xD5;
sfr COPCRCI_1    = 0xE7;
sfr COPCRCI_2    = 0xD7;

void coprocessor_init();
void init_HW(void);
unsigned char rd_contactless();
unsigned char drain_fifo();
void wr_contactless(unsigned char *data_to_sent, unsigned char *data_lenght);
void copy_data_block_sequential(unsigned char lower_source_address2, unsigned char lower_source_address, 
																unsigned char upper_source_address2, unsigned char upper_source_address,
																unsigned char destination_address2, unsigned char destination_address);
void copy_data_block_independent(unsigned char lower_source_address2, unsigned char lower_source_address, 
																 unsigned char upper_source_address2, unsigned char upper_source_address,
																 unsigned char destination_address2, unsigned char destination_address);
void write_data_independent(unsigned char destination_address2, unsigned char destination_address, unsigned copdata);
void write_data_sequential(unsigned char destination_address2, unsigned char destination_address, unsigned copdata);
unsigned read_data_sequential(unsigned char source_address2, unsigned char source_address);
unsigned read_data_independent(unsigned char source_address2, unsigned char source_address);
void copy_data_sequential(unsigned char source_address2, unsigned char source_address,
													unsigned char destination_address2, unsigned char destination_address);
void copy_data_independent(unsigned char source_address2, unsigned char source_address,
													 unsigned char destination_address2, unsigned char destination_address);
void HASH_sequential();
void HASH_independent();
void BC3_encrypt_k_sequential();
void BC3_encrypt_k_independent();
void BC3_encrypt_sequential();
void BC3_encrypt_independent();
void BC3_decrypt_k_independent();
void BC3_decrypt_k_sequential();
void BC3_decrypt_independent();
void BC3_decrypt_sequential();
void AES_keygen_sequential();
void AES_keygen_independent();
void AES_encrypt_sequential();
void AES_encrypt_independent();
void AES_dec_keygen_sequential();
void AES_dec_keygen_independent();
void AES_decrypt_sequential();
void AES_decrypt_independent();
void Addition_sequential();
void Addition_independent();
void Subtraction_sequential();
void Subtraction_independent();
void Multiplication_sequential();
void Multiplication_independent();
void Division_sequential();
void Division_independent();
void DES_Enc_sequential();
void DES_Enc_independent();
void DES_Dec_sequential();
void DES_Dec_independent();
void SHA1_sequential();
void SHA1_independent();
#endif  // HAL_H