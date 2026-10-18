; ==============================================================================
; Program: atomic_spinlock.asm
; Description: Implements a hardware spinlock using LOCK CMPXCHG and atomic XADD
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    msg_acquired: db "[+] Spinlock acquired atomically via LOCK CMPXCHG!", 10
    len_acquired: equ $ - msg_acquired

    msg_released: db "[+] Critical section executed. Spinlock released!", 10
    len_released: equ $ - msg_released

    lock_var: dd 0              ; 0 = Unlocked, 1 = Locked

section .bss
    shared_counter: resd 1

section .text
global _start

; ------------------------------------------------------------------------------
; Routine: spinlock_lock
; Input: RDI = pointer to 32-bit lock variable
; ------------------------------------------------------------------------------
spinlock_lock:
.spin:
    xor eax, eax                ; Expected value: 0 (unlocked)
    mov edx, 1                  ; Desired value: 1 (locked)
    lock cmpxchg [rdi], edx     ; Atomic CAS
    jz .acquired                ; If ZF=1, swap succeeded!

    pause                       ; Intel PAUSE instruction optimizes spin-wait loop power & pipeline
    jmp .spin

.acquired:
    ret

; ------------------------------------------------------------------------------
; Routine: spinlock_unlock
; Input: RDI = pointer to 32-bit lock variable
; ------------------------------------------------------------------------------
spinlock_unlock:
    ; Simple store with release semantics (on x86, normal stores have release order)
    mov dword [rdi], 0
    ret

_start:
    ; 1. Acquire spinlock
    lea rdi, [lock_var]
    call spinlock_lock

    ; Print acquired message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_acquired
    mov rdx, len_acquired
    syscall

    ; 2. Critical Section: atomically increment shared counter
    ; Using LOCK XADD (Fetch and Add)
    mov eax, 5                  ; amount to add
    lock xadd [shared_counter], eax
    ; eax now holds old value (0), and [shared_counter] holds 5!

    ; 3. Release spinlock
    lea rdi, [lock_var]
    call spinlock_unlock

    ; Print released message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_released
    mov rdx, len_released
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
