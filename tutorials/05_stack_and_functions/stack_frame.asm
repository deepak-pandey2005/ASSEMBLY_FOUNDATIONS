; ==============================================================================
; Program: stack_frame.asm
; Description: Function prolog, epilog, stack alignment, and local stack variables
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .text
global _start

; ------------------------------------------------------------------------------
; Function: compute_locals
; Demonstrates stack frame creation:
;   int64_t compute_locals(int64_t x) {
;       int64_t a = x + 5;
;       int64_t b = a * 2;
;       return a + b;
;   }
; ------------------------------------------------------------------------------
compute_locals:
    ; === PROLOG ===
    push rbp                ; Save previous frame pointer
    mov  rbp, rsp           ; Establish new frame pointer
    sub  rsp, 16            ; Allocate 16 bytes for local variables (maintains 16-byte alignment!)

    ; Local variable 'a' stored at [rbp - 8]
    mov  rax, rdi           ; rax = x
    add  rax, 5             ; rax = x + 5
    mov  [rbp - 8], rax     ; a = rax

    ; Local variable 'b' stored at [rbp - 16]
    mov  rax, [rbp - 8]     ; rax = a
    shl  rax, 1             ; rax = a * 2
    mov  [rbp - 16], rax    ; b = rax

    ; Compute return value: a + b
    mov  rax, [rbp - 8]
    add  rax, [rbp - 16]

    ; === EPILOG ===
    mov  rsp, rbp           ; Deallocate local variables
    pop  rbp                ; Restore previous frame pointer
    ret                     ; Return to caller

_start:
    ; Call compute_locals(10)
    ; Expected: a = 15, b = 30, return = 45
    mov  rdi, 10
    call compute_locals
    ; rax = 45

    ; Exit
    mov  rax, 60
    xor  rdi, rdi
    syscall
