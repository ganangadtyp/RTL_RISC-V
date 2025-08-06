// This file contains a few of standard operation of CP and Comm

#include "hal.h"

uint32_t data_00;
uint32_t data_04;
uint32_t data_08;
uint32_t data_0C;
uint32_t data_10;
uint32_t data_14;
uint32_t data_18;
uint32_t data_1C;

void mmi(uint8_t addr, uint16_t value){
	switch (addr)
	{
	/* ============================ READ ============================ */
		// 0x0004_0000
	case (COPMISO):
		data_00 = *(volatile uint32_t*)(base_address | 0x00);
		value = (data_00 & 0x000000FF);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
    break;
    
    case (COPSTATR):
		data_00 = *(volatile uint32_t*)(base_address | 0x00);
		value = ((data_00 & 0x0000FF00) >> 8);
    break;

    case (COPSTATR2):
		data_00 = *(volatile uint32_t*)(base_address | 0x00);
		value = ((data_00 & 0x00FF0000) >> 16);
    break;

        // 0x0004_0004
	case (COPCRCSTAT):
		data_04 = *(volatile uint32_t*)(base_address | 0x04);
		value = ((data_04 & 0x0000FF00) >> 8);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;
	case (COPCRCO):
		data_04 = *(volatile uint32_t*)(base_address | 0x04);
		value = ((data_04 & 0xFFFF0000) >> 16);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;

		// 0x0004_0008
	case (COPWRSTAT):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		value = (data_04 & 0x000000FF);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;
	case (COPRD):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		value = ((data_04 & 0x0000FF00) >> 8);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;
	case (COPRDSTAT):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		value = ((data_04 & 0x00FF0000) >> 16);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;
	case (COPRDLN):
		data_08 = *(volatile uint32_t*)(base_address | 0x08);
		value = ((data_04 & 0xFF000000) >> 24);
		// (*(uint32_t *) (ram_base_address + 0x10)) = (uint32_t)(data_04); 
	break;
	/* ---------------------------- READ END ---------------------------- */

	/* ============================   WRITE  ============================ */
		// 0x0004_000C
	case (COPMOSI):
		data_0C &= 0xFFFFFF00;
		data_0C |= (value & 0xFF);
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C);
    break;

    case (COPCOM):
	    data_0C &= 0xFFFF00FF;
        data_0C = data_0C | ((value & 0xFF) << 8);
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C);
    break;

    case (COPTH):
        data_0C &= 0x0000FFFF;      // Masking, retain the unbothered data
		data_0C |= (value << 16);   // Shifting right 16, based on the allocation
		(*(uint32_t *) (base_address + 0x0C)) = (uint32_t)(data_0C); 
	break;

    	// 0x0004_0010
	case (COPSRC):
        data_10 &= 0xFFFF0000;                  // Read data, keeping the unbothered data, reseting the old data that wants to be changed
		data_10 |= value;						// For 16 bit data no need to mask // giving the new value to the allocation
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_10);    // sending the data
	break;
    
    case (COPDST):
		data_10 &= 0x0000FFFF;      // Masking, retain the unbothered data
		data_10 |= (value << 16);   // Shifting right 16, based on the allocation
		(*(uint32_t *) (base_address + 0x10)) = (uint32_t)(data_10); 
	break;

        // 0x0004_0014
	case (COPCRCEN):
		data_14 = 0x00000000 | (value & 0x00FF);		// For 8 bit data mask with 0x00FF to only store relevant bit
		(*(uint32_t *) (base_address + 0x14)) = (uint32_t)(data_14); 
	break;

		// 0x0004_0018
	case (COPCRCINIT):
		data_18 &= 0xFFFF0000;                  // Read data, keeping the unbothered data, reseting the old data that wants to be changed
		data_18 |= value;						// For 16 bit data no need to mask // giving the new value to the allocation
		(*(uint32_t *) (base_address + 0x18)) = (uint32_t)(data_18);    // sending the data
	break;
	case (COPCRCIN):
		data_18 &= 0x0000FFFF;      // Masking, retain the unbothered data
		data_18 |= (value << 16);   // Shifting right 16, based on the allocation
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


// Initialization, give all inputs 0xFF
void coprocessor_init(){

	mmi(COPMOSI, 0x00FF);
    mmi(COPCOM, 0x00FF);
    mmi(COPTH, 0xFFFF);
    mmi(COPSRC, 0xFFFF);
    mmi(COPDST, 0xFFFF);
    
    mmi(COPCRCEN, 0x00FF);
	mmi(COPCRCIN, 0xFFFF);
	mmi(COPCRCINIT, 0xFFFF);
	mmi(COPWREN, 0x00FF);
	mmi(COPWR, 0x00FF);
	mmi(COPWRLN, 0x00FF);
	mmi(COPRDEN, 0x00FF);

}