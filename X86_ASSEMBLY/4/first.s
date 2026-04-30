section .data

section .text
global _start

_start:
    mov eax,1
    mov ebx,2
    add eax,ebx
    int 80h