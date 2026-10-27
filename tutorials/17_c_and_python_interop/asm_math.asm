; ==============================================================================
; Program: asm_math.asm
; Description: Native math kernel exportable to C and Python via System V ABI
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Declarations & Implementations:
; ------------------------------------------------------------------------------
; #include <stdint.h>
;
; int64_t fast_multiply_add(int64_t a, int64_t b, int64_t c) {
;     return (a * b) + c;
; }
;
; int64_t fast_factorial(int64_t n) {
;     int64_t result = 1;
;     while (n > 1) {
;         result *= n;
;         n--;
;     }
;     return result;
; }
; ==============================================================================

section .text
global fast_multiply_add
global fast_factorial

; ------------------------------------------------------------------------------
; int64_t fast_multiply_add(int64_t a, int64_t b, int64_t c)
; Computes: (a * b) + c
;
; System V AMD64 Calling Convention:
;   RDI = 1st arg: int64_t a
;   RSI = 2nd arg: int64_t b
;   RDX = 3rd arg: int64_t c
; Returns in RAX
; ------------------------------------------------------------------------------
fast_multiply_add:
    mov rax, rdi        ; int64_t rax = a;
    imul rax, rsi       ; rax = a * b;
    add rax, rdx        ; rax = (a * b) + c;
    ret                 ; return rax;

; ------------------------------------------------------------------------------
; int64_t fast_factorial(int64_t n)
; Computes n! iteratively
;
; System V AMD64 Calling Convention:
;   RDI = 1st arg: int64_t n
; Returns in RAX
; ------------------------------------------------------------------------------
fast_factorial:
    mov rax, 1          ; int64_t result = 1;
    cmp rdi, 1          ; if (n <= 1) return result;
    jle .done

.loop:
    imul rax, rdi       ; result *= n;
    dec rdi             ; n--;
    cmp rdi, 1          ; while (n > 1)
    jg .loop

.done:
    ret                 ; return result;
