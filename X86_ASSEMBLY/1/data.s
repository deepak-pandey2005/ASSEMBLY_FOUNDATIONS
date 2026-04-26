section .data
        num DB 5
        num2 DB 2

section .text
global _start

_start:
        mov ecx ,[num2]
        mov bl ,[num]  
        mov cl ,[num]
        mov eax,1
        int 80h