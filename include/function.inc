;读软盘扇区 ax为扇区数 cl长度 es:bx指目标
;实模式
ReadSector:
push cx
push ax
push dx
push bx
;扇区数除以18
mov bl,18
div bl
;求柱面号
mov ch,al
shr ch,1
;求磁头号
mov dh,al
and dh,1
;求起始扇区号
inc ah
mov al,ah
xchg cl,al
;最后配置
mov ah,2h
mov dl,0
pop bx
int 13h
pop dx
pop ax
pop cx
ret

;ds:ax字符串地址 dh行(从0开始)
显示字符串:
push ax
push es
push bp
push cx
push bx
push dx
;实际中断需要es:bp串地址
mov bp,ax
mov ax,ds
mov es,ax
mov	cx, 20	; CX = 串长度
mov	ax, 01301h		; AH = 13,  AL = 01h
mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h)
mov dl,0
int	10h			; int 10h
pop dx
pop bx
pop cx
pop bp
pop es
pop ax
ret

;读取序号为ax所在相对与数据区到扇区号在FAT中的条目 结果放在ax中（假定用户知道第一个数据区扇区号为2）
GetNextFat:
push bx
push cx
push dx
push es
mov dx,0;dx在这里作为奇偶标记 为0则是偶数
shr ax,1;快速除以2的同时根据CF的值判断是否偶数
jnb isnoteven;是偶数的话就跳转
mov dx,1
isnoteven:
mov bl,3
mul bl
cmp dx,0
jz isnoteven2
inc ax
isnoteven2:
;接着求所在扇区数
push dx;先储存DX的值（奇偶）
mov dx,0
mov bx,512
div bx;DX装有余数
inc ax;现在为所在扇区数（引导区占用了一个扇区）
mov bx,9000h
mov es,bx
mov bx,0
mov cl,2
call ReadSector
;读取吧骚年
;读取好了就取值
mov bx,ax
add bx,dx
mov word ax,[es:bx-1]
pop dx;取出来
cmp dx,0
jz iseven;是偶数的话就跳转
;如果是奇数的话
shr ax,4
jmp getnextfatret
iseven:
;如果是偶数
and ax,0000111111111111b
getnextfatret:
pop es
pop dx
pop cx
pop bx
ret

CleanScreen:
push ax
push bx
push cx
push dx
mov	ax, 0600h		; AH = 6,  AL = 0h
mov	bx, 0700h		; 黑底白字(BL = 07h)
mov	cx, 0			; 左上角: (0, 0)
mov	dx, 0184fh		; 右下角: (80, 50)
int	10h			; int 10h
pop dx
pop cx
pop bx
pop ax
ret
