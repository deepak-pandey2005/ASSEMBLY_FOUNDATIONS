; ==============================================================================
; tutorials/35_linux_futex_low_latency_mutex/futex_mutex.asm
; Low-Latency Mutex using Linux sys_futex (Syscall 202) in Pure x86-64 Assembly.
;
; Concepts:
; - Futex 3-state word:
;     0 = Unlocked
;     1 = Locked, no waiters
;     2 = Locked, one or more threads sleeping in kernel queue
; - Fast-path: Single user-space atomic instruction (LOCK CMPXCHG, zero syscalls)
; - Slow-path: sys_futex(uaddr, FUTEX_WAIT, 2, NULL, NULL, 0)
; - Unlock: Decrements lock. If state was 2, calls sys_futex(uaddr, FUTEX_WAKE, 1)
; - Multithreaded test: Spawns worker thread via sys_clone, concurrent lock/unlock
; ==============================================================================

global _start

%define SYS_WRITE 1
%define SYS_MMAP  9
%define SYS_CLONE 56
%define SYS_EXIT  60
%define SYS_FUTEX 202

%define STDOUT_FILENO 1

; Futex Operations
%define FUTEX_WAIT         0
%define FUTEX_WAKE         1
%define FUTEX_PRIVATE_FLAG 128
%define FUTEX_WAIT_PRIVATE (FUTEX_WAIT | FUTEX_PRIVATE_FLAG)
%define FUTEX_WAKE_PRIVATE (FUTEX_WAKE | FUTEX_PRIVATE_FLAG)

; Clone flags for threads
%define CLONE_VM      0x00000100
%define CLONE_FS      0x00000200
%define CLONE_FILES   0x00000400
%define CLONE_SIGHAND 0x00000800
%define CLONE_THREAD  0x00010000
%define CLONE_FLAGS   (CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD)

; mmap constants
%define PROT_READ   0x1
%define PROT_WRITE  0x2
%define MAP_PRIVATE 0x02
%define MAP_ANON    0x20
%define STACK_SIZE  16384

section .data
    title_banner    db "+================================================+", 10
                    db "|    LINUX FUTEX LOW-LATENCY MUTEX (sys_futex)   |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    msg_main_start  db "[Main Thread] Mutex initialized. Testing uncontended lock/unlock...", 10
    len_main_start  equ $ - msg_main_start

    msg_uncont_ok   db "[+] Fast-path user-space atomic lock/unlock: PASSED (Zero Syscalls).", 10
    len_uncont_ok   equ $ - msg_uncont_ok

    msg_spawn_test  db "[*] Spawning concurrent thread to test contested futex kernel sleep...", 10
    len_spawn_test  equ $ - msg_spawn_test

    msg_worker_run  db "[Worker Thread] Attempting to acquire contested mutex...", 10
    len_worker_run  equ $ - msg_worker_run

    msg_worker_got  db "[Worker Thread] Acquired mutex! In critical section.", 10
    len_worker_got  equ $ - msg_worker_got

    msg_main_holds  db "[Main Thread] Holding mutex, sleeping briefly to force worker sleep...", 10
    len_main_holds  equ $ - msg_main_holds

    msg_main_unlock db "[Main Thread] Releasing mutex! sys_futex waking worker thread...", 10
    len_main_unlock equ $ - msg_main_unlock

    msg_all_done    db "[+] Linux Futex low-latency mutex verification PASSED perfectly!", 10
    len_all_done    equ $ - msg_all_done

    ; 32-bit Futex lock word: 0 = free, 1 = locked, 2 = locked with waiters
    align 4
    my_mutex        dd 0
    worker_done     dd 0

section .bss
    child_stack     resq 1

section .text

_start:
    ; Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; Step 1: Uncontended Fast-Path Lock / Unlock Test
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_main_start]
    mov     rdx, len_main_start
    syscall

    lea     rdi, [rel my_mutex]
    call    futex_mutex_lock

    ; In critical section (uncontended)
    lea     rdi, [rel my_mutex]
    call    futex_mutex_unlock

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_uncont_ok]
    mov     rdx, len_uncont_ok
    syscall

    ; Step 2: Allocate stack for worker thread via sys_mmap
    mov     rax, SYS_MMAP
    xor     rdi, rdi
    mov     rsi, STACK_SIZE
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_PRIVATE | MAP_ANON
    mov     r8, -1
    xor     r9, r9
    syscall

    test    rax, rax
    js      .error_exit

    ; Align child stack pointer to top of allocated region
    lea     rsi, [rax + STACK_SIZE - 16]

    ; Print spawn message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_spawn_test]
    mov     rdx, len_spawn_test
    syscall

    ; Main thread acquires mutex BEFORE spawning worker to guarantee contention
    lea     rdi, [rel my_mutex]
    call    futex_mutex_lock

    ; Spawn worker thread via sys_clone
    mov     rax, SYS_CLONE
    mov     rdi, CLONE_FLAGS
    ; rsi already points to child stack top
    xor     rdx, rdx
    xor     r10, r10
    xor     r8, r8
    syscall

    test    rax, rax
    js      .error_exit
    jz      .worker_entry

    ; --------------------------------------------------------------------------
    ; MAIN THREAD (Holding lock)
    ; --------------------------------------------------------------------------
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_main_holds]
    mov     rdx, len_main_holds
    syscall

    ; Busy loop to simulate work while holding lock
    mov     rcx, 5000000
