; ==============================================================================
; Program: function_call.asm
; Description: Demonstrates writing functions following System V AMD64 ABI
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .text
global _start

; ------------------------------------------------------------------------------
; Function: add_three_numbers
; Signature (C): int64_t add_three_numbers(int64_t a, int64_t b, int64_t c)
; ABI Input:
;   RDI = a
;   RSI = b
;   RDX = c
; ABI Return:
;   RAX = a + b + c
; ------------------------------------------------------------------------------
add_three_numbers:
    mov rax, rdi        ; rax = a
    add rax, rsi        ; rax = a + b
    add rax, rdx        ; rax = a + b + c
    ret                 ; pop return address into RIP and return to caller

; ------------------------------------------------------------------------------
; Function: square
; Signature (C): int64_t square(int64_t x)
; ABI Input:
;   RDI = x
; ABI Return:
;   RAX = x * x
; ------------------------------------------------------------------------------
square:
    mov rax, rdi
    imul rax, rdi
    ret

; ------------------------------------------------------------------------------
; Program Entry Point
; ------------------------------------------------------------------------------
_start:
    ; 1. Call add_three_numbers(10, 20, 30)
    mov rdi, 10         ; 1st argument
    mov rsi, 20         ; 2nd argument
    mov rdx, 30         ; 3rd argument
    call add_three_numbers
    ; Result is in RAX (= 60)

    ; 2. Call square(rax) -> square(60) = 3600
    mov rdi, rax        ; pass previous result as 1st argument
    call square
    ; RAX is now 3600

    ; 3. Exit with status 0
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; return code 0
    syscall
