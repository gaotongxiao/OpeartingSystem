loader基址 equ 9000h
loader偏移 equ 400h
loader物理地址 equ loader基址*10h+loader偏移
loader物理基址 equ loader基址*10h

kernel基址 equ 8000h
kernel偏移 equ 0h
kernel物理地址 equ kernel基址*10h+kernel偏移
