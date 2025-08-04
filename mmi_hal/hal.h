#include <stdint.h>

#ifndef HAL_H
#define HAL_H

/************* Address *************/
#define base_address   	0x00040000
#define ram_base_address   	0x00050000

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

extern uint32_t data_0C;
extern uint32_t data_10;
extern uint32_t data_14;
extern uint32_t data_18;
extern uint32_t data_1C;

// extern uint16_t CRCSTAT;
// extern uint16_t CRCO;

extern void coprocessor_init();
extern void mmi(uint8_t addr, uint16_t value);

#endif  // HAL_H
