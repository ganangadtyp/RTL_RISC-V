// This file contains a few of standard operation of CP and Comm

#include "hal.h"

// Global Variable for Storing Data to Sent/Received Data to/from MMI,
// according to MMI Address.
uint32_t data_00;
uint32_t data_04;
uint32_t data_08;
uint32_t data_0C;
uint32_t data_10;
uint32_t data_14;
uint32_t data_18;
uint32_t data_1C;

//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// Initialization, Read, and Write

/**
 * @brief Sending data to MMI Register specified by an address then modify the specific bit position,
 * representing the input port to Coprocessors
 *
 * This function retrieve a data from MMI Register from a specified address,
 * then masking it based on the bit position of input port that wants to be written,
 * then writing and shifting the write value to that bit position,
 * then sending the full data back to the register with that specified address.
 *
 * @param addr 8-bit input port address
 * @param value 16-bit write value
 * 
 * @return None. 
 * 
 * @note Use this function to give input to Coprocessors.
 */
void write_mmi(uint8_t addr, uint16_t value){
	switch (addr)
	{
	/* ============================   WRITE  ============================ */
		// 0x0004_000C
	case (COPMOSI):
		data_0C &= 0xFFFFFF00; // Masking the bit position to reset old data, retain the unbothered data
		data_0C |= (value & 0xFF); //Writing value to the bit position
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C); // Sending back to MMI Register
    break;

    case (COPCOM):
	    data_0C &= 0xFFFF00FF; // Masking the bit position to reset old data, retain the unbothered data
        data_0C = data_0C | ((value & 0xFF) << 8); // Shifting left 8, based on the allocation, then write the value
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C); // Sending back to MMI Register
    break;

    case (COPTH):
        data_0C &= 0x0000FFFF;      // Masking the bit position to reset old data, retain the unbothered data
		data_0C |= (value << 16);   // Shifting left 16, based on the allocation, then write the value
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C); // Sending back to MMI Register
	break;

    	// 0x0004_0010
	case (COPSRC):
        data_10 &= 0xFFFF0000;
		data_10 |= value;
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_10);
	break;
    
    case (COPDST):
		data_10 &= 0x0000FFFF;
		data_10 |= (value << 16);
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_10); 
	break;

        // 0x0004_0014
	case (COPCRCEN):
		data_14 = 0x00000000 | (value & 0x00FF);		// For 8 bit data mask with 0x00FF to only store relevant bit
		(*(uint32_t *) (base_address + 0x14)) = (uint32_t)(data_14); 
	break;

		// 0x0004_0018
	case (COPCRCINIT):
		data_18 &= 0xFFFF0000;          
		data_18 |= value;
		(*(uint32_t *) (base_address + 0x18)) = (uint32_t)(data_18);
	break;
	case (COPCRCIN):
		data_18 &= 0x0000FFFF;
		data_18 |= (value << 16);
		(*(uint32_t *) (base_address + 0x18)) = (uint32_t)(data_18); 
	break;

		// 0x0004_001C
	case (COPWREN):
		data_1C &= 0xFFFFFF00;
		data_1C |= (value & 0xFF);
		(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)(data_1C); 
	break;
	case (COPWR):
		data_1C = data_1C & 0xFFFF00FF;
		data_1C = data_1C | ((value & 0xFF) << 8);
		(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)(data_1C); 
	break;
	case (COPWRLN):
		data_1C &= 0xFF00FFFF;
		data_1C |= ((value & 0xFF) << 16);
		(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)(data_1C); 
	break;
	case (COPRDEN):
		data_1C &= 0x00FFFFFF;
		data_1C |= ((value & 0xFF) << 24);
		(*(uint32_t *) (base_address + 0x1C)) = (uint32_t)(data_1C); 
	break;
	/* ---------------------------- WRITE END ---------------------------- */
	
	default:
		break;
	}
}

/**
 * @brief Reading a data from MMI Register specified by an address then masking the specific bit position,
 * representing the output port from Coprocessors
 *
 * This function retrieve a data from MMI Register from a specified address,
 * then masking it based on the bit position of output port that wants to be read,
 * then shifting right based on the bit position to LSB side.
 *
 * @param addr 8-bit output port address
 * 
 * @return 16-bit Output Data from Coprocessors
 * 
 * @note Use this function to read output from Coprocessors.
 */
