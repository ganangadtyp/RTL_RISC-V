// This file contains a few of standard operation of CP and Comm

#include <hal.h>

void write_mmi_8(uint8_t addr, uint8_t value){
	switch (addr)
	{
	case (addr_COPCRCEN):
		data_14 = 0x00000000 | value;
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_14); 
	break;
	case (addr_COPWREN):
		data_1C = data_1C & 0xFFFFFF00;
		data_1C = data_1C | value;
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_1C); 
	break;
	case (addr_COPWR):
		data_1C = data_1C & 0xFFFF00FF;
		data_1C = data_1C | (value << 8);
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_1C); 
	break;
	case (addr_COPWRLN):
		data_1C = data_1C & 0xFF00FFFF;
		data_1C = data_1C | (value << 16);
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_1C); 
	break;
	case (addr_COPRDEN):
		data_1C = data_1C & 0x00FFFFFF;
		data_1C = data_1C | (value << 24);
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_1C); 
	break;
	
	default:
		break;
	}
}

uint8_t read_mmi_8(uint8_t addr, uint8_t value){
	switch (addr)
	{
	case (addr_COPCRCO2):
		return ((*mmi_04 >> 24) & 0xFF);
	break;
	
	default:
		break;
	}
}

// void write_1C(){
// 	(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)((COPRDEN << 24) | (COPWRLN << 16) | (COPWR << 8) | (COPWREN));
// }


// Initialization, give all inputs 0xFF
void coprocessor_init(){
	// COPMOSI 			= 0xFF; //DataIn
	// COPTH 				= 0xFFFF; //AdThIn
	// COPSRC 				= 0xFFFF; //AdSrcIn
	// COPDST 				= 0xFFFF; //AdDstIn
	// // COPTH2 				= 0xFF; //AdThIn
	// // COPSRC2 			= 0xFF; //AdSrcIn
	// // COPDST2				= 0xFF; //AdDstIn
	// COPWR				= 0xFF;
	// COPWREN				= 0xFF;
	// COPRDEN				= 0xFF;
	// COPCRCINIT_1 	    = 0XFF;
	// COPCRCINIT_2 	    = 0XFF;
	// COPCRCI_1 		    = 0XFF;
	// COPCRCI_2 		    = 0XFF;
	// COPCRCEN			= 0XFF;
	// COPCOM 				= 0xFF; //CommandIn
    
    // write_0C();
	// write_10();
	// write_14();
	// write_18();
	// write_1C();

}

//-------------------------------------------------------------------------------------------
// SHARED MEMORY CONTROLLER
// copas block data
void copy_data_block_sequential(unsigned char lower_source_address2, unsigned char lower_source_address, 
	unsigned char upper_source_address2, unsigned char upper_source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x84;
	write_0C();
	COPDST = (destination_address2 << 8) | (destination_address);
	write_10();
	COPTH = (upper_source_address2 << 8) | upper_source_address;
	write_0C();
	COPSRC = (lower_source_address2 << 8) | lower_source_address;
	write_10();
	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x04 = flag jika memory sedang read	
	do {
    	read_00();
	} while (COPSTATR & 0x0C); //0x0C = 0x04 OR 0x08
	COPCOM = 0xFF;
	write_0C();
}

void copy_data_block_independent(unsigned char lower_source_address2, unsigned char lower_source_address, 
	unsigned char upper_source_address2, unsigned char upper_source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x04;
	write_0C();
	COPDST = (destination_address2 << 8) | destination_address;
	write_10();
	COPTH = (upper_source_address2 << 8) | upper_source_address;
	write_0C();
	COPSRC = (lower_source_address2 << 8) | lower_source_address;
	write_10();
	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x08 = flag jika memory sedang read	
	
	do {
    	read_00();
	} while (COPSTATR & 0x0C); //0x0C = 0x04 OR 0x08

	COPCOM = 0xFF;
	write_0C();
}

void write_data_independent(unsigned char destination_address2, unsigned char destination_address, unsigned copdata){
	COPCOM = 0x03;
	write_0C();
	COPDST = (destination_address2 << 8 ) | destination_address;
	write_10();
	COPMOSI = copdata;
	write_0C();
	// PERHATIAN: perhatikan flag penuh instruction buufer 

	do {
    	read_00();
	} while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}


