; ==============================================================================
; Program: branches.asm
; Description: Implementation of an if-else ladder in x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
;
; static int64_t test_val = -25;
;
; int main(void) {
;     const char *msg;
;     size_t len;
;
;     if (test_val < 0) {
;         msg = "Number is negative\n";
;         len = 19;
;     } else if (test_val > 0) {
;         msg = "Number is positive\n";
;         len = 19;
;     } else {
;         msg = "Number is zero\n";
;         len = 15;
;     }
;
;     write(STDOUT_FILENO, msg, len);
;     _exit(0);
; }
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
    ; --------------------------------------------------------------------------
    ; If-Else Ladder:
    ; C equivalent:
    ;   if (test_val < 0) goto is_negative;
    ;   else if (test_val > 0) goto is_positive;
    ;   else goto is_zero;
    ; --------------------------------------------------------------------------
    mov rax, [test_val]     ; int64_t rax = test_val; (-25)

    ; Compare rax with 0 (sets RFLAGS: ZF, SF, OF)
    cmp rax, 0
    jl  .is_negative        ; if (rax < 0) signed jump
    jg  .is_positive        ; else if (rax > 0) signed jump
    ; Fall-through if (rax == 0)

.is_zero:
    ; C equivalent: msg = msg_zero; len = len_zero;
    mov rsi, msg_zero       ; buffer pointer
    mov rdx, len_zero       ; length
    jmp .print

.is_positive:
    ; C equivalent: msg = msg_pos; len = len_pos;
    mov rsi, msg_pos        ; buffer pointer
    mov rdx, len_pos        ; length
    jmp .print

.is_negative:
    ; C equivalent: msg = msg_neg; len = len_neg;
    mov rsi, msg_neg        ; buffer pointer
    mov rdx, len_neg        ; length
    jmp .print

.print:
    ; --------------------------------------------------------------------------
    ; C equivalent: write(1, msg, len);
    ; --------------------------------------------------------------------------
    mov rax, 1              ; rax = SYS_write (1)
    mov rdi, 1              ; rdi = STDOUT_FILENO (1)
    syscall

    ; --------------------------------------------------------------------------
    ; C equivalent: _exit(0);
    ; --------------------------------------------------------------------------
    mov rax, 60             ; rax = SYS_exit (60)
    xor rdi, rdi            ; rdi = 0
    syscall
