; ==============================================================================
; Program: array_sum.asm
; Description: Demonstrates rep movsb (block memory copy) and array transformations
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    src_data: db 10, 20, 30, 40, 50, 60, 70, 80
    src_len:  equ $ - src_data

section .bss
    dest_data: resb 8
    accum:     resq 1

section .text
global _start

_start:
    ; 1. Fast block copy using REP MOVSB (like memcpy)
    cld                         ; DF = 0 (forward)
    lea rsi, [src_data]         ; Source pointer
    lea rdi, [dest_data]        ; Destination pointer
    mov rcx, src_len            ; Byte count = 8
    rep movsb                   ; Copy rcx bytes from [rsi] to [rdi]

    ; 2. Sum elements of the copied array
    xor rax, rax                ; sum = 0
    xor rsi, rsi                ; index = 0

.sum_loop:
    cmp rsi, src_len
    jge .done_sum
    movzx rbx, byte [dest_data + rsi] ; movzx: zero-extend byte to 64-bit
    add rax, rbx
    inc rsi
    jmp .sum_loop

.done_sum:
    mov [accum], rax            ; rax = 10+20+30+40+50+60+70+80 = 360

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
