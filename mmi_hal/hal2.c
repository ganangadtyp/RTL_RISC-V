// This file contains a few of standard operation of CP and Comm

#include <hal.h>

// void COPMOSI(uint8_t){
//     (*(uint32_t *) (base_address + 0x0C)) = uint32_t((COPTH << 16) + (COPCOM << 8) + (COPMOSI));
// }


// Initialization, give all inputs 0xFF
void coprocessor_init(){
	// COPMOSI 			= 0xFF; //DataIn
	// COPTH 				= 0xFF; //AdThIn
	// COPSRC 				= 0xFF; //AdSrcIn
	// COPDST 				= 0xFF; //AdDstIn
	// COPTH2 				= 0xFF; //AdThIn
	// COPSRC2 			= 0xFF; //AdSrcIn
	// COPDST2				= 0xFF; //AdDstIn
	// COPWR				= 0xFF;
	// COPWREN				= 0xFF;
	// COPRDEN				= 0xFF;
	// COPCRCINIT_1 	    = 0XFF;
	// COPCRCINIT_2 	    = 0XFF;
	// COPCRCI_1 		    = 0XFF;
	// COPCRCI_2 		    = 0XFF;
	// COPCRCEN			= 0XFF;
	// COPCOM 				= 0xFF; //CommandIn
    
    

}

uint8_t get_COPMISO(void){
        return (uint8_t)(MMI_00_ADDR & 0xFF);
}

uint8_t get_COPSTATR(void){
        return (uint8_t)((MMI_00_ADDR >> 8) & 0xFF);
}

uint8_t get_COPSTATR2(void){
        return (uint8_t)((MMI_00_ADDR >> 16) & 0xFF);
}

void set_COPMOSI(uint8_t value) {
    uint32_t reg = MMI_0C_ADDR;
    reg &= ~0x000000FF;
    reg |= ((uint32_t)value & 0xFF);
    MMI_0C_ADDR = reg;
}

void set_COPCOM(uint8_t value) {
    uint32_t reg = MMI_0C_ADDR;
    reg &= ~0x0000FF00;
    reg |= ((uint32_t)value & 0xFF) << 8;
    MMI_0C_ADDR = reg;
}

void set_COPWREN(uint8_t value) {
	COPWREN = value;
	mmi_1C = uint32_t((COPRDEN << 24) + (COPWRLN << 16) + (COPWR << 8) + (COPWREN));
}

void set_COPWR(uint8_t value) {
	COPWR = value;
	mmi_1C = uint32_t((COPRDEN << 24) + (COPWRLN << 16) + (COPWR << 8) + (COPWREN));
}

void set_COPWRLN(uint8_t value) {
	COPWRLN = value;
	mmi_1C = uint32_t((COPRDEN << 24) + (COPWRLN << 16) + (COPWR << 8) + (COPWREN));
}

void set_COPRDEN(uint8_t value) {
	COPRDEN = value;
	mmi_1C = uint32_t((COPRDEN << 24) + (COPWRLN << 16) + (COPWR << 8) + (COPWREN));
}

