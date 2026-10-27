; ==============================================================================
; Program: atomic_spinlock.asm
; Description: Implements a hardware spinlock using LOCK CMPXCHG and atomic XADD
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <stdbool.h>
; #include <unistd.h>
; #include <immintrin.h> // for _mm_pause()
;
; static uint32_t lock_var = 0; // 0 = Unlocked, 1 = Locked
; static uint32_t shared_counter = 0;
;
; void spinlock_lock(uint32_t *lock) {
;     // Atomic Compare-And-Swap (CAS)
;     while (!__sync_bool_compare_and_swap(lock, 0, 1)) {
;         _mm_pause(); // Intel PAUSE instruction optimizes spin-wait loops
;     }
; }
;
; void spinlock_unlock(uint32_t *lock) {
;     __atomic_store_n(lock, 0, __ATOMIC_RELEASE);
; }
;
; int main(void) {
;     // 1. Acquire spinlock
;     spinlock_lock(&lock_var);
;     write(STDOUT_FILENO, "[+] Spinlock acquired atomically via LOCK CMPXCHG!\n", 51);
;
;     // 2. Critical Section: Atomic fetch-and-add (__sync_fetch_and_add)
;     __sync_fetch_and_add(&shared_counter, 1);
;
;     // 3. Release spinlock
;     spinlock_unlock(&lock_var);
;     write(STDOUT_FILENO, "[+] Critical section executed. Spinlock released!\n", 50);
;
;     _exit(0);
; }
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
; C equivalent:
;   while (!__sync_bool_compare_and_swap(lock, 0, 1)) { _mm_pause(); }
; ------------------------------------------------------------------------------
spinlock_lock:
.spin:
    xor eax, eax                ; uint32_t expected = 0; (unlocked)
    mov edx, 1                  ; uint32_t desired = 1;  (locked)
    lock cmpxchg [rdi], edx     ; Atomic CAS: if (*rdi == eax) { *rdi = edx; ZF=1; } else { eax = *rdi; ZF=0; }
    jz .acquired                ; if (ZF == 1) goto acquired;

    pause                       ; Intel PAUSE instruction: reduces CPU pipeline stalls & power
    jmp .spin

.acquired:
    ret

; ------------------------------------------------------------------------------
; Routine: spinlock_unlock
; Input: RDI = pointer to 32-bit lock variable
; C equivalent: *lock = 0;
; ------------------------------------------------------------------------------
spinlock_unlock:
    ; Simple store with release semantics (on x86 TSO, normal stores have release order)
    mov dword [rdi], 0
    ret

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; 1. Acquire spinlock
    ; C equivalent: spinlock_lock(&lock_var);
    lea rdi, [lock_var]
    call spinlock_lock

    ; Print acquired message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_acquired
    mov rdx, len_acquired
    syscall

    ; 2. Critical Section: Atomic fetch-and-add (LOCK XADD)
    ; C equivalent: __sync_fetch_and_add(&shared_counter, 1);
    mov eax, 1
    lock xadd [shared_counter], eax

    ; 3. Release spinlock
    ; C equivalent: spinlock_unlock(&lock_var);
    lea rdi, [lock_var]
    call spinlock_unlock

    ; Print released message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_released
    mov rdx, len_released
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
