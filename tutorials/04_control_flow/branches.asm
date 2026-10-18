; ==============================================================================
; Program: branches.asm
; Description: Implementation of an if-else ladder in x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    msg_pos:  db "Number is positive", 10
    len_pos:  equ $ - msg_pos

    msg_neg:  db "Number is negative", 10
    len_neg:  equ $ - msg_neg

    msg_zero: db "Number is zero", 10
    len_zero: equ $ - msg_zero

    test_val: dq -25

section .text
global _start

_start:
    mov rax, [test_val]

    ; Compare rax with 0
    cmp rax, 0
    jl  .is_negative        ; Jump if Signed Less than 0
    jg  .is_positive        ; Jump if Signed Greater than 0
    ; Fall-through if Equal to 0

.is_zero:
    mov rsi, msg_zero
    mov rdx, len_zero
    jmp .print

.is_positive:
    mov rsi, msg_pos
    mov rdx, len_pos
    jmp .print

.is_negative:
    mov rsi, msg_neg
    mov rdx, len_neg
    jmp .print

.print:
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
