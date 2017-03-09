org 400h
[SECTION 16]
[BITS 16]

jmp atm1
atm2: times 20 db 0
atm3: dd 0
atm1:
mov ebx,0
mov di,atm2
mov ax,cs
mov es,ax
mov ds,ax
mov eax,0E820h
mov ecx,20
mov edx,534d4150h
atm4:
int 15h
mov eax,[atm2+16]
cmp eax,1
jne continue
mov eax,[atm2+8]
mov [atm3],eax
continue:
mov eax,0E820h
cmp bx,0
jne atm4
mov eax,[atm3]

jmp atm5
atm6 db 'This is loader.     '
atm5:
mov ax,cs
mov gs,ax
mov ds,ax
mov dh,1
mov ax,atm6
call atm7


jmp atm8
%include "fat12.inc"
%include "address.inc"
%include "pm.inc"
atm9 dw 19
atm10 dw 14
atm11 db 'KERNEL  BIN'
atm12 db 'Can not find KERNEL.'
atm13 db 'find.               '



gdt: atm14 0,0,0
gdtatm15: atm14 0,0fffffh,atm16|atm14_32atm17|atm18_4k
gdtatm19: atm14 0,0fffffh,atm20|atm14_32atm17|atm18_4k
gdtatm21 atm14 0b8000h,0ffffh,atm16|DPL3
gdtatm22_atm32 atm22 atm15,0,0,atm24+DPL0
gdtatm25 atm14 atm26,4095,atm16
gdtatm27 atm14 atm28,1023,atm16|atm18_4k

gdtatm29: equ $-gdt
gdtatm30:	dw gdtatm29-1
		dd loaderatm31+gdt

atm15 equ gdtatm15-gdt
atm19   equ gdtatm19-gdt
atm21 equ gdtatm21-gdt
atm22_atm32 equ gdtatm22_atm32-gdt
atm25 equ gdtatm25-gdt
atm27 equ gdtatm27-gdt
atm33: db 'In protect mode.$'
atm88:db 'Page on.$'

[SECTION atm34]
atm34:
times 1024 db 0
atm35 equ $-atm34

[SECTION atm36]
[BITS 16]
atm8:
xor ah, ah	
xor dl, dl	
int 13h
mov ax,cs
mov ds,ax
atm37:
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,07c00h
cmp word [atm10],0
jz atm38
dec word [atm10]
mov ax,kernelatm39
mov es,ax
mov bx,kernelatm40
mov ax,[atm9]
mov cl,1
call ReadSector

mov si,atm11
mov di,kernelatm40
cld
mov dx,10h

atm41:
cmp dx,0
jz atm42
dec dx
mov cx,11
atm43:
cmp cx,0
jz atm44
dec cx
lodsb
cmp al,byte [es:di]
jnz atm45
inc di
jmp atm43
atm45:
and di,0ffe0h
add di,20h
mov si,atm11
jmp atm41
atm42:
inc word [atm9]
jmp atm37

atm38:
mov ax,atm12
mov dh,2
call atm7
jmp $

atm44:
mov ax,atm13
mov dh,2
call atm7
mov bx,kernelatm40
and di,0ffe0h
add di,1ah
mov ax,[es:di]

atm46:
add ax,31
mov cl,1
call ReadSector
sub ax,31
call GetNextFat
cmp ax,0fffh
jz atm47

add bx,512
jmp atm46
atm47:

mov ax,gs
mov ds,ax
lgdt [gdtatm30]
cli
in al,92h
or al,00000010b
out 92h,al
mov eax,cr0
or eax,1
mov cr0,eax
mov ax,atm15
mov es,ax
jmp dword atm19:(loaderatm31+atm48_32atm17)
%include "function.inc"
%include "protectfunction.inc"
%include "const.inc"

[SECTION 32bit]
[BITS 32]
atm48_32atm17:
mov ax,atm21
mov gs,ax
mov ax,atm15
mov ds,ax
mov eax,loaderatm31+atm33
mov dh,3
call atm19:atm7_atm49+loaderatm31

mov eax,[loaderatm31+atm3]
mov edx,0
mov ebx,4096*1024
div ebx
cmp edx,0
jnz atm50
inc eax
atm50:

push eax
mov ecx,eax
mov ax,atm25
mov es,ax
mov eax,atm28|atm51|atm52|atm53
mov edi,0

atm86:
stosd
add eax,4096
loop atm86

mov ax,atm27
mov es,ax
pop eax
mov ebx,1024
mul ebx

mov ecx,eax
mov eax,atm51|atm52|atm53
mov edi,0

atm87:
stosd
add eax,4096
loop atm87

mov eax,atm26
mov cr3,eax
mov eax,cr0
or eax,80000000h
mov cr0,eax


mov ax,atm15
mov ds,ax
mov ax,atm21
mov gs,ax

mov eax,loaderatm31+atm88
mov dh,4
call atm19:atm7_atm49+loaderatm31


mov ecx,0
mov eax,0
mov ebx,0
mov cx,[kernelatm67+44]
mov ax,[kernelatm67+42]
mov ebx,[kernelatm67+28]
mov edx,0
atm89:

mov esi,[kernelatm67+ebx+edx]
cmp esi,0
je atm91

push eax
mov ax,atm15
mov es,ax
mov edi,[kernelatm67+ebx+edx+8]
push ecx
mov ecx,[kernelatm67+ebx+edx+16]
mov esi,[kernelatm67+ebx+edx+4]
add esi,kernelatm67
mov eax,0
atm90:
mov al,[esi]
stosb
inc esi
loop atm90
pop ecx
pop eax
add edx,eax
atm91: 
loop atm89
jmp atm19:30400h
