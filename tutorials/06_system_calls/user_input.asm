; ==============================================================================
; Program: user_input.asm
; Description: Read a line from stdin (keyboard) and echo it back to stdout
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
;
; static const char prompt[] = "Please enter your name: ";
; static const char greeting[] = "Hello, ";
; static char buffer[64];
; static ssize_t bytes_read;
;
; int main(void) {
;     // 1. Print prompt
;     write(STDOUT_FILENO, prompt, sizeof(prompt) - 1);
;
;     // 2. Read from stdin
;     bytes_read = read(STDIN_FILENO, buffer, sizeof(buffer));
;
;     // 3. Print greeting prefix
;     write(STDOUT_FILENO, greeting, sizeof(greeting) - 1);
;
;     // 4. Print user's name
;     if (bytes_read > 0) {
;         write(STDOUT_FILENO, buffer, bytes_read);
;     }
;
;     _exit(0);
; }
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
    ; --------------------------------------------------------------------------
    ; 1. Print prompt
    ; C equivalent: write(1, prompt, prompt_len);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; rax = SYS_write (1)
    mov rdi, 1                  ; rdi = STDOUT_FILENO (1)
    mov rsi, prompt             ; rsi = &prompt[0]
    mov rdx, prompt_len         ; rdx = length
    syscall

    ; --------------------------------------------------------------------------
    ; 2. Read user input from stdin (fd: 0)
    ; C equivalent: bytes_read = read(0, buffer, 64);
    ; --------------------------------------------------------------------------
    mov rax, 0                  ; rax = SYS_read (0)
    mov rdi, 0                  ; rdi = STDIN_FILENO (0)
    mov rsi, buffer             ; rsi = &buffer[0]
    mov rdx, 64                 ; rdx = 64 (max buffer size)
    syscall
    ; RAX contains number of bytes actually read (including '\n')
    mov [bytes_read], rax

    ; --------------------------------------------------------------------------
    ; 3. Print greeting prefix ("Hello, ")
    ; C equivalent: write(1, greeting, greeting_len);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, greeting           ; "Hello, "
    mov rdx, greeting_len
    syscall

    ; --------------------------------------------------------------------------
    ; 4. Print user's name from buffer
    ; C equivalent: write(1, buffer, bytes_read);
    ; --------------------------------------------------------------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, [bytes_read]
    syscall

    ; --------------------------------------------------------------------------
    ; 5. Clean exit
    ; C equivalent: _exit(0);
    ; --------------------------------------------------------------------------
    mov rax, 60                 ; rax = SYS_exit (60)
    xor rdi, rdi                ; status = 0
    syscall
