; ==============================================================================
; Program: stack_frame.asm
; Description: Function prolog, epilog, stack alignment, and local stack variables
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; int64_t compute_locals(int64_t x) {
;     int64_t a = x + 5;
;     int64_t b = a * 2;
;     return a + b;
; }
;
; int main(void) {
;     int64_t res = compute_locals(10); // a = 15, b = 30, res = 45
;     _exit(0);
; }
; ==============================================================================

section .text
global _start

; ------------------------------------------------------------------------------
; Function: compute_locals
; Signature (C): int64_t compute_locals(int64_t x)
;
; Stack Frame Layout:
;   [rbp]      = Saved Caller's RBP
;   [rbp - 8]  = local variable int64_t a
;   [rbp - 16] = local variable int64_t b
; ------------------------------------------------------------------------------
compute_locals:
    ; === PROLOG (Setting up the stack frame) ===
    push rbp                ; push old frame pointer to preserve caller's frame
    mov  rbp, rsp           ; rbp now points to the base of our new stack frame
    sub  rsp, 16            ; allocate 16 bytes for local variables (maintains 16-byte stack alignment!)

    ; Local variable 'a' stored at [rbp - 8]
    ; C equivalent: int64_t a = x + 5;
    mov  rax, rdi           ; rax = x
    add  rax, 5             ; rax = x + 5
    mov  [rbp - 8], rax     ; a = x + 5

    ; Local variable 'b' stored at [rbp - 16]
    ; C equivalent: int64_t b = a * 2;
    mov  rax, [rbp - 8]     ; rax = a
    shl  rax, 1             ; rax = a * 2 (fast bit-shift multiply)
    mov  [rbp - 16], rax    ; b = a * 2

    ; Compute return value: a + b
    ; C equivalent: return a + b;
    mov  rax, [rbp - 8]     ; rax = a
    add  rax, [rbp - 16]    ; rax = a + b (return value stored in rax)

    ; === EPILOG (Tearing down the stack frame) ===
    mov  rsp, rbp           ; deallocate local stack variables
    pop  rbp                ; restore caller's frame pointer
    ret                     ; return to caller (pops return RIP from stack)

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; --------------------------------------------------------------------------
    ; Call compute_locals(10)
    ; C equivalent: int64_t res = compute_locals(10);
    ; Expected: a = 15, b = 30, return = 45
    ; --------------------------------------------------------------------------
    mov  rdi, 10            ; 1st argument (x = 10)
    call compute_locals     ; invoke function; RAX receives 45

    ; Exit
    ; C equivalent: _exit(0);
    mov  rax, 60            ; rax = SYS_exit (60)
    xor  rdi, rdi           ; status = 0
    syscall
