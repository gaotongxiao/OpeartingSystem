[BITS 32]
;ds:eax字符串地址 dh行(从0开始) gs存放显示选择子 字符串以$结尾
显示字符串_保护模式:
push bx
push ecx
;计算行数对应在内存中的地址
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
逐个显示:
mov bl,[eax]
cmp bl,'$'
je 退出
mov [gs:ecx],bx
inc eax
add ecx,2
jmp 逐个显示
退出:
pop ecx
pop bx
ret
