#include <stdint.h>

#ifndef HAL_H
#define HAL_H

/************* Coprocessors Ports Address Macro *************/
#define base_address   	0x00100000

#define COPSTATR2	  	0x02
#define COPSTATR      	0x01
#define COPMISO       	0x00

#define COPCRCO	  		0x06
#define COPCRCSTAT    	0x05

#define COPRDLN	      	0x0B
#define COPRDSTAT	  	0x0A
#define COPRD	      	0x09
#define COPWRSTAT     	0x08

#define npu           	0x0
#define COPMOSI       	0x0C
#define COPCOM        	0x0D

#define COPTH         	0x0E
#define COPDST        	0x12
#define COPSRC        	0x10

#define COPCRCEN      	0x14
#define COPCRCIN      	0x1A
#define COPCRCINIT    	0x18
#define COPRDEN       	0x1C
#define COPWRLN       	0x1D
#define COPWR         	0x1E
#define COPWREN       	0x1F

/******* MMI Data *********/
extern uint32_t data_00;
extern uint32_t data_04;
extern uint32_t data_08;
extern uint32_t data_0C;
extern uint32_t data_10;
extern uint32_t data_14;
extern uint32_t data_18;
extern uint32_t data_1C;

/******* HAL Functions Declaration *********/

//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// Initialization and Read/Write
extern void     coprocessor_init();
extern uint16_t read_mmi(uint8_t addr);
extern void     write_mmi(uint8_t addr, uint16_t value);

//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// CONTACTLESS COMMUNICATION
uint16_t rd_contactless();
uint16_t drain_fifo();
void wr_contactless(uint16_t *data_to_sent, uint16_t *data_lenght);

//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// SHARED MEMORY CONTROLLER
void copy_data_block_sequential(uint16_t lower_source_address, uint16_t upper_source_address, uint16_t destination_address);
void copy_data_block_independent(uint16_t lower_source_address, uint16_t upper_source_address, uint16_t destination_address);

void write_data_independent(uint16_t destination_address, uint16_t copdata);
void write_data_sequential(uint16_t destination_address, uint16_t copdata);
	
uint16_t read_data_sequential(uint16_t source_address);
uint16_t read_data_independent(uint16_t source_address);

void copy_data_sequential(uint16_t source_address, uint16_t destination_address);
void copy_data_independent( uint16_t source_address, uint16_t destination_address);

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// Coprocessor controller
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

void AES_dec_keygen_sequential();
void AES_dec_keygen_independent();

void AES_decrypt_sequential();
void AES_decrypt_independent();

void AES_encrypt_independent();
void AES_encrypt_sequential();

void Addition_sequential();
void Addition_independent();

void Subtraction_sequential();
void Subtraction_independent();

void Multiplication_sequential();
void Multiplication_independent();

void Division_sequential();
void Division_independent();

#endif  // HAL_H
