; ==============================================================================
; Program: loop_sum.asm
; Description: Compute sum of 1..N and iterate through an integer array
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; static int64_t array[5] = {10, 20, 30, 40, 50};
; static int64_t total;
;
; int main(void) {
;     // 1. Calculate sum of 1 to 10
;     int64_t sum1 = 0;
;     for (int64_t i = 1; i <= 10; i++) {
;         sum1 += i;
;     }
;     // sum1 is now 55 (1+2+3+4+5+6+7+8+9+10)
;
;     // 2. Iterate through array and sum elements
;     int64_t sum2 = 0;
;     for (size_t rsi = 0; rsi < 5; rsi++) {
;         sum2 += array[rsi];
;     }
;     total = sum2; // 150
;
;     _exit(0);
; }
; ==============================================================================

section .data
    array: dq 10, 20, 30, 40, 50
    array_len: equ 5

section .bss
    total: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. Calculate sum of 1 to 10
    ; C equivalent:
    ;   int64_t sum = 0;
    ;   for (int64_t i = 1; i <= 10; i++) { sum += i; }
    ; --------------------------------------------------------------------------
    xor rax, rax            ; int64_t sum = 0 (accumulator in rax)
    mov rcx, 1              ; int64_t i = 1   (loop counter in rcx)

.for_loop:
    cmp rcx, 10             ; if (i > 10) break;
    jg .loop_end
    add rax, rcx            ; sum += i;
    inc rcx                 ; i++;
    jmp .for_loop

.loop_end:
    ; RAX is now 55 (1+2+3+4+5+6+7+8+9+10)

    ; --------------------------------------------------------------------------
    ; 2. Iterate through array and sum elements
    ; C equivalent:
    ;   int64_t total_sum = 0;
    ;   for (size_t i = 0; i < array_len; i++) { total_sum += array[i]; }
    ;   total = total_sum;
    ; --------------------------------------------------------------------------
    xor r8, r8              ; int64_t total_sum = 0 (accumulator in r8)
    xor rsi, rsi            ; size_t i = 0          (index in rsi)

.array_loop:
    cmp rsi, array_len      ; if (i >= array_len) break;
    jge .done_array

    add r8, [array + rsi*8] ; total_sum += array[i];
    inc rsi                 ; i++;
    jmp .array_loop

.done_array:
    mov [total], r8         ; total = total_sum (150)

    ; Exit with status 0
    ; C equivalent: _exit(0);
    mov rax, 60             ; rax = SYS_exit (60)
    xor rdi, rdi            ; status = 0
    syscall
