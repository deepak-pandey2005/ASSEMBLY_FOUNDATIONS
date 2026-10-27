; ==============================================================================
; Program: seccomp_sandbox.asm
; Description: Process isolation via Linux Seccomp (Secure Computing Mode)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <sys/prctl.h>
; #include <linux/seccomp.h>
; #include <unistd.h>
;
; int main(void) {
;     // Step 1: Pre-sandbox
;     write(STDOUT_FILENO, "[+] Step 1: Pre-sandbox. All Linux syscalls permitted.\n", 54);
;
;     // Step 2: Prevent acquiring new privileges (prctl PR_SET_NO_NEW_PRIVS)
;     prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
;
;     // Step 3: Enter Strict Seccomp (only read, write, exit, sigreturn allowed!)
;     prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT, 0, 0, 0);
;
;     // Step 4: Permitted syscall works normally
;     write(STDOUT_FILENO, "[+] Step 3: Sandboxed! Allowed sys_write works normally.\n", 56);
;     write(STDOUT_FILENO, "[+] Step 4: Exiting cleanly via allowed sys_exit.\n", 49);
;
;     // If we tried any disallowed syscall (e.g. open, fork, socket),
;     // kernel would instantly send SIGKILL / SIGSYS to terminate process!
;     _exit(0);
; }
; ==============================================================================

section .data
    msg_pre:  db "[+] Step 1: Pre-sandbox. All Linux syscalls permitted.", 10
    len_pre:  equ $ - msg_pre

    msg_lock: db "[+] Step 2: Enabling PR_SET_NO_NEW_PRIVS and Strict Seccomp...", 10
    len_lock: equ $ - msg_lock

    msg_post: db "[+] Step 3: Sandboxed! Allowed sys_write works normally.", 10
    len_post: equ $ - msg_post

    msg_safe: db "[+] Step 4: Exiting cleanly via allowed sys_exit.", 10
    len_safe: equ $ - msg_safe

    ; Constants for prctl
    ; PR_SET_NO_NEW_PRIVS = 38
    PR_SET_NO_NEW_PRIVS equ 38
    ; PR_SET_SECCOMP = 22
    PR_SET_SECCOMP equ 22
    ; SECCOMP_MODE_STRICT = 1
    SECCOMP_MODE_STRICT equ 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. PRE-SANDBOX: Normal sys_write (Syscall 1)
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_pre]
    mov rdx, len_pre
    syscall

    ; --------------------------------------------------------------------------
    ; 2. LOCK DOWN: sys_prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)
    ; Syscall: 157
    ; Ensures the process cannot gain privileges via setuid executables
    ; --------------------------------------------------------------------------
    mov rax, 157                        ; sys_prctl
    mov rdi, PR_SET_NO_NEW_PRIVS        ; 38
    mov rsi, 1                          ; arg2 = 1
    xor rdx, rdx
    xor r10, r10
    xor r8, r8
    syscall

    ; --------------------------------------------------------------------------
    ; 3. ENABLE STRICT SECCOMP: sys_prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT=1)
    ; Syscall: 157
    ; From this point on, ONLY 4 syscalls are permitted:
    ;   - sys_read (0)
    ;   - sys_write (1)
    ;   - sys_exit (60)
    ;   - sys_rt_sigreturn (15)
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_lock]
    mov rdx, len_lock
    syscall

    mov rax, 157                        ; sys_prctl
    mov rdi, PR_SET_SECCOMP             ; 22
    mov rsi, SECCOMP_MODE_STRICT        ; 1
    xor rdx, rdx
    xor r10, r10
    xor r8, r8
    syscall

    cmp rax, 0
    jl .fatal

    ; --------------------------------------------------------------------------
    ; 4. POST-SANDBOX: Permitted sys_write (Syscall 1) succeeds!
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_post]
    mov rdx, len_post
    syscall

    ; Permitted message before exit
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_safe]
    mov rdx, len_safe
    syscall

    ; --------------------------------------------------------------------------
    ; 5. PERMITTED EXIT: sys_exit(0) -> Syscall 60
    ; (If we had called sys_open or sys_fork here, kernel would instantly kill us!)
    ; --------------------------------------------------------------------------
    mov rax, 60                         ; sys_exit
    xor rdi, rdi                        ; status = 0
    syscall

.fatal:
    mov rax, 60
    mov rdi, 1
    syscall
