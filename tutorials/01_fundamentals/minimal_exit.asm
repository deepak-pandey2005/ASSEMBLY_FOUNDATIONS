; ==============================================================================
; Program: minimal_exit.asm
; Description: The absolute minimal working x86-64 ELF program.
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .text
global _start

_start:
    ; sys_exit(status: 42)
    mov rax, 60     ; sys_exit syscall index
    mov rdi, 42     ; custom return code (accessible via `echo $?`)
    syscall
