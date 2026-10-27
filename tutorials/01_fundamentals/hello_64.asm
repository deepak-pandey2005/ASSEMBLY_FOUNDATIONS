; ==============================================================================
; Program: hello_64.asm
; Description: 64-bit Linux "Hello, World!" with step-by-step register breakdown.
; Architecture: x86-64 (AMD64) Linux
; Assembler: NASM (Intel syntax)
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
;
; int main(void) {
;     const char msg[] = "Hello, Assembly Foundations!\n";
;     write(STDOUT_FILENO, msg, sizeof(msg) - 1); // STDOUT_FILENO = 1
;     _exit(0);
; }
; ==============================================================================

section .data
    ; C equivalent: const char msg[] = "Hello, Assembly Foundations!\n";
    ; 10 is the ASCII newline character ('\n').
    msg: db "Hello, Assembly Foundations!", 10

    ; C equivalent: sizeof(msg) - 1 (or strlen(msg))
    ; ($ - msg) = current offset minus start of msg = length in bytes.
    msg_len: equ $ - msg

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. WRITE TO STDOUT
    ;
    ; C equivalent:
    ;   write(/* fd = */ 1, /* buf = */ msg, /* count = */ msg_len);
    ;
    ; Linux x86-64 System V Calling Convention:
    ;   RAX = syscall number (1 is SYS_write)
    ;   RDI = 1st arg: file descriptor (1 is STDOUT_FILENO)
    ;   RSI = 2nd arg: pointer to buffer (const void *buf)
    ;   RDX = 3rd arg: count of bytes to write (size_t count)
    ; --------------------------------------------------------------------------
    mov rax, 1              ; rax = 1 (syscall: sys_write)
    mov rdi, 1              ; rdi = 1 (int fd = STDOUT_FILENO)
    mov rsi, msg            ; rsi = &msg[0] (pointer to string buffer)
    mov rdx, msg_len        ; rdx = 29 (size_t count)
    syscall                 ; trigger kernel context switch: write(1, msg, 29)

    ; --------------------------------------------------------------------------
    ; 2. EXIT CLEANLY
    ;
    ; C equivalent:
    ;   _exit(0);
    ;
    ; Linux x86-64 System V Calling Convention:
    ;   RAX = syscall number (60 is SYS_exit)
    ;   RDI = 1st arg: exit status code (int status = 0)
    ; --------------------------------------------------------------------------
    mov rax, 60             ; rax = 60 (syscall: sys_exit)
    xor rdi, rdi            ; rdi = 0  (exit status code = 0)
                            ; (xor reg, reg is standard idiom in x86 for reg = 0)
    syscall                 ; trigger kernel context switch: exit(0)
