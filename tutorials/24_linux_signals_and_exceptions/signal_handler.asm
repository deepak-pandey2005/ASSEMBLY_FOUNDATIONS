; ==============================================================================
; Program: signal_handler.asm
; Description: Registers a custom signal handler for SIGUSR1 via sys_rt_sigaction
; Architecture: x86-64 Linux
; Assembler: NASM
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
; ------------------------------------------------------------------------------
restore_trampoline:
    mov rax, 15                         ; sys_rt_sigreturn
    syscall

; ------------------------------------------------------------------------------
; Custom Signal Handler for SIGUSR1
; Arguments passed by kernel: RDI = signal number (10)
; ------------------------------------------------------------------------------
sigusr1_handler:
    ; Print message from inside signal handler
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_caught]
    mov rdx, len_caught
    syscall
    ret                                 ; Returns to restorer trampoline

_start:
    ; 1. Print installation message
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_install]
    mov rdx, len_install
    syscall

    ; --------------------------------------------------------------------------
    ; 2. REGISTER SIGNAL HANDLER: sys_rt_sigaction(signum, &act, &oldact, sigsetsize)
    ; Syscall: 13
    ; RDI = signum (SIGUSR1 = 10)
    ; RSI = &act
    ; RDX = NULL (oldact)
    ; R10 = sizeof(sigset_t) = 8
    ; --------------------------------------------------------------------------
    mov rax, 13                         ; sys_rt_sigaction
    mov rdi, 10                         ; SIGUSR1
    lea rsi, [act]                      ; struct sigaction
    xor rdx, rdx                        ; oldact = NULL
    mov r10, 8                          ; sigsetsize = 8
    syscall

    ; --------------------------------------------------------------------------
    ; 3. SEND SIGNAL TO OURSELVES: sys_kill(pid, sig)
    ; Syscall: 62
    ; RDI = pid (0 means self process group)
    ; RSI = SIGUSR1 (10)
    ; --------------------------------------------------------------------------
    mov rax, 62                         ; sys_kill
    xor rdi, rdi                        ; pid = 0 (self)
    mov rsi, 10                         ; SIGUSR1
    syscall

    ; --------------------------------------------------------------------------
    ; 4. RESUME NORMAL EXECUTION
    ; --------------------------------------------------------------------------
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
