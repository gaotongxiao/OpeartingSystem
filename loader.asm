org 400h
[SECTION 16]
[BITS 16]
;;;;;;;;;;;获取内存大小
jmp 获取内存大小
内存结构: times 20 db 0
内存大小: dd 0
获取内存大小:
mov ebx,0
mov di,内存结构
mov ax,cs
mov es,ax
mov ds,ax
mov eax,0E820h
mov ecx,20
mov edx,534d4150h
重复获取:
int 15h
mov eax,[内存结构+16]
cmp eax,1
jne continue
mov eax,[内存结构+8]
mov [内存大小],eax
continue:
mov eax,0E820h
cmp bx,0
jne 重复获取
mov eax,[内存大小]
;;;;;;;;;;;;;;;开始
jmp 开始
欢迎信息 db 'This is loader.     '
开始:
mov ax,cs
mov gs,ax;保存cs地址
mov ds,ax
mov dh,1
mov ax,欢迎信息
call 显示字符串

;jmp dt
jmp 加载内核
%include "fat12.inc"
%include "address.inc"
%include "pm.inc"
寻找扇区数 dw 19
寻找次数 dw 14;寻找次数
加载程序名称 db 'KERNEL  BIN'
不能找到文件 db 'Can not find KERNEL.'
已经找到文件 db 'find.               '

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GDT时间
gdt: 段 0,0,0
gdt全内存读写: 段 0,0fffffh,可读写|段_32位|段界限粒度_4k
gdt全内存代码: 段 0,0fffffh,可执行|段_32位|段界限粒度_4k
gdt显示 段 0b8000h,0ffffh,可读写|DPL3
gdt门_函数 门 全内存读写,0,0,调用门+DPL0
gdt页目录 段 页目录地址,4095,可读写
gdt页目录表 段 页目录表地址,1023,可读写|段界限粒度_4k

gdt长度: equ $-gdt
gdt基地址:	dw gdt长度-1
		dd loader物理基址+gdt

全内存读写 equ gdt全内存读写-gdt
全内存代码   equ gdt全内存代码-gdt
显示 equ gdt显示-gdt
门_函数 equ gdt门_函数-gdt
页目录 equ gdt页目录-gdt
页目录表 equ gdt页目录表-gdt
成功进入保护模式: db 'In protect mode.$'
成功开启分页:db 'Page on.$'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[SECTION 堆栈]
堆栈:
times 1024 db 0
堆栈顶 equ $-堆栈

[SECTION 工作]
[BITS 16]
加载内核:
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
mov ax,kernel基址
mov es,ax
mov bx,kernel偏移
mov ax,[寻找扇区数]
mov cl,1
call ReadSector

mov si,加载程序名称
mov di,kernel偏移
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
mov dh,2
call 显示字符串
jmp $

找到文件:
mov ax,已经找到文件
mov dh,2
call 显示字符串
mov bx,kernel偏移
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
;开始进入保护模式
mov ax,gs
mov ds,ax
lgdt [gdt基地址]
cli
in al,92h
or al,00000010b
out 92h,al
mov eax,cr0
or eax,1
mov cr0,eax
mov ax,全内存读写
mov es,ax
jmp dword 全内存代码:(loader物理基址+代码_32位)
%include "function.inc"
%include "protectfunction.inc"
%include "const.inc"

[SECTION 32bit]
[BITS 32]
代码_32位:
mov ax,显示
mov gs,ax
mov ax,全内存读写
mov ds,ax
mov eax,loader物理基址+成功进入保护模式
mov dh,3
call 全内存代码:显示字符串_保护模式+loader物理基址
;启动分页机制*(有用么？？？）
mov eax,[loader物理基址+内存大小]
mov edx,0
mov ebx,4096*1024
div ebx
cmp edx,0
jnz 无余数
inc eax
无余数:
;开始定义页目录
push eax
mov ecx,eax
mov ax,页目录
mov es,ax
mov eax,页目录表地址|页存在|用户|可读写可执行
mov edi,0

初始化页目录:
stosd
add eax,4096
loop 初始化页目录

mov ax,页目录表
mov es,ax
pop eax
mov ebx,1024
mul ebx
;此时eax为页目录表项
mov ecx,eax
mov eax,页存在|用户|可读写可执行
mov edi,0

初始化页目录表:
stosd
add eax,4096
loop 初始化页目录表

mov eax,页目录地址
mov cr3,eax
mov eax,cr0
or eax,80000000h
mov cr0,eax

;开启完毕
mov ax,全内存读写
mov ds,ax
mov ax,显示
mov gs,ax

mov eax,loader物理基址+成功开启分页
mov dh,4
call 全内存代码:显示字符串_保护模式+loader物理基址

;;;;;;;;;;;;;开始读取内核elf
mov ecx,0
mov eax,0
mov ebx,0
mov cx,[kernel物理地址+44];program header 个数
mov ax,[kernel物理地址+42];program header table条目大小
mov ebx,[kernel物理地址+28];program header table偏移
mov edx,0;存放地址
读取程序头表:
;首先判断该段是否无用段
mov esi,[kernel物理地址+ebx+edx]
cmp esi,0
je 该段是无用段
;定位程序头表中的信息
push eax
mov ax,全内存读写
mov es,ax
mov edi,[kernel物理地址+ebx+edx+8];存放地址
push ecx
mov ecx,[kernel物理地址+ebx+edx+16];文件长度
mov esi,[kernel物理地址+ebx+edx+4];段的第一个字节在文件中的偏移
add esi,kernel物理地址
mov eax,0
转移地址:
mov al,[esi]
stosb
inc esi
loop 转移地址
pop ecx
pop eax
add edx,eax
该段是无用段: 
loop 读取程序头表
jmp 全内存代码:30400h
