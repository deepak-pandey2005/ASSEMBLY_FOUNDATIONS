; ==============================================================================
; Program: minimal_exit.asm
; Description: The absolute minimal working x86-64 ELF program.
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
;
; int main(void) {
;     _exit(42); // returns 42 to OS (view with `echo $?`)
; }
; ==============================================================================

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; C equivalent:
    ;   _exit(42);
    ;
    ; Linux x86-64 System V Calling Convention:
    ;   RAX = 60 (syscall number for SYS_exit)
    ;   RDI = 42 (1st argument: int status)
    ; --------------------------------------------------------------------------
    mov rax, 60     ; rax = 60 (syscall number for SYS_exit)
    mov rdi, 42     ; rdi = 42 (exit status code: 42)
    syscall         ; invoke Linux kernel to terminate the process
