; ==============================================================================
; Program: fpu_math.asm
; Description: x87 FPU transcendental math: Pi, square root of 2, and sine calculation
; Architecture: x86-64 Linux
; Assembler: NASM
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

_start:
    ; --------------------------------------------------------------------------
    ; 1. COMPUTE SQRT(2.0) USING x87 FPU
    ; --------------------------------------------------------------------------
    finit                           ; Initialize FPU state
    fld   dword [two]               ; Push 2.0 onto FPU stack (ST(0) = 2.0)
    fsqrt                           ; ST(0) = sqrt(2.0) ≈ 1.41421356...

    ; Multiply by 1000.0 to inspect fixed-point integer
    fmul  dword [scale_1000]        ; ST(0) = 1414.21356...
    fistp dword [int_result]        ; Round to integer and store in int_result, pop ST(0)

    ; Print prefix
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_sqrt]
    mov rdx, len_sqrt
    syscall

    ; Print calculated integer (should be 1414)
    mov eax, [int_result]
    call print_uint32

    ; Print newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    ; Clean Exit
    mov rax, 60
    xor rdi, rdi
    syscall
