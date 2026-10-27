; ==============================================================================
; Program: function_call.asm
; Description: Demonstrates writing functions following System V AMD64 ABI
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; int64_t add_three_numbers(int64_t a, int64_t b, int64_t c) {
;     return a + b + c;
; }
;
; int64_t square(int64_t x) {
;     return x * x;
; }
;
; int main(void) {
;     int64_t sum = add_three_numbers(10, 20, 30); // 60
;     int64_t res = square(sum);                  // 3600
;     _exit(0);
; }
; ==============================================================================

section .text
global _start

; ------------------------------------------------------------------------------
; Function: add_three_numbers
; Signature (C): int64_t add_three_numbers(int64_t a, int64_t b, int64_t c)
;
; System V AMD64 ABI Input:
;   RDI = 1st arg: int64_t a
;   RSI = 2nd arg: int64_t b
;   RDX = 3rd arg: int64_t c
; System V AMD64 ABI Return:
;   RAX = return value (a + b + c)
; ------------------------------------------------------------------------------
add_three_numbers:
    mov rax, rdi        ; int64_t rax = a;
    add rax, rsi        ; rax += b;
    add rax, rdx        ; rax += c;
    ret                 ; return rax; (pops return address from stack into RIP)

; ------------------------------------------------------------------------------
; Function: square
; Signature (C): int64_t square(int64_t x)
;
; System V AMD64 ABI Input:
;   RDI = 1st arg: int64_t x
; System V AMD64 ABI Return:
;   RAX = return value (x * x)
; ------------------------------------------------------------------------------
square:
    mov rax, rdi        ; int64_t rax = x;
    imul rax, rdi       ; rax = rax * x;
    ret                 ; return rax;

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; --------------------------------------------------------------------------
    ; 1. Call add_three_numbers(10, 20, 30)
    ; C equivalent: int64_t sum = add_three_numbers(10, 20, 30);
    ; --------------------------------------------------------------------------
    mov rdi, 10         ; 1st argument (a = 10)
    mov rsi, 20         ; 2nd argument (b = 20)
    mov rdx, 30         ; 3rd argument (c = 30)
    call add_three_numbers
    ; Result is returned in RAX (= 60)

    ; --------------------------------------------------------------------------
    ; 2. Call square(sum) -> square(60) = 3600
    ; C equivalent: int64_t res = square(sum);
    ; --------------------------------------------------------------------------
    mov rdi, rax        ; pass previous return value (RAX) as 1st argument (RDI)
    call square
    ; Result is returned in RAX (= 3600)

    ; --------------------------------------------------------------------------
    ; 3. Clean exit
    ; C equivalent: _exit(0);
    ; --------------------------------------------------------------------------
    mov rax, 60         ; rax = SYS_exit (60)
    xor rdi, rdi        ; rdi = 0 (status = 0)
    syscall
