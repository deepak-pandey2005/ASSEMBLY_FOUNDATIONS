; ==============================================================================
; Program: array_sum.asm
; Description: Demonstrates rep movsb (block memory copy) and array transformations
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <string.h>
; #include <stdint.h>
; #include <unistd.h>
;
; static const uint8_t src_data[8] = {10, 20, 30, 40, 50, 60, 70, 80};
; static uint8_t       dest_data[8];
; static uint64_t      accum;
;
; int main(void) {
;     // 1. Fast block copy using memcpy (REP MOVSB)
;     memcpy(dest_data, src_data, sizeof(src_data));
;
;     // 2. Sum elements of the copied array
;     uint64_t sum = 0;
;     for (size_t i = 0; i < sizeof(src_data); i++) {
;         sum += (uint64_t)dest_data[i];
;     }
;     accum = sum; // 10+20+30+40+50+60+70+80 = 360
;
;     _exit(0);
; }
; ==============================================================================

section .data
    ; C equivalent: static const uint8_t src_data[8] = {10, 20, 30, 40, 50, 60, 70, 80};
    src_data: db 10, 20, 30, 40, 50, 60, 70, 80
    src_len:  equ $ - src_data

section .bss
    ; C equivalent: static uint8_t dest_data[8];
    dest_data: resb 8
    ; C equivalent: static uint64_t accum;
    accum:     resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. Fast block copy using REP MOVSB
    ; C equivalent: memcpy(dest_data, src_data, 8);
    ; --------------------------------------------------------------------------
    cld                         ; Clear Direction Flag (DF = 0): increment pointers
    lea rsi, [src_data]         ; rsi = const void *src
    lea rdi, [dest_data]        ; rdi = void *dest
    mov rcx, src_len            ; rcx = size_t n (8 bytes)
    rep movsb                   ; while (rcx--) *rdi++ = *rsi++;

    ; --------------------------------------------------------------------------
    ; 2. Sum elements of the copied array
    ; C equivalent:
    ;   uint64_t sum = 0;
    ;   for (size_t rsi = 0; rsi < src_len; rsi++) { sum += dest_data[rsi]; }
    ;   accum = sum;
    ; --------------------------------------------------------------------------
    xor rax, rax                ; uint64_t sum = 0 (accumulator in rax)
    xor rsi, rsi                ; size_t i = 0     (index in rsi)

.sum_loop:
    cmp rsi, src_len            ; if (i >= src_len) goto done_sum;
    jge .done_sum
    movzx rbx, byte [dest_data + rsi] ; uint64_t val = (uint64_t)dest_data[i]; (zero-extended)
    add rax, rbx                ; sum += val;
    inc rsi                     ; i++;
    jmp .sum_loop

.done_sum:
    mov [accum], rax            ; accum = sum (360)

    ; Clean exit
    ; C equivalent: _exit(0);
    mov rax, 60                 ; rax = SYS_exit (60)
    xor rdi, rdi                ; status = 0
    syscall
