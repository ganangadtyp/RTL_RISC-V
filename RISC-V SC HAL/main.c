#include "hal.h"

int main(){
    uint16_t STATR;
	uint16_t MISO;
    
    coprocessor_init();

    // Adder using accelerator

    // tulis nilai a pada address shd mem 0x009F
    // AdDestIn = 0x009F
    mmi(COPDST, 0x009F);
    mmi(COPMOSI, 0x0005);
    mmi(COPCOM, 0x0083);
    mmi(COPCOM, 0x00FF);
    // DataIn = 0x05
    // ComandIn = 0x83 //0x83 adalah instruction untuk write
    // ComandIn = 0xFF

    // // tulis nilai b pada address shd mem 0x00BF
    // AdDestIn = 0x00BF
    mmi(COPDST, 0x00BF);
    // DataIn = 0x05
    mmi(COPMOSI, 0x0005);
    // ComandIn = 0x83
    mmi(COPCOM, 0x0083);
    // ComandIn = 0xFF
    mmi(COPCOM, 0x00FF);

    // //Perintah jalankan addition
    // ComandIn = 0x8C // instruction untuk addition
    mmi(COPCOM, 0x008C);
    // ComandIn = 0xFF
    mmi(COPCOM, 0x00FF);

    // //baca hasil
    // AdSrcIn = 0x01D7
    mmi(COPSRC, 0x01D7);
    // CommandIn = 0x82
    mmi(COPCOM, 0x0082);
    // //jangan tulis perintah jika ins buffer penuh
    // //wait sampai dengan StatusOut bit ketiga tidak bernilai 1 yang menandakan Ins Buffer penuh
    // if bit ke-3 statusout == 0
    //0000_0100
    //     continue
    // else
    //     wait
    do
    {
       mmi(COPSTATR, STATR); 
    } while ((STATR & (1 << 2)) != 0);
    

    // //kemudian lanjutkan
    // CommandIn = 0xFF
    mmi(COPCOM, 0x00FF);

    // //wait sampai statusOut bit ke-4 bernilai 1, data valid untuk dibaca
    // if bit ke-4 statusout == 1
    //0000_1000
    //     continue
    // else
    //     wait
    do
    {
        mmi(COPSTATR, STATR);
    } while ((STATR & (1 << 3)) == 0);

    // hasil = DataOut
    mmi(COPMISO, MISO);

    // CommandIn = 0x00 //instruksi untuk menandakan DataOut telah dibaca
    mmi(COPCOM, 0x0000);

    while(1);
}