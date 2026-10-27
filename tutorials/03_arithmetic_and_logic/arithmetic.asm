; ==============================================================================
; Program: arithmetic.asm
; Description: Addition, subtraction, multi-word carry, multiplication and division
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; static int64_t val1 = 100;
; static int64_t val2 = 30;
;
; static int64_t sum;
; static int64_t diff;
; static int64_t product;
; static int64_t quotient;
; static int64_t remainder;
;
; int main(void) {
;     // 1. Basic Addition & Subtraction
;     sum  = val1 + val2;             // 100 + 30 = 130
;     diff = val1 - val2;             // 100 - 30 = 70
;
;     // 2. Multiplication
;     product = val1 * val2;          // 100 * 30 = 3000
;
;     // 3. Division & Remainder
;     quotient  = val1 / val2;        // 100 / 30 = 3
;     remainder = val1 % val2;        // 100 % 30 = 10
;
;     // 4. 128-bit Addition with Carry (__int128 in GCC/Clang)
;     unsigned __int128 big_a = 0xFFFFFFFFFFFFFFFFULL;
;     unsigned __int128 big_b = 1;
;     unsigned __int128 big_sum = big_a + big_b; // lower 64-bit = 0, upper 64-bit carry = 1
;
;     _exit(0);
; }
; ==============================================================================

section .data
    ; C equivalent: static int64_t val1 = 100;
    val1: dq 100
    ; C equivalent: static int64_t val2 = 30;
    val2: dq 30

section .bss
    ; C equivalent: static int64_t sum, diff, product, quotient, remainder;
    sum:       resq 1
    diff:      resq 1
    product:   resq 1
    quotient:  resq 1
    remainder: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. Basic Addition & Subtraction
    ; C equivalent: sum = val1 + val2; diff = val1 - val2;
    ; --------------------------------------------------------------------------
    mov rax, [val1]             ; int64_t rax = val1; (100)
    add rax, [val2]             ; rax += val2;        (100 + 30 = 130)
    mov [sum], rax              ; sum = rax;

    mov rax, [val1]             ; rax = val1;         (100)
    sub rax, [val2]             ; rax -= val2;        (100 - 30 = 70)
    mov [diff], rax             ; diff = rax;

    ; --------------------------------------------------------------------------
    ; 2. Multiplication (IMUL - signed)
    ; C equivalent: product = val1 * val2;
    ; --------------------------------------------------------------------------
    mov rax, [val1]             ; rax = 100
    imul rax, [val2]            ; rax = rax * val2; (100 * 30 = 3000)
    mov [product], rax          ; product = 3000

    ; --------------------------------------------------------------------------
    ; 3. Division (IDIV - signed 64-bit)
    ; C equivalent: quotient = val1 / val2; remainder = val1 % val2;
    ; --------------------------------------------------------------------------
    mov rax, [val1]             ; rax = 100 (dividend lower 64 bits)
    cqo                         ; Convert Quadword to Octoword: sign-extends RAX into RDX:RAX
    mov rbx, [val2]             ; rbx = 30  (divisor)
    idiv rbx                    ; RDX:RAX / RBX -> RAX = quotient (3), RDX = remainder (10)

    mov [quotient], rax         ; quotient = 3
    mov [remainder], rdx        ; remainder = 10

    ; --------------------------------------------------------------------------
    ; 4. Multi-precision Addition with Carry (ADC)
    ; C equivalent: unsigned __int128 lower carry into upper word
    ; --------------------------------------------------------------------------
    mov rax, 0xFFFFFFFFFFFFFFFF ; Max 64-bit unsigned integer (UINT64_MAX)
    add rax, 1                  ; rax = 0; Overflow causes CF (Carry Flag) = 1
    mov rbx, 10
    adc rbx, 0                  ; rbx = rbx + 0 + CF = 10 + 0 + 1 = 11

    ; Clean exit
    ; C equivalent: _exit(0);
    mov rax, 60                 ; rax = SYS_exit (60)
    xor rdi, rdi                ; rdi = 0
    syscall
