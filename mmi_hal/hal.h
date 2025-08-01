#include <stdint.h>

#ifndef HAL_H
#define HAL_H

/************* Address *************/
#define base_address    0x00040000

#define addr_COPSTATR2	    0x0
#define addr_COPSTATR       0x0
#define addr_COPMISO        0x0
#define addr_COPCRCO2	    0x07
#define addr_COPCRCO1	    0x06
#define addr_COPCRCSTAT     0x05
//  0x0addr_
#define addr_COPRDLN	    0x0B
#define addr_COPRDSTAT	    0x0A
#define addr_COPRD	        0x09
#define addr_COPWRSTAT      0x08
//  0x0addr_
#define addr_npu            0x0
#define addr_COPMOSI        0x0
#define addr_COPCOM         0x0
//  0xaddr_
#define addr_COPTH          0x1
#define addr_COPDST         0x1
#define addr_COPSRC         0x1
//  0x1addr_
#define addr_COPCRCEN       0x14
#define addr_COPCRCI_2      0x18
#define addr_COPCRCI_1      0x19
#define addr_COPCRCINIT_2   0x1A
#define addr_COPCRCINIT_1   0x1B
#define addr_COPRDEN        0x1C
#define addr_COPWRLN        0x1D
#define addr_COPWR          0x1E
#define addr_COPWREN        0x1F

// COP Output
// Crypt Output
uint32_t *mmi_00 = (uint32_t *) base_address + 0x00;
// Comm Output
uint32_t *mmi_04 = (uint32_t *) base_address + 0x04;
uint32_t *mmi_08 = (uint32_t *) base_address + 0x08;

// Cop Input
// Crypt Input
uint32_t *mmi_0C = (uint32_t *) base_address + 0x0C;
uint32_t *mmi_10 = (uint32_t *) base_address + 0x10;
// Comm Input
uint32_t *mmi_14 = (uint32_t *) base_address + 0x14;
uint32_t *mmi_18 = (uint32_t *) base_address + 0x18;
// uint32_t *mmi_1C = (uint32_t *) base_address + 0x1C;

uint32_t data_0C;
uint32_t data_10;
uint32_t data_14;
uint32_t data_18;
uint32_t data_1C;

#define mmi_1C  (*(uint32_t *) (base_address + 0x1C))

/************* End of Address *************/

// uint8_t COPSTATR2	= ((*mmi_00 >> 16) & 0xFF); // StatusOut2
// uint8_t COPSTATR    = ((*mmi_00 >> 8 ) & 0xFF); // StatusOut
// uint8_t COPMISO     = ( *mmi_00 & 0xFF);    // DataOut    

// uint8_t COPCRCO2	= ((*mmi_04 >> 24) & 0xFF);
// uint8_t COPCRCO1	= ((*mmi_04 >> 16) & 0xFF);
// uint8_t COPCRCSTAT  = ((*mmi_04 >> 8 ) & 0xFF);

// uint8_t COPRDLN	    = ((*mmi_08 >> 24) & 0xFF);
// uint8_t COPRDSTAT	= ((*mmi_08 >> 16) & 0xFF);
// uint8_t COPRD	    = ((*mmi_08 >> 8 ) & 0xFF);
// uint8_t COPWRSTAT   = ( *mmi_08 & 0xFF);



uint8_t COPSTATR2	;
uint8_t COPSTATR    ;
uint8_t COPMISO     ;

uint8_t COPCRCO2	;
uint8_t COPCRCO1	;
uint8_t COPCRCSTAT  ;

uint8_t COPRDLN	    ;
uint8_t COPRDSTAT	;
uint8_t COPRD	    ;
uint8_t COPWRSTAT   ;

// COP Input
uint8_t COPMOSI;
uint8_t COPCOM;

uint16_t COPTH;
uint16_t COPDST;
uint16_t COPSRC;

uint8_t COPCRCEN;
uint8_t COPCRCI_2;
uint8_t COPCRCI_1;
uint8_t COPCRCINIT_2;
uint8_t COPCRCINIT_1;
uint8_t COPRDEN;
uint8_t COPWRLN;
uint8_t COPWR;
uint8_t COPWREN;

// MMI Register
// (*(uint32_t *) (base_address + 0x0C)) = uint32_t((COPTH << 16) + (COPCOM << 8) + (COPMOSI));
// (*(uint32_t *) (base_address + 0x10)) = uint32_t((COPDST << 16) + (COPSRC));
// (*(uint32_t *) (base_address + 0x14)) = uint32_t(0x00000000 + (COPCRCEN));
// (*(uint32_t *) (base_address + 0x18)) = uint32_t((COPCRCI2 << 24) + (COPCRCI1 << 16) + (COPCRCINIT2 << 8) + (COPCRCINIT1));
// (*(uint32_t *) (base_address + 0x1C)) = uint32_t((COPRDEN << 24) + (COPWRLN << 16) + (COPWR << 8) + (COPWREN));

void coprocessor_init();

void write_0C();
void write_10();
void write_14();
void write_18();
void write_1C();
void read_00();
void read_04();
void read_08();
void read_COPCRCO2();
void read_COPCRCO1();
void read_COPCRCSTAT();

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
#endif  // HAL_H
