# Simple DOS HDD imager

This tool simply sends the contents of the hard drive over serial (COM1).

It fetches the drive geometry using AH=0x08 INT 13H, then reads it sector-by-sector using AH=0x02 INT 13H (CHS mode), and transmits it over COM1.

### Defaults:

Sector Size: 512 bytes

Baud: 115.2 kb/s

Comport: COM1 (0x3f8)

Drive to image: 0 (C:) (DL = 0x80)

##### Defaults can be changed in `imager.asm`

### To compile:

```
nasm -f bin -o imager.com imager.asm
```