uint16_t read_mmi(uint8_t addr){
	switch (addr)
	{
	/* ============================ READ ============================ */
		// 0x0004_0000
	case (COPMISO):
		data_00 = *(volatile uint32_t*)(base_address | 0x00); // Reading from MMI Register
		return (uint16_t)(data_00 & 0x00FF); // Return a data, masked based on bit position and length of the output port in the register
    break;
    
    case (COPSTATR):
		data_00 = *(volatile uint32_t*)(base_address | 0x00); // Reading from MMI Register
		return (uint16_t)((data_00 & 0x0000FF00) >> 8); // Return a data, masked based on bit position and length of the output port in the register,
		// and shift right based on bit position to LSB side.
    break;

    case (COPSTATR2):
		data_00 = *(volatile uint32_t*)(base_address | 0x00);
		return (uint16_t)((data_00 & 0x00FF0000) >> 16);
    break;

        // 0x0004_0004
	case (COPCRCSTAT):
		data_04 = *(volatile uint32_t*)(base_address | 0x04);
		return ((data_04 & 0x0000FF00) >> 8);
	break;
	case (COPCRCO):
		data_04 = *(volatile uint32_t*)(base_address | 0x04);
		return ((data_04 & 0xFFFF0000) >> 16);
	break;

		// 0x0004_0008
	case (COPWRSTAT):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		return (data_08 & 0x000000FF);
	break;
	case (COPRD):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		return ((data_08 & 0x0000FF00) >> 8);
	break;
	case (COPRDSTAT):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		return ((data_08 & 0x00FF0000) >> 16);
	break;
	case (COPRDLN):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		return ((data_08 & 0xFF000000) >> 24);
	break;
	/* ---------------------------- READ END ---------------------------- */

	default:
		return 0xFFFF;
	}
}

/**
 * @brief Initialize All Coprocessors Input Ports
 *
 * This funtion calls write_mmi to send input data to Coprocessors' input port
 * to send 0xFF (for 8 bits ports) or 0xFFFF (for 16 bits ports)
 *
 * @return None. 
 * 
 * @note Run this function at the start of the program.
 */
void coprocessor_init(){
	write_mmi(COPMOSI, 0x00FF);
    write_mmi(COPCOM, 0x00FF);
    write_mmi(COPTH, 0xFFFF);
    write_mmi(COPSRC, 0xFFFF);
    write_mmi(COPDST, 0xFFFF);
    
    write_mmi(COPCRCEN, 0x00FF);
	write_mmi(COPCRCIN, 0xFFFF);
	write_mmi(COPCRCINIT, 0xFFFF);
	write_mmi(COPWREN, 0x00FF);
	write_mmi(COPWR, 0x00FF);
	write_mmi(COPWRLN, 0x00FF);
	write_mmi(COPRDEN, 0x00FF);
}

// ---------------------------------------------------------------------------//
// CONTACTLESS COMMUNICATION FUNCTION

/**
 * @brief Read a value from the COPRD port.
 *
 * This function reads 16-bit value from the COPRD port,
 * then toggles the COPRDEN port to 0x00 then 0xFF to complete the read cycle.
 *
 * @return The 16-bit value read from COPRD.
 */
uint16_t rd_contactless(){
	uint16_t a;
	a = read_mmi(COPRD);
	write_mmi(COPRDEN, 0x0000);
	write_mmi(COPRDEN, 0x00FF);
	return a;
}

/**
 * @brief Read continuously the contactless FIFO buffer until empty.
 *
 * This function continuously reads from the COPRD port and toggles
 * the COPRDEN port by 0x00 then 0xFF while the FIFO contains data. It stops when
 * the COPRDSTAT 3rd bit (0x04) indicates the FIFO is empty.
 *
 * @return The last 16-bit value read from the COPRD port before it became empty.
 */
uint16_t drain_fifo(){
	uint16_t a;
	while(!(read_mmi(COPRDSTAT) & 0X04)){
		a = read_mmi(COPRD);
		write_mmi(COPRDEN, 0x0000);
		write_mmi(COPRDEN, 0x00FF);
	}
	return a;
}

//Sending data via contactless communication.
// *data_to_sent : Pointer to a data to be sent
// *data_lenght : Pointer to a length of the data to be sent
/**
 * @brief Sending data via contactless communication.
 *
 * This function sends data to the contactless interface
 * by sending the data to COPWR port, the data length to COPWRLN port,
 * and toggling the write enable port COPWREN by 0x00 then 0xFF.
 *
 * @param lower_source_address 16-bit lower source address of Shared MEM that wants to be copied
 * @param upper_source_address 16-bit upper source address of Shared MEM that wants to be copied
 * @param destination_address 16-bit destination address to store copied block of data
 *
 * @return None.
 */
void wr_contactless(uint16_t *data_to_sent, uint16_t *data_lenght){
	
	write_mmi(COPWR, *data_to_sent);
	write_mmi(COPWRLN, *data_lenght);
	write_mmi(COPWREN, 0x0000);
	write_mmi(COPWREN, 0x00FF);
}
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// Cryptographic Coprocessor's SHARED MEMORY CONTROLLER

/**
 * @brief Copying a block of Shared MEM in Crypto Coprocessor
 * Sequentially (not parallel with other function)
 *
 * This funtion trigger copying a block of shared memory command sequentially to COPCOM
 * then sending destination address to paste in COPDST port,
 * upper source address of the copied block in COPTH port,
 * lower source address of the copied block in COPSRC port,
 * then waits for 4th and 3rd bit of COPSTATR to turn '1' before sending idle command
 * to COPCOM. 
 *
 * @param lower_source_address 16-bit lower source address of Shared MEM that wants to be copied
 * @param upper_source_address 16-bit upper source address of Shared MEM that wants to be copied
 * @param destination_address 16-bit destination address to store copied block of data
 *
 * @return None.
 */
