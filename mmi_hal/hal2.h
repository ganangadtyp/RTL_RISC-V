#include <hal.c>

#ifndef HAL_H
#define HAL_H

/************* Address *************/
#define base_address    0x00040000

#define BASE_ADDRESS    0x00040000
#define MMI_00_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x00))
#define MMI_04_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x04))
#define MMI_08_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x08))
#define MMI_0C_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x0C))
#define MMI_10_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x10))
#define MMI_14_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x14))
#define MMI_18_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x18))
#define MMI_1C_ADDR     (*(volatile uint32_t *)(BASE_ADDRESS + 0x1C))

// COP Output
// Crypt Output
// uint32_t *mmi_00 = (uint32_t *) base_address + 0x00;
// // Comm Output
// uint32_t *mmi_04 = (uint32_t *) base_address + 0x04;
// uint32_t *mmi_08 = (uint32_t *) base_address + 0x08;

// // Cop Input
// // Crypt Input
// uint32_t *mmi_0C = (uint32_t *) base_address + 0x0C;
// uint32_t *mmi_10 = (uint32_t *) base_address + 0x10;
// // Comm Input
// uint32_t *mmi_14 = (uint32_t *) base_address + 0x14;
// uint32_t *mmi_18 = (uint32_t *) base_address + 0x18;
// uint32_t *mmi_1C = (uint32_t *) base_address + 0x1C;
/************* End of Address *************/

uint8_t get_COPMISO(void);
uint8_t get_COPSTATR(void);
uint8_t get_COPSTATR2(void);

void set_COPMOSI(uint8_t value);
void set_COPCOM(uint8_t value);
void set_COPTH(uint8_t value);
void set_COPTH2(uint8_t value);
void set_COPSRC(uint8_t value);
void set_COPSRC2(uint8_t value);
void set_COPDST(uint8_t value);
void set_COPDST2(uint8_t value);

#endif