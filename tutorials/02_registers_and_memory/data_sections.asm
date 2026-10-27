; ==============================================================================
; Program: data_sections.asm
; Description: Demonstrates data transfer across .rodata, .data, and .bss
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
;
; // .rodata section (Read-Only Data)
; static const char greeting[] = "Assembler initialized\n";
;
; // .data section (Initialized Read-Write Data)
; static uint64_t init_val = 0x1122334455667788ULL;
; static uint8_t  status_byte = 1;
;
; // .bss section (Uninitialized Zero-Filled RAM)
; static char     buffer[64];
; static uint64_t saved_val;
;
; int main(void) {
;     // 1. Write from .rodata
;     write(STDOUT_FILENO, greeting, sizeof(greeting) - 1);
;
;     // 2. Load from .data and save into .bss
;     saved_val = init_val;
;
;     // 3. Write bytes into .bss array
;     buffer[0] = 'A';
;     buffer[1] = 'B';
;     buffer[2] = '\n';
;
;     // 4. Write from .bss
;     write(STDOUT_FILENO, buffer, 3);
;
;     _exit(0);
; }
; ==============================================================================

section .rodata
    ; C equivalent: static const char greeting[] = "Assembler initialized\n";
    greeting: db "Assembler initialized", 10, 0
    greeting_len: equ $ - greeting

section .data
    ; C equivalent: static uint64_t init_val = 0x1122334455667788ULL;
    init_val: dq 0x1122334455667788
    ; C equivalent: static uint8_t status_byte = 1;
    status_byte: db 1

section .bss
    ; C equivalent: static char buffer[64]; (uninitialized, zeroed by kernel)
    buffer: resb 64
    ; C equivalent: static uint64_t saved_val;
    saved_val: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. Print greeting from .rodata
    ; C equivalent: write(1, greeting, greeting_len);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; rax = SYS_write (1)
    mov rdi, 1                  ; rdi = STDOUT_FILENO (1)
    mov rsi, greeting           ; rsi = &greeting[0] (pointer to .rodata string)
    mov rdx, greeting_len       ; rdx = byte count
    syscall

    ; --------------------------------------------------------------------------
    ; 2. Load from .data into register, store into .bss
    ; C equivalent: saved_val = init_val;
    ; --------------------------------------------------------------------------
    mov rax, [init_val]         ; rax = init_val (0x1122334455667788)
    mov [saved_val], rax        ; saved_val = rax

    ; --------------------------------------------------------------------------
    ; 3. Store individual bytes into buffer array in .bss
    ; C equivalent: buffer[0] = 'A'; buffer[1] = 'B'; buffer[2] = '\n';
    ; --------------------------------------------------------------------------
    mov byte [buffer], 'A'      ; buffer[0] = 'A'
    mov byte [buffer + 1], 'B'  ; buffer[1] = 'B'
    mov byte [buffer + 2], 10   ; buffer[2] = '\n' (10)

    ; --------------------------------------------------------------------------
    ; 4. Print buffer from .bss
    ; C equivalent: write(1, buffer, 3);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; rax = SYS_write (1)
    mov rdi, 1                  ; rdi = STDOUT_FILENO (1)
    mov rsi, buffer             ; rsi = &buffer[0]
    mov rdx, 3                  ; rdx = 3 bytes
    syscall

    ; --------------------------------------------------------------------------
    ; 5. Clean exit
    ; C equivalent: _exit(0);
    ; --------------------------------------------------------------------------
    mov rax, 60                 ; rax = SYS_exit (60)
    xor rdi, rdi                ; rdi = 0
    syscall
