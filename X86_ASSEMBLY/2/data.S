section .data 
        char DB 'A'   ; variable named char with value 'A'
        string1 DB "ABA",0 

section .text

global _start

_start:
        mov bl,[char] ; loads 1 byte from memory location into register char
                      ; bl is the lower 8bits of EBX
        mov eax,1     ;set system call number 1
        int 80h       ; triggers the system call