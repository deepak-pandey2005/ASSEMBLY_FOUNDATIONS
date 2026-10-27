; ==============================================================================
; Program: precise_sleep.asm
; Description: High-resolution process sleep using sys_nanosleep (Syscall 35)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <time.h>
; #include <unistd.h>
;
; int main(void) {
;     write(STDOUT_FILENO, "[+] Sleeping for 50 milliseconds via sys_nanosleep...\n", 53);
;
;     // struct timespec { time_t tv_sec; long tv_nsec; };
;     struct timespec req;
;     req.tv_sec = 0;
;     req.tv_nsec = 50000000; // 50,000,000 nanoseconds = 50 milliseconds
;
;     nanosleep(&req, NULL);
;
;     write(STDOUT_FILENO, "[+] Woke up from sys_nanosleep! Scheduler yielded cleanly.\n", 58);
;     _exit(0);
; }
; ==============================================================================

section .data
    msg_start: db "[+] Sleeping for 50 milliseconds via sys_nanosleep...", 10
    len_start: equ $ - msg_start

    msg_done:  db "[+] Woke up from sys_nanosleep! Scheduler yielded cleanly.", 10
    len_done:  equ $ - msg_done

    ; struct timespec:
    ;   tv_sec:  seconds
    ;   tv_nsec: nanoseconds (50,000,000 ns = 50 ms)
    align 8
    sleep_time:
        dq 0                            ; tv_sec = 0
        dq 50000000                     ; tv_nsec = 50,000,000 (50 milliseconds)

section .text
global _start

_start:
    ; 1. Print sleep start message
    ; C equivalent: write(1, msg_start, len_start);
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_start]
    mov rdx, len_start
    syscall

    ; --------------------------------------------------------------------------
    ; 2. CALL SYS_NANOSLEEP: sys_nanosleep(req, rem)
    ; Syscall: 35
    ; C equivalent: nanosleep(&sleep_time, NULL);
    ; --------------------------------------------------------------------------
    mov rax, 35                         ; sys_nanosleep (35)
    lea rdi, [sleep_time]               ; const struct timespec *req
    xor rsi, rsi                        ; rem = NULL
    syscall

    ; 3. Print wake-up confirmation
    ; C equivalent: write(1, msg_done, len_done);
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Clean Exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