void write_data_sequential(unsigned char destination_address2, unsigned char destination_address, unsigned copdata){
	COPCOM = 0x83;
	write_0C();
	COPDST = (destination_address2 << 8) | destination_address;
	write_10();
	COPMOSI = copdata;
	write_0C();

	do {
    	read_00();
	} while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}
	
unsigned read_data_sequential(unsigned char source_address2, unsigned char source_address){
	COPCOM = 0x82;
	write_0C();
	COPSRC = (source_address2 << 8) + source_address;
	write_10();
	read_00();
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
	write_0C();
	// read_00();
	// while (!(COPSTATR & 0x08));

	do {
    	read_00();
	} while (!(COPSTATR & 0x08));

	COPCOM = 0x00;
	write_0C();
	return COPMISO;
}

unsigned read_data_independent(unsigned char source_address2, unsigned char source_address){
	COPCOM = 0x02;
	write_0C();
	COPSRC = (source_address2 << 8) | source_address;
	write_10();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
	
	do {
    	read_00();
	} while (!(COPSTATR & 0x08));
	//while (!(COPSTATR & 0x08));
	
	COPCOM = 0x00;
	write_0C();
	return COPMISO;
}

void copy_data_sequential(unsigned char source_address2, unsigned char source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x81;
	write_0C();
	COPSRC = (source_address2 << 8) | source_address;
	write_10();
	COPDST = (destination_address2 << 8) | destination_address;
	write_10();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void copy_data_independent(unsigned char source_address2, unsigned char source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x01;
	write_0C();
	COPSRC = (source_address2 << 8) | source_address;
	write_10();
	COPDST = (destination_address2 << 8) |destination_address;
	write_10();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// Coprocessor controller

void HASH_sequential(){
	COPCOM = 0x85;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	//while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void HASH_independent(){
	COPCOM = 0x05;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_encrypt_k_sequential(){
	COPCOM = 0x86;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write();
}

void BC3_encrypt_k_independent(){
	COPCOM = 0x06;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_encrypt_sequential(){
	COPCOM = 0x89;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_encrypt_independent(){
	COPCOM = 0x09;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_decrypt_k_independent(){
	COPCOM = 0x07;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_decrypt_k_sequential(){
	COPCOM = 0x87;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_decrypt_independent(){
	COPCOM = 0x0A;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void BC3_decrypt_sequential(){
	COPCOM = 0x8A;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_keygen_sequential(){
	COPCOM = 0x8B;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_dec_keygen_sequential(){
	COPCOM = 0x9C;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_keygen_independent(){
	COPCOM = 0x0B;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_dec_keygen_independent(){
	COPCOM = 0x1C;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_encrypt_sequential(){
	COPCOM = 0x9B;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_decrypt_sequential(){
	COPCOM = 0x9D;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_encrypt_independent(){
	COPCOM = 0x1B;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void AES_decrypt_independent(){
	COPCOM = 0x1D;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void Addition_sequential(){
	COPCOM = 0x8C;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void Addition_independent(){
	COPCOM = 0x0C;
	write_0C();
	
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}

void Subtraction_sequential(){
	COPCOM = 0x8D;
	write_0C();
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}

void Subtraction_independent(){
	COPCOM = 0x0D;
	write_0C();

	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}

void Multiplication_sequential(){
	COPCOM = 0x8E;
	write_0C();

	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

void Multiplication_independent(){
	COPCOM = 0x0E;
	write_0C();
	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}

void Division_sequential(){
	COPCOM = 0x92;
	write_0C();

	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);

	COPCOM = 0xFF;
	write_0C();
}

void Division_independent(){
	COPCOM = 0x12;
	write_0C();

	do {
    	read_00();
	} while (COPSTATR & 0x04);
	// while (COPSTATR & 0x04);
	
	COPCOM = 0xFF;
	write_0C();
}

// ---------------------------------------------------------------------------//
void send_MMI_1C(){
    (*(uint32_t *) (base_address + 0x1C)) = (uint32_t)((COPRDEN << 24) | (COPWRLN << 16) | (COPWR << 8) | (COPWREN));
}

// CONTACTLESS COMMUNICATION FUNCTION
unsigned char rd_contactless(){
	unsigned char a;
	a = COPRD;
	COPRDEN = 0x00;
	write_1C();
	COPRDEN = 0xFF;
	write_1C();
	return a;
}

unsigned char drain_fifo(){
	unsigned char a;
	while(!(COPRDSTAT & 0X04)){
		a = COPRD;
		COPRDEN = 0x00;
		write_1C();
		COPRDEN = 0xFF;
		write_1C();
	}
	return a;
}

void wr_contactless(unsigned char *data_to_sent, unsigned char *data_lenght){
	COPWR = *data_to_sent;
	write_1C();
	COPWRLN = *data_lenght;
	write_1C();
	COPWREN = 0x00;	
	write_1C();
	COPWREN = 0xFF;
	write_1C();
}
//-------------------------------------------------------------------------------------------


// (*(uint32_t *) (base_address + 0x0C)) = (uint32_t)((COPTH << 16)) | (COPCOM << 8) | (COPMOSI);
// (*(uint32_t *) (base_address + 0x10)) = (uint32_t)((COPDST << 16) | (COPSRC));
// (*(uint32_t *) (base_address + 0x14)) = (uint32_t)(0x00000000 | (COPCRCEN));
// (*(uint32_t *) (base_address + 0x18)) = (uint32_t)((COPCRCI_2 << 24) | (COPCRCI_1 << 16) | (COPCRCINIT_2 << 8) | (COPCRCINIT_1));
// (*(uint32_t *) (base_address + 0x1C)) = (uint32_t)((COPRDEN << 24) | (COPWRLN << 16) | (COPWR << 8) | (COPWREN));


// void write_0C(){
// 	(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)((COPTH << 16) | (COPCOM << 8) | (COPMOSI));
// }

// void write_10(){
// 	(*(uint32_t *) (base_address + 0x10)) = (uint32_t)((COPDST << 16) | (COPSRC));
// }

// void write_14(){
// 	(*(uint32_t *) (base_address + 0x14)) = (uint32_t)(0x00000000 | (COPCRCEN));
// }

// void write_18(){
// 	(*(uint32_t *) (base_address + 0x18)) = (uint32_t)((COPCRCI_2 << 24) | (COPCRCI_1 << 16) | (COPCRCINIT_2 << 8) | (COPCRCINIT_1));
// }

// void write_1C(){
// 	(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)((COPRDEN << 24) | (COPWRLN << 16) | (COPWR << 8) | (COPWREN));
// }

// void read_00(){
// 	COPSTATR2	= ((*mmi_00 >> 16) & 0xFF); // StatusOut2
// 	COPSTATR    = ((*mmi_00 >> 8 ) & 0xFF); // StatusOut
// 	COPMISO     = ( *mmi_00 & 0xFF);    // DataOut 
// }
   
// void read_04(){
// 	COPCRCO2	= ((*mmi_04 >> 24) & 0xFF);
// 	COPCRCO1	= ((*mmi_04 >> 16) & 0xFF);
// 	COPCRCSTAT  = ((*mmi_04 >> 8 ) & 0xFF);
// }

// void read_08(){
// 	COPRDLN	    = ((*mmi_08 >> 24) & 0xFF);
// 	COPRDSTAT	= ((*mmi_08 >> 16) & 0xFF);
// 	COPRD	    = ((*mmi_08 >> 8 ) & 0xFF);
// 	COPWRSTAT   = ( *mmi_08 & 0xFF);
// }

// void read_COPCRCO2(){
// 	COPCRCO2	= ((*mmi_04 >> 24) & 0xFF);
// }

// void read_COPCRCO1(){
// 	COPCRCO1	= ((*mmi_04 >> 16) & 0xFF);
// }

// void read_COPCRCSTAT(){
// 	COPCRCSTAT	= ((*mmi_04 >> 8) & 0xFF);
// }