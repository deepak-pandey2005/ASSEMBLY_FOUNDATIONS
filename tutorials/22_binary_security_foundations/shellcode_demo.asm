; ==============================================================================
; Program: shellcode_demo.asm
; Description: Anti-debugging detection via ptrace + position-independent stack string payload
; Architecture: x86-64 Linux
; Assembler: NASM
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
    ; --------------------------------------------------------------------------
    mov rax, 101                ; sys_ptrace
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
    ; --------------------------------------------------------------------------
    xor rax, rax
    push rax                    ; null-terminate
    mov rax, 0x0A2144454E5750   ; "PWNED!\n"
    push rax                    ; push onto stack

    ; Write string directly from RSP
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, rsp                ; stack pointer points to our dynamic string!
    mov rdx, 7                  ; 7 bytes
    syscall

    ; Clean up stack
    add rsp, 16

    ; Print verified message
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_pic]
    mov rdx, len_pic
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
