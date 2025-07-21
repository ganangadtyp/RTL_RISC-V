#include <hal.h>
#include <reg51.h>
void coprocessor_init(){
	COPMOSI 			= 0xFF;
	COPTH 				= 0xFF;
	COPSRC 				= 0xFF;
	COPDST 				= 0xFF;
	COPTH2 				= 0xFF;
	COPSRC2 			= 0xFF;
	COPDST2				= 0xFF;
	COPWR					= 0xFF;
	COPWREN				= 0xFF;
	COPRDEN				= 0xFF;
	COPCRCINIT_1 	= 0XFF;
	COPCRCINIT_2 	= 0XFF;
	COPCRCI_1 		= 0XFF;
	COPCRCI_2 		= 0XFF;
	COPCRCEN			= 0XFF;
	COPCOM 				= 0xFF;
}

// PERHATIAN!!!
// nilai sfr pada fungsi init_HW perlu disesuaikan
void init_HW(void){
	coprocessor_init();
	SCON  = 0xD0;                   /* SCON: mode 3, 9-bit UART, enable rcvr    */
	TMOD |= 0x20;                   /* TMOD: timer 1, mode 2, 8-bit reload      */
	TH1   = 0xff;                   /* TH1:  reload value for 9600 baud @ 3.58MHz  */
	TR1   = 1;                      /* TR1:  timer 1 run                        */
	TI    = 1;                      /* TI:   set TI to send first char of UART  */
}
// ---------------------------------------------------------------------------//
// CONTACTLESS COMMUNICATION FUNCTION
unsigned char rd_contactless(){
	unsigned char a;
	a = COPRD;
	COPRDEN = 0x00;
	COPRDEN = 0xFF;
	return a;
}

unsigned char drain_fifo(){
	unsigned char a;
	while(!(COPRDSTAT & 0X04)){
		a = COPRD;
		COPRDEN = 0x00;
		COPRDEN = 0xFF;
	}
	return a;
}

void wr_contactless(unsigned char *data_to_sent, unsigned char *data_lenght){
	COPWR = *data_to_sent;
	COPWRLN = *data_lenght;
	COPWREN = 0x00;	
	COPWREN = 0xFF;
}
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// SHARED MEMORY CONTROLLER
// copas block data
void copy_data_block_sequential(unsigned char lower_source_address2, unsigned char lower_source_address, 
	unsigned char upper_source_address2, unsigned char upper_source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x84;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	COPTH = upper_source_address;
	COPTH2 = upper_source_address2;
	COPSRC = lower_source_address;
	COPSRC2 = lower_source_address2;
	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x04 = flag jika memory sedang read	
	while (COPSTATR & 0x0C); //0x0C = 0x04 OR 0x08
	COPCOM = 0xFF;
}

void copy_data_block_independent(unsigned char lower_source_address2, unsigned char lower_source_address, 
	unsigned char upper_source_address2, unsigned char upper_source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x04;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	COPTH = upper_source_address;
	COPTH2 = upper_source_address2;
	COPSRC = lower_source_address;
	COPSRC2 = lower_source_address2;
	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x08 = flag jika memory sedang read	
	while (COPSTATR & 0x0C); //0x0C = 0x04 OR 0x08
	COPCOM = 0xFF;
}

void write_data_independent(unsigned char destination_address2, unsigned char destination_address, unsigned copdata){
	COPCOM = 0x03;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	COPMOSI = copdata;
	// PERHATIAN: perhatikan flag penuh instruction buufer 
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}


void write_data_sequential(unsigned char destination_address2, unsigned char destination_address, unsigned copdata){
	COPCOM = 0x83;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	COPMOSI = copdata;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}
	
unsigned read_data_sequential(unsigned char source_address2, unsigned char source_address){
	COPCOM = 0x82;
	COPSRC = source_address;
	COPSRC2 = source_address2;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
	while (!(COPSTATR & 0x08));
	COPCOM = 0x00;
	return COPMISO;
}

unsigned read_data_independent(unsigned char source_address2, unsigned char source_address){
	COPCOM = 0x02;
	COPSRC = source_address;
	COPSRC2 = source_address2;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;	
	while (!(COPSTATR & 0x08));
	COPCOM = 0x00;
	return COPMISO;
}

void copy_data_sequential(unsigned char source_address2, unsigned char source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x81;
	COPSRC = source_address;
	COPSRC2 = source_address2;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void copy_data_independent(unsigned char source_address2, unsigned char source_address,
	unsigned char destination_address2, unsigned char destination_address){
	COPCOM = 0x01;
	COPSRC = source_address;
	COPSRC2 = source_address2;
	COPDST = destination_address;
	COPDST2 = destination_address2;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// Coprocessor controller

void HASH_sequential(){
	COPCOM = 0x85;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void HASH_independent(){
	COPCOM = 0x05;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_encrypt_k_sequential(){
	COPCOM = 0x86;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_encrypt_k_independent(){
	COPCOM = 0x06;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_encrypt_sequential(){
	COPCOM = 0x89;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_encrypt_independent(){
	COPCOM = 0x09;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_decrypt_k_independent(){
	COPCOM = 0x07;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_decrypt_k_sequential(){
	COPCOM = 0x87;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_decrypt_independent(){
	COPCOM = 0x0A;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void BC3_decrypt_sequential(){
	COPCOM = 0x8A;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_keygen_sequential(){
	COPCOM = 0x8B;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_dec_keygen_sequential(){
	COPCOM = 0x9C;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_keygen_independent(){
	COPCOM = 0x0B;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_dec_keygen_independent(){
	COPCOM = 0x1C;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_encrypt_sequential(){
	COPCOM = 0x9B;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_decrypt_sequential(){
	COPCOM = 0x9D;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_encrypt_independent(){
	COPCOM = 0x1B;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void AES_decrypt_independent(){
	COPCOM = 0x1D;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Addition_sequential(){
	COPCOM = 0x8C;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Addition_independent(){
	COPCOM = 0x0C;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Subtraction_sequential(){
	COPCOM = 0x8D;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Subtraction_independent(){
	COPCOM = 0x0D;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Multiplication_sequential(){
	COPCOM = 0x8E;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Multiplication_independent(){
	COPCOM = 0x0E;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Division_sequential(){
	COPCOM = 0x92;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}

void Division_independent(){
	COPCOM = 0x12;
	while (COPSTATR & 0x04);
	COPCOM = 0xFF;
}