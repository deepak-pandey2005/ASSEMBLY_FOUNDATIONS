; ==============================================================================
; Program: hello_64.asm
; Description: 64-bit Linux "Hello, World!" with step-by-step register breakdown.
; Architecture: x86-64 (AMD64) Linux
; Assembler: NASM (Intel syntax)
;
; How to build:
;   nasm -f elf64 -g -F dwarf hello_64.asm -o hello_64.o
;   ld hello_64.o -o hello_64
;   ./hello_64
; ==============================================================================

section .data
    ; String literal in memory.
    ; 10 is the ASCII newline character ('\n').
    msg: db "Hello, Assembly Foundations!", 10

    ; Calculate length automatically using NASM's current address symbol ($)
    ; ($ - msg) = current offset minus start of msg = length in bytes.
    msg_len: equ $ - msg

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. WRITE TO STDOUT
    ; System V AMD64 syscall calling convention:
    ;   RAX = syscall number (1 is sys_write)
    ;   RDI = 1st arg: file descriptor (1 is stdout)
    ;   RSI = 2nd arg: pointer to buffer
    ;   RDX = 3rd arg: count of bytes to write
    ; --------------------------------------------------------------------------
    mov rax, 1              ; syscall: sys_write
    mov rdi, 1              ; fd: stdout
    mov rsi, msg            ; pointer to the string
    mov rdx, msg_len        ; length of the string
    syscall                 ; trigger kernel context switch

    ; --------------------------------------------------------------------------
    ; 2. EXIT CLEANLY
    ;   RAX = syscall number (60 is sys_exit)
    ;   RDI = 1st arg: status code (0 is SUCCESS)
    ; --------------------------------------------------------------------------
    mov rax, 60             ; syscall: sys_exit
    xor rdi, rdi            ; exit code = 0 (xor reg, reg is faster & smaller than mov reg, 0)
    syscall                 ; invoke kernel to terminate process
