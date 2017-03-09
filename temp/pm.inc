































































































































































































atm14_32atm17		EQU	4000h	
atm18_4k	EQU	8000h	

DPL0		EQU	  00h	
DPL1		EQU	  20h	
DPL2		EQU	  40h	
DPL3		EQU	  60h	



atm56		EQU	90h	
atm16		EQU	92h	
atm57		EQU	93h	
atm20		EQU	98h	
atm58		EQU	9Ah	
atm59		EQU	9Ch	
atm60		EQU	9Eh	



atm61		EQU	  82h	
LDT			EQU       82h
atm62	EQU	  85h	
TSS	EQU	  89h	
atm24	EQU	  8Ch	
atm63	EQU	  8Eh	
atm64	EQU	  8Fh	






















RPL0		EQU	0	
RPL1		EQU	1	
RPL2		EQU	2	
RPL3		EQU	3	

TIG		EQU	0	
TIL		EQU	4	






atm51		EQU	1	
atm65		EQU	0	
atm53		EQU	2	
atm66		EQU	0	
atm52		EQU	4	







































%macro atm14 3
	dw	%2 & 0FFFFh				
	dw	%1 & 0FFFFh				
	db	(%1 >> 16) & 0FFh			
	dw	((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)	
	db	(%1 >> 24) & 0FFh			
%endmacro 







%macro atm22 4
	dw	(%2 & 0FFFFh)				
	dw	%1					
	dw	(%3 & 1Fh) | ((%4 << 8) & 0FF00h)	
	dw	((%2 >> 16) & 0FFFFh)			
%endmacro 

