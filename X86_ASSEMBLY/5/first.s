section .data

section .text
global _start

_start:
        MOV al ,0xff
        MOV bl ,3
        mul bl
        int 80h