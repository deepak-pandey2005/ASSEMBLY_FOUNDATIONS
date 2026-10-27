; ==============================================================================
; Program: shellcode_demo.asm
; Description: Anti-debugging detection via ptrace + position-independent stack string payload
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <sys/ptrace.h>
; #include <unistd.h>
; #include <string.h>
;
; int main(void) {
;     // 1. Anti-debugging check using ptrace
;     // If a debugger is already attached, PTRACE_TRACEME fails with -1 (EPERM)
;     long res = ptrace(PTRACE_TRACEME, 0, NULL, NULL);
;     if (res < 0) {
;         write(STDOUT_FILENO, "[!] ALERT: Active debugger (GDB/strace) detected via ptrace!\n", 61);
;     } else {
;         write(STDOUT_FILENO, "[+] No debugger detected. Running normally!\n", 44);
;     }
;
;     // 2. Position-Independent Code (PIC) stack string payload
;     // Pushing string "PWNED!\n" dynamically on the stack without any .data memory
;     char stack_str[8] = {'P', 'W', 'N', 'E', 'D', '!', '\n', '\0'};
;     write(STDOUT_FILENO, stack_str, 7);
;     write(STDOUT_FILENO, "[+] Position-Independent stack string execution verified!\n", 58);
;
;     _exit(0);
; }
; ==============================================================================

section .data
    msg_normal: db "[+] No debugger detected. Running normally!", 10
    len_normal: equ $ - msg_normal

    msg_debug:  db "[!] ALERT: Active debugger (GDB/strace) detected via ptrace!", 10
    len_debug:  equ $ - msg_debug

    msg_pic:    db "[+] Position-Independent stack string execution verified!", 10
    len_pic:    equ $ - msg_pic

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. ANTI-DEBUGGING: sys_ptrace(PTRACE_TRACEME=0, pid=0, addr=0, data=0)
    ; Syscall: 101
    ; If a debugger is already attached, ptrace fails and returns -1 (EPERM)!
    ; C equivalent: if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) < 0) goto debugger_found;
    ; --------------------------------------------------------------------------
    mov rax, 101                ; sys_ptrace (101)
    xor rdi, rdi                ; PTRACE_TRACEME = 0
    xor rsi, rsi                ; pid = 0
    xor rdx, rdx                ; addr = 0
    xor r10, r10                ; data = 0
    syscall

    cmp rax, 0
    jl .debugger_found

    ; No debugger attached
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [msg_normal]
    mov rdx, len_normal
    syscall
    jmp .run_pic_payload

.debugger_found:
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [msg_debug]
    mov rdx, len_debug
    syscall

.run_pic_payload:
    ; --------------------------------------------------------------------------
    ; 2. POSITION-INDEPENDENT CODE (PIC) DEMO:
    ; Pushing string dynamically onto the stack without referencing any .data symbols!
    ; String: "PWNED!\n\0" (8 bytes: 'P', 'W', 'N', 'E', 'D', '!', 10, 0)
    ; Hex: 0x000A2144454E5750
    ; C equivalent: char stack_str[8] = "PWNED!\n"; write(1, stack_str, 7);
    ; --------------------------------------------------------------------------
    xor rax, rax
    push rax                    ; null-terminate

    mov rax, 0x0A2144454E5750   ; "PWNED!\n" in little-endian format
    push rax

    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, rsp                ; buffer pointer on the stack
    mov rdx, 7                  ; 7 bytes
    syscall

    add rsp, 16                 ; clean up stack space

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_pic]
    mov rdx, len_pic
    syscall

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall
