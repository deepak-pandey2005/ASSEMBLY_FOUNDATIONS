; ==============================================================================
; Program: data_sections.asm
; Description: Demonstrates data transfer across .rodata, .data, and .bss
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .rodata
    greeting: db "Assembler initialized", 10, 0
    greeting_len: equ $ - greeting

section .data
    ; Initialized data variables
    init_val: dq 0x1122334455667788
    status_byte: db 1

section .bss
    ; Uninitialized buffer reserved at runtime
    buffer: resb 64
    saved_val: resq 1

section .text
global _start

_start:
    ; Print greeting from .rodata
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, greeting           ; buffer in .rodata
    mov rdx, greeting_len       ; byte count
    syscall

    ; Load from .data into register
    mov rax, [init_val]

    ; Store into .bss
    mov [saved_val], rax

    ; Store bytes into buffer array in .bss
    mov byte [buffer], 'A'
    mov byte [buffer + 1], 'B'
    mov byte [buffer + 2], 10

    ; Print buffer from .bss
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, buffer
    mov rdx, 3                  ; 3 bytes
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
