org 07c00h
bootstart:
jmp short 包含数据的开始
nop
%include "fat12.inc"
%include "address.inc"
包含数据的开始:
jmp 开始
寻找扇区数 dw 19
寻找次数 dw 14;寻找次数
加载程序名称 db 'LOADER  BIN'
不能找到文件 db 'Can not find loader.'
已经找到文件 db 'find.               '

开始:
;清屏
mov	ax, 0600h		; AH = 6,  AL = 0h
mov	bx, 0700h		; 黑底白字(BL = 07h)
mov	cx, 0			; 左上角: (0, 0)
mov	dx, 0184fh		; 右下角: (80, 50)
int	10h			; int 10h
xor ah, ah	; ┓
xor dl, dl	; ┣ 软驱复位
int 13h
mov ax,cs
mov ds,ax
真正的开始:
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,07c00h
cmp word [寻找次数],0
jz 寻找失败
dec word [寻找次数]
mov ax,loader基址
mov es,ax
mov bx,loader偏移
mov ax,[寻找扇区数]
mov cl,1
call ReadSector

mov si,加载程序名称
mov di,loader偏移
cld
mov dx,10h

搜索:
cmp dx,0
jz 跳入下一扇区
dec dx
mov cx,11
检测是否为加载程序:
cmp cx,0
jz 找到文件
dec cx
lodsb
cmp al,byte [es:di]
jnz 找不到文件
inc di
jmp 检测是否为加载程序
找不到文件:
and di,0ffe0h
add di,20h
mov si,加载程序名称
jmp 搜索
跳入下一扇区:
inc word [寻找扇区数]
jmp 真正的开始

寻找失败:
mov ax,不能找到文件
mov dh,0
call 显示字符串
jmp $

找到文件:
mov ax,已经找到文件
mov dh,0
call 显示字符串
mov bx,loader偏移
and di,0ffe0h
add di,1ah
mov ax,[es:di]
;首先把数据区读入
读取数据区:
add ax,31;此时ax为数据区的真正扇区号
mov cl,1
call ReadSector
sub ax,31
call GetNextFat
cmp ax,0fffh
jz 程序加载完毕
;否则
add bx,512
jmp 读取数据区
程序加载完毕:
jmp 9000h:400h
%include "function.inc"
times 	510-($-$$)	db	0
dw 0xaa55