void copy_data_block_sequential(uint16_t lower_source_address, uint16_t upper_source_address, uint16_t destination_address){
	write_mmi(COPCOM, 0x84);
	write_mmi(COPDST, destination_address);
	write_mmi(COPTH, upper_source_address);
	write_mmi(COPSRC, lower_source_address);

	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x04 = flag jika memory sedang read	
	while (read_mmi(COPSTATR) & 0x0C); //0x0C = 0x04 OR 0x08
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Copying a block of Shared MEM in Crypto Coprocessor
 * Independently (enabling parallel with other function)
 *
 * This funtion trigger copying a block of shared memory command independently to COPCOM
 * then sending destination address to paste in COPDST port,
 * upper source address of the copied block in COPTH port,
 * lower source address of the copied block in COPSRC port,
 * then waits for 4th and 3rd bit of COPSTATR to turn '1' before sending idle command
 * to COPCOM. 
 *
 * @param lower_source_address 16-bit lower source address of Shared MEM that wants to be copied
 * @param upper_source_address 16-bit upper source address of Shared MEM that wants to be copied
 * @param destination_address 16-bit destination address to store copied block of data
 *
 * @return None.
 */
void copy_data_block_independent(uint16_t lower_source_address, uint16_t upper_source_address, uint16_t destination_address){
	write_mmi(COPCOM, 0x04);
	write_mmi(COPDST, destination_address);
	write_mmi(COPTH, upper_source_address);
	write_mmi(COPSRC, lower_source_address);
	// PERHATIAN: Jangan ubah nilai source address pada saat membaca.
	// COPSTATR 0x08 = flag jika memory sedang read	
	while (read_mmi(COPSTATR) & 0x0C); //0x0C = 0x04 OR 0x08
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief  Sends data to Coprocessor Independently (enabling parallel with other function)
 *
 * This funtion trigger write independently command to COPCOM
 * and writes the provided data to COPMOSI to store in Shared Mem at COPDST
 * then waits for 3rd bit of COPSTATR to turn '1' before sending idle command
 * to COPCOM. 
 *
 * @param copdata 16-bit data to send.
 * @param destination_addres 16-bit destination address.
 *
 * @return None.
 */
void write_data_independent(uint16_t destination_address, uint16_t copdata){
	write_mmi(COPCOM, 0x03);
	write_mmi(COPDST, destination_address);
	write_mmi(COPMOSI, copdata);
	// PERHATIAN: perhatikan flag penuh instruction buufer 
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief  Sends data to Coprocessor Sequentially (not parallel with other function)
 *
 * This funtion trigger write sequential command to COPCOM
 * and writes the provided data to COPMOSI to store in Shared Mem at COPDST
 * then waits for 3rd bit of COPSTATR to turn '1' before sending idle command
 * to COPCOM. 
 *
 * @param copdata 16-bit data to send.
 * @param destination_addres 16-bit destination address.
 *
 * @return None.
 */
void write_data_sequential(uint16_t destination_address, uint16_t copdata){
	write_mmi(COPCOM, 0x83);
	write_mmi(COPDST, destination_address);
	write_mmi(COPMOSI, copdata);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief  Reads data from Coprocessor Sequentially (not parallel with other function)
 *
 * This funtion trigger read sequential command to COPCOM
 * and gives COPSRC the source address of data that wants to be read
 * then waits until the 3rd bit of COPSTATR to turn '1' then trigger idle to COPCOM,
 * then waits until the 4th bit of COPSTATR to turn '1' that indicate a valid data to read
 * then trigger done reading to COPCOM.
 * 
 * @param source_address 16-bit source address of the data.
 *
 * @return 16-bit Read Data.
 */
uint16_t read_data_sequential(uint16_t source_address){
	uint16_t a;
	write_mmi(COPCOM, 0x82);
	write_mmi(COPSRC, source_address);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
	while (!(read_mmi(COPSTATR) & 0x08));
	a = read_mmi(COPMISO);
	write_mmi(COPCOM, 0x00);
	return a;
}

/**
 * @brief  Reads data from Coprocessor Independent/Parallel (enabling parallel function with other function)
 *
 * This funtion trigger read independent/parallel command to COPCOM
 * and gives COPSRC the source address of data that wants to be read
 * then waits until the 3rd bit of COPSTATR to turn '1' then trigger idle to COPCOM,
 * then waits until the 4th bit of COPSTATR to turn '1' that indicate a valid data to read
 * then trigger done reading to COPCOM.
 * 
 * @param source_address 16-bit source address of the data.
 *
 * @return 16-bit Read Data.
 */
uint16_t read_data_independent(uint16_t source_address){
	uint16_t a;
	write_mmi(COPCOM, 0x02);
	write_mmi(COPSRC, source_address);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);	
	while (!(read_mmi(COPSTATR) & 0x08));
	a = read_mmi(COPMISO);
	write_mmi(COPCOM, 0x00);
	return a;
}

/**
 * @brief Copy a data from shared memory at specified address with sequential process (not parallel with other function). 
 *
 * This function triggers a command to copy data sequentially to COPCOM.
 * COPSRC is given the source address value of the data to be copied, 
 * COPDST is given the destination address value where the data is pasted.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 * 
 * @param source_address 16-bit source address of the data.
 * @param destintion_address 16-bit destination address to paste
 *
 * @return None.
 */
void copy_data_sequential(uint16_t source_address, uint16_t destination_address){
	write_mmi(COPCOM, 0x81);
	write_mmi(COPSRC, source_address);
	write_mmi(COPDST, destination_address);
	while (COPSTATR & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Copy a data from shared memory at specified address with independent process (enabling parallel process with other function). 
 *
 * This function triggers a command to copy data independently to COPCOM.
 * COPSRC is given the source address value of the data to be copied, 
 * COPDST is given the destination address value where the data is pasted.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 * 
 * @param source_address 16-bit source address of the data.
 * @param destintion_address 16-bit destination address to paste
 *
 * @return None.
 */
void copy_data_independent( uint16_t source_address, uint16_t destination_address){
	write_mmi(COPCOM, 0x01);
	write_mmi(COPSRC, source_address);
	write_mmi(COPDST, destination_address);
	while (COPSTATR & 0x04);
	write_mmi(COPCOM, 0xFF);
}

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// Coprocessor controller

/**
 * @brief Execute HASH Sequentially (not parallel with other function). 
 *
 * This function triggers a command to execute HASH sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void HASH_sequential(){
	write_mmi(COPCOM, 0x85);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute HASH Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute HASH independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void HASH_independent(){
	write_mmi(COPCOM, 0x05);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Encryption using Key k Sequentially (not parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Encryption using Key k sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_encrypt_k_sequential(){
	write_mmi(COPCOM, 0x86);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Encryption using Key k Independently (enabling parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Encryption using Key k independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_encrypt_k_independent(){
	write_mmi(COPCOM, 0x06);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Encryption Sequentially (not parallel with other function). 
 *
 * This function triggers a command to execute BC3 Encryption sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_encrypt_sequential(){
	write_mmi(COPCOM, 0x89);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Encryption Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute Execute BC3 Encryption independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_encrypt_independent(){
	write_mmi(COPCOM, 0x09);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Decryption using Key k Independently (enabling parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Decryption using Key k independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_decrypt_k_independent(){
	write_mmi(COPCOM, 0x07);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Decryption using Key k Sequentially (not parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Decryption using Key k sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_decrypt_k_sequential(){
	write_mmi(COPCOM, 0x87);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Decryption Independently (enabling parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Decryption independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_decrypt_independent(){
	write_mmi(COPCOM, 0x0A);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute BC3 Decryption Sequentially (not parallel with other function). 
 *
 * This function triggers a command to Execute BC3 Decryption sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void BC3_decrypt_sequential(){
	write_mmi(COPCOM, 0x8A);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Key Generation Sequentially (not parallel with other function). 
 *
 * This function triggers a command to Execute AES Key Generation sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_keygen_sequential(){
	write_mmi(COPCOM, 0x8B);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Decryption Key Generation Sequentially (not parallel with other function). 
 *
 * This function triggers a command to Execute AES Decryption Key Generation sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_dec_keygen_sequential(){
	write_mmi(COPCOM, 0x9C);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Key Generation Independently (enabling parallel with other function). 
 *
 * This function triggers a command to Execute AES Key Generation independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_keygen_independent(){
	write_mmi(COPCOM, 0x0B);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Decryption Key Generation Independently (enabling parallel with other function). 
 *
 * This function triggers a command to Execute AES Decryption Key Generation independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_dec_keygen_independent(){
	write_mmi(COPCOM, 0x1C);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Encryption Sequentially (not parallel with other function). 
 *
 * This function triggers a command to execute AES Encryption sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_encrypt_sequential(){
	write_mmi(COPCOM, 0x9B);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Decryption Sequentially (not parallel with other function). 
 *
 * This function triggers a command to execute AES Decryption sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_decrypt_sequential(){
	write_mmi(COPCOM, 0x9D);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Encryption Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute AES Encryption independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_encrypt_independent(){
	write_mmi(COPCOM, 0x1B);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute AES Decryption Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute AES independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void AES_decrypt_independent(){
	write_mmi(COPCOM, 0x1D);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Addition Sequentially (enabling parallel with other function). 
 *
 * This function triggers a command to execute addition sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Addition_sequential(){
	write_mmi(COPCOM, 0x8C);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Addition Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute addition independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Addition_independent(){
	write_mmi(COPCOM, 0x0C);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Substraction Sequentially (enabling parallel with other function). 
 *
 * This function triggers a command to execute substraction sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Subtraction_sequential(){
	write_mmi(COPCOM, 0x8D);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Substraction Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute substraction independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Subtraction_independent(){
	write_mmi(COPCOM, 0x0D);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Multiplication Sequentially (enabling parallel with other function). 
 *
 * This function triggers a command to execute multiplication sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Multiplication_sequential(){
	write_mmi(COPCOM, 0x8E);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Multiplication Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute multiplication independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Multiplication_independent(){
	write_mmi(COPCOM, 0x0E);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Division Sequentially (enabling parallel with other function). 
 *
 * This function triggers a command to execute division sequentially to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Division_sequential(){
	write_mmi(COPCOM, 0x92);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}

/**
 * @brief Execute Division Independently (enabling parallel with other function). 
 *
 * This function triggers a command to execute division independently to COPCOM.
 * This function waits for the third bit of StatusOut to turn to '1',
 * then completes by giving an idle command to COPCOM.
 *
 * @return None.
 */
void Division_independent(){
	write_mmi(COPCOM, 0x12);
	while (read_mmi(COPSTATR) & 0x04);
	write_mmi(COPCOM, 0xFF);
}