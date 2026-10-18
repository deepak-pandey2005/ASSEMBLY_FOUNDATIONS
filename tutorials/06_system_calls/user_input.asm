; ==============================================================================
; Program: user_input.asm
; Description: Read a line from stdin (keyboard) and echo it back to stdout
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    prompt: db "Please enter your name: "
    prompt_len: equ $ - prompt

    greeting: db "Hello, "
    greeting_len: equ $ - greeting

section .bss
    buffer: resb 64             ; reserve 64 bytes for input string
    bytes_read: resq 1

section .text
global _start

_start:
    ; 1. Print prompt
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; 2. Read user input from stdin (fd: 0)
    ; sys_read(fd=0, buf=buffer, count=64)
    mov rax, 0                  ; sys_read
    mov rdi, 0                  ; stdin
    mov rsi, buffer
    mov rdx, 64
    syscall
    ; RAX contains number of bytes actually read (including newline)
    mov [bytes_read], rax

    ; 3. Print greeting prefix ("Hello, ")
    mov rax, 1
    mov rdi, 1
    mov rsi, greeting
    mov rdx, greeting_len
    syscall

    ; 4. Print user's name
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, [bytes_read]
    syscall

    ; 5. Exit cleanly
    mov rax, 60
    xor rdi, rdi
    syscall
