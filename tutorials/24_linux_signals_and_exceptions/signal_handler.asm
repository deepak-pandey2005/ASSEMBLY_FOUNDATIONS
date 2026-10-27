; ==============================================================================
; Program: signal_handler.asm
; Description: Registers a custom signal handler for SIGUSR1 via sys_rt_sigaction
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <signal.h>
; #include <unistd.h>
; #include <string.h>
;
; void sigusr1_handler(int sig) {
;     const char msg[] = "[+] Signal SIGUSR1 successfully intercepted and handled!\n";
;     write(STDOUT_FILENO, msg, sizeof(msg) - 1);
; }
;
; int main(void) {
;     // 1. Install signal handler for SIGUSR1 (signal 10)
;     struct sigaction sa;
;     memset(&sa, 0, sizeof(sa));
;     sa.sa_handler = sigusr1_handler;
;     sigaction(SIGUSR1, &sa, NULL);
;
;     write(STDOUT_FILENO, "[+] Installing custom signal handler for SIGUSR1 (10)...\n", 57);
;
;     // 2. Raise SIGUSR1 to self
;     kill(getpid(), SIGUSR1);
;
;     write(STDOUT_FILENO, "[+] Process resumed after signal handling. Exiting cleanly.\n", 59);
;     _exit(0);
; }
; ==============================================================================

section .data
    msg_install: db "[+] Installing custom signal handler for SIGUSR1 (10)...", 10
    len_install: equ $ - msg_install

    msg_caught:  db "[+] Signal SIGUSR1 successfully intercepted and handled!", 10
    len_caught:  equ $ - msg_caught

    msg_done:    db "[+] Process resumed after signal handling. Exiting cleanly.", 10
    len_done:    equ $ - msg_done

    ; struct sigaction (32 bytes minimum representation on x86_64)
    ; offset 0:  sa_handler pointer
    ; offset 8:  sa_flags (SA_RESTORER = 0x04000000)
    ; offset 16: sa_restorer pointer (points to sys_rt_sigreturn)
    ; offset 24: sa_mask (8 bytes zero)
    align 8
    act:
        dq sigusr1_handler              ; sa_handler
        dq 0x04000000                   ; sa_flags: SA_RESTORER
        dq restore_trampoline           ; sa_restorer
        dq 0                            ; sa_mask

section .text
global _start

; ------------------------------------------------------------------------------
; Signal Restorer Trampoline: sys_rt_sigreturn (Syscall 15)
; Mandatory on x86_64 Linux when using SA_RESTORER
; C equivalent: void restore_rt(void) { syscall(SYS_rt_sigreturn); }
; ------------------------------------------------------------------------------
restore_trampoline:
    mov rax, 15                         ; sys_rt_sigreturn (15)
    syscall

; ------------------------------------------------------------------------------
; Custom Signal Handler for SIGUSR1
; Arguments passed by kernel: RDI = signal number (10)
; C equivalent: void sigusr1_handler(int sig)
; ------------------------------------------------------------------------------
sigusr1_handler:
    ; Print message from inside signal handler
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_caught]
    mov rdx, len_caught
    syscall
    ret                                 ; Returns to restorer trampoline

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; 1. Print installation message
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_install]
    mov rdx, len_install
    syscall

    ; 2. Register Signal Handler: sys_rt_sigaction(sig=10, act=&act, oldact=0, sigsetsize=8)
    ; C equivalent: sigaction(SIGUSR1, &act, NULL);
    mov rax, 13                         ; sys_rt_sigaction (13)
    mov rdi, 10                         ; SIGUSR1 = 10
    lea rsi, [act]                       ; pointer to struct sigaction
    xor rdx, rdx                        ; oldact = NULL
    mov r10, 8                          ; sizeof(sigset_t) = 8 bytes
    syscall

    ; 3. Trigger Signal by sending SIGUSR1 to our own PID: sys_kill(pid, sig)
    ; C equivalent: kill(getpid(), SIGUSR1);
    mov rax, 39                         ; sys_getpid
    syscall
    mov rdi, rax                        ; rdi = self pid
    mov rsi, 10                         ; rsi = SIGUSR1 (10)
    mov rax, 62                         ; sys_kill
    syscall

    ; 4. Execution resumes here after signal handler finishes!
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
