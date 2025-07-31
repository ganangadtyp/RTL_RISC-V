#include <stdint.h>

#ifndef HAL_H
#define HAL_H

/************* Address *************/
#define base_address    0x00040000

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


#endif