jmp 加载成功
欢迎信息 db 'In kernel.$'
加载成功:
global _start
_start:
mov eax,kernel物理地址+欢迎信息
mov dh,3
;call 显示字符串_保护模式
jmp $

%include "protectfunction.inc"
%include "address.inc"
