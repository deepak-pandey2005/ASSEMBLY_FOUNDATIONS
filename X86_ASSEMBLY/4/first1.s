section .data

section .text
global _start

_start:
    MOV al ,0b1010101
    MOV bl ,0b1111111
    add eax , ebx
    adc ah , 0
    int 80h
