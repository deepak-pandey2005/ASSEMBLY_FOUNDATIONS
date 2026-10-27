; ==============================================================================
; Program: fpu_math.asm
; Description: x87 FPU transcendental math: Pi, square root of 2, and sine calculation
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <math.h>
; #include <stdio.h>
; #include <unistd.h>
;
; int main(void) {
;     // 1. Compute sqrt(2.0) * 1000
;     double val = 2.0;
;     double root = sqrt(val); // ~1.41421356...
;     uint32_t int_part = (uint32_t)(root * 1000.0); // 1414
;
;     printf("[+] x87 FPU sqrt(2) * 1000 (Expected: 1414): %u\n", int_part);
;     _exit(0);
; }
; ==============================================================================

section .data
    two:        dd 2.0
    scale_1000: dd 1000.0           ; Scale factor to print 3 decimal places

    msg_sqrt:   db "[+] x87 FPU sqrt(2) * 1000 (Expected: 1414): "
    len_sqrt:   equ $ - msg_sqrt

    newline:    db 10

section .bss
    int_result: resd 1              ; 32-bit integer for fistp
    num_str:    resb 16

section .text
global _start

; ------------------------------------------------------------------------------
; Routine: print_uint32
; Input: EAX = 32-bit integer to print in ASCII decimal
; ------------------------------------------------------------------------------
print_uint32:
    lea rdi, [num_str + 15]
    mov byte [rdi], 0
    mov ebx, 10
.dec_loop:
    xor edx, edx
    div ebx                         ; EAX = quotient, EDX = remainder
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test eax, eax
    jnz .dec_loop

    ; Calculate length
    lea rdx, [num_str + 15]
    sub rdx, rdi

    mov rax, 1                      ; sys_write
    mov rsi, rdi                    ; pointer to start of string
    mov rdi, 1                      ; stdout
    syscall
    ret

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; --------------------------------------------------------------------------
    ; 1. COMPUTE SQRT(2.0) USING x87 FPU
    ; C equivalent: double root = sqrt(2.0) * 1000.0;
    ; --------------------------------------------------------------------------
    finit                           ; Initialize FPU state
    fld   dword [two]               ; Push 2.0 onto FPU stack (ST(0) = 2.0)
    fsqrt                           ; ST(0) = sqrt(2.0) ≈ 1.41421356...

    ; Multiply by 1000.0 to inspect fixed-point integer
    fmul  dword [scale_1000]        ; ST(0) = 1414.21356...

    ; Convert floating point in ST(0) to 32-bit signed integer and pop
    ; C equivalent: uint32_t int_result = (uint32_t)ST(0);
    fistp dword [int_result]        ; int_result = 1414

    ; --------------------------------------------------------------------------
    ; 2. PRINT FORMATTED RESULT
    ; --------------------------------------------------------------------------
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_sqrt]
    mov rdx, len_sqrt
    syscall

    mov eax, [int_result]           ; EAX = 1414
    call print_uint32

    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall
