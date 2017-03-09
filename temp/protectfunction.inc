[BITS 32]

atm7_atm49:
push bx
push ecx

mov bl,80
push eax
push edx
mov eax,0
mov al,dh
mul bl
mov bx,2
mul bx
mov ecx,0
mov cx,ax
pop edx
pop eax
mov bh,0fh
atm54:
mov bl,[eax]
cmp bl,'$'
je atm55
mov [gs:ecx],bx
inc eax
add ecx,2
jmp atm54
atm55:
pop ecx
pop bx
ret