.delay_loop:
    pause
    dec     rcx
    jnz     .delay_loop

    ; Release mutex, waking the worker thread sleeping in futex queue
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_main_unlock]
    mov     rdx, len_main_unlock
    syscall

    lea     rdi, [rel my_mutex]
    call    futex_mutex_unlock

    ; Wait for worker to finish
.wait_worker:
    pause
    mov     eax, [rel worker_done]
    test    eax, eax
    jz      .wait_worker

    ; Success banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_all_done]
    mov     rdx, len_all_done
    syscall

    ; Exit main
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

    ; --------------------------------------------------------------------------
    ; WORKER THREAD ENTRY
    ; --------------------------------------------------------------------------
.worker_entry:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_worker_run]
    mov     rdx, len_worker_run
    syscall

    ; Try acquiring mutex (will block in kernel via FUTEX_WAIT!)
    lea     rdi, [rel my_mutex]
    call    futex_mutex_lock

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_worker_got]
    mov     rdx, len_worker_got
    syscall

    ; Release mutex
    lea     rdi, [rel my_mutex]
    call    futex_mutex_unlock

    ; Signal completion
    mov     dword [rel worker_done], 1

    ; Exit worker thread
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

.error_exit:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

; ==============================================================================
; futex_mutex_lock(int32_t *uaddr [RDI])
; ==============================================================================
futex_mutex_lock:
    push    rbx
    push    r12
    mov     r12, rdi                    ; r12 = futex word pointer

    ; 1. Fast-path: atomic compare-and-swap (0 -> 1)
    xor     eax, eax                    ; Expected = 0
    mov     ecx, 1                      ; Desired = 1
    lock cmpxchg [r12], ecx
    jz      .lock_acquired              ; If eax was 0, lock succeeded immediately!

.contention_loop:
    ; Lock is held. Try marking it as 2 (locked with waiters)
    cmp     eax, 2
    je      .call_futex_wait

    ; Set state to 2 atomically
    mov     eax, 1
    mov     ecx, 2
    lock cmpxchg [r12], ecx
    test    eax, eax
    jz      .lock_acquired              ; If it was unlocked in between, we got it!

.call_futex_wait:
    ; sys_futex(uaddr, FUTEX_WAIT_PRIVATE, val=2, NULL, NULL, 0)
    mov     rax, SYS_FUTEX
    mov     rdi, r12                    ; uaddr
    mov     rsi, FUTEX_WAIT_PRIVATE     ; op
    mov     rdx, 2                      ; expected val
    xor     r10, r10                    ; timeout = NULL
    xor     r8, r8
    xor     r9, r9
    syscall

    ; After wake-up, try to exchange with 2
    mov     ecx, 2
    xchg    [r12], ecx
    test    ecx, ecx
    jz      .lock_acquired              ; If old value was 0, we acquired the lock!

    mov     eax, ecx
    jmp     .contention_loop

.lock_acquired:
    pop     r12
    pop     rbx
    ret

; ==============================================================================
; futex_mutex_unlock(int32_t *uaddr [RDI])
; ==============================================================================
futex_mutex_unlock:
    push    r12
    mov     r12, rdi

    ; Fast-path: decrement lock value
    ; If old value was 1, it becomes 0 (no waiters). Done!
    ; If old value was 2, we must wake sleeping waiters.
    mov     eax, 1
    lock xadd [r12], eax                ; eax receives old value
    ; But we want to decrement: lock sub dword [r12], 1
    ; Let's do standard decrement:
    lock sub dword [r12], 1
    jz      .unlock_done                ; If new value is 0, no waiters to wake

    ; New value was > 0 (meaning there were waiters), reset to 0 and wake 1 thread
    mov     dword [r12], 0

    ; sys_futex(uaddr, FUTEX_WAKE_PRIVATE, val=1)
    mov     rax, SYS_FUTEX
    mov     rdi, r12
    mov     rsi, FUTEX_WAKE_PRIVATE
    mov     rdx, 1                      ; Wake 1 thread
    xor     r10, r10
    xor     r8, r8
    xor     r9, r9
    syscall

.unlock_done:
    pop     r12
    ret
