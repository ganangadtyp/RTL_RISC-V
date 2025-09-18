#include "hal.h"

int main(){
    coprocessor_init();

    uint16_t data_sent, data_length;
    data_sent = 0x0002;
    data_length = 0x0008;
    
    while(1)
    {
        if(rd_contactless() == 0x26)
        {
            wr_contactless(&data_sent, &data_length);
            rd_contactless();
        }
    }
}
