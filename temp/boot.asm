org 07c00h
bootstart:
jmp short atm1
nop
%include "fat12.inc"
%include "address.inc"
atm1:
jmp atm19
atm20 dw 19
atm23 dw 14
atm24 db 'LOADER  BIN'
atm25 db 'Can not find loader.'
atm26 db 'find.               '

atm19:

mov	ax, 0600h		
mov	bx, 0700h		
mov	cx, 0			
mov	dx, 0184fh		
int	10h			
xor ah, ah	
xor dl, dl	
int 13h
mov ax,cs
mov ds,ax
atm27:
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,07c00h
cmp word [atm23],0
jz atm28
dec word [atm23]
mov ax,loaderatm40
mov es,ax
mov bx,loaderatm41
mov ax,[atm20]
mov cl,1
call ReadSector

mov si,atm24
mov di,loaderatm41
cld
mov dx,10h

atm29:
cmp dx,0
jz atm30
dec dx
mov cx,11
atm31:
cmp cx,0
jz atm32
dec cx
lodsb
cmp al,byte [es:di]
jnz atm33
inc di
jmp atm31
atm33:
and di,0ffe0h
add di,20h
mov si,atm24
jmp atm29
atm30:
inc word [atm20]
jmp atm27

atm28:
mov ax,atm25
mov dh,0
call atm34
jmp $

atm32:
mov ax,atm26
mov dh,0
call atm34
mov bx,loaderatm41
and di,0ffe0h
add di,1ah
mov ax,[es:di]

atm35:
add ax,31
mov cl,1
call ReadSector
sub ax,31
call GetNextFat
cmp ax,0fffh
jz atm36

add bx,512
jmp atm35
atm36:
jmp 9000h:400h
%include "function.inc"
times 	510-($-$$)	db	0
dw 0xaa55
