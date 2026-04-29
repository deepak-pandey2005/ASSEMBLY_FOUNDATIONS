section .bss
    num resb 3  ; allocates 3 bytes

section .data
    num2 db 3 dup(2)

section .text
global _start

_start:
    mov bl, 1
    mov [num], bl
    mov [num+1], bl
    mov [num+2], bl

    ; exit(0)
    mov eax, 1      ; syscall: sys_exit
    xor ebx, ebx    ; status = 0
    int 0x80