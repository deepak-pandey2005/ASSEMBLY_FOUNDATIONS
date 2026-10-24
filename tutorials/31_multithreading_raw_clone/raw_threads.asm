; ==============================================================================
; tutorials/31_multithreading_raw_clone/raw_threads.asm
; Native Linux Multithreading using raw sys_clone (Syscall 56) without libc / pthreads.
;
; Concepts:
; - Linux clone flags: CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD
; - User-space stack allocation with sys_mmap (Syscall 9)
; - Top-of-stack alignment (x86-64 stack grows downward)
; - Passing arguments/work to the child thread via shared memory
; - Atomic coordination (spin-wait / atomic exchange) between threads
; ==============================================================================

global _start

%define SYS_WRITE   1
%define SYS_MMAP    9
%define SYS_CLONE   56
%define SYS_EXIT    60

%define STDOUT_FILENO 1

; Memory protection and flags for mmap
%define PROT_READ   0x1
%define PROT_WRITE  0x2
%define MAP_PRIVATE 0x02
%define MAP_ANON    0x20

; Linux clone() flags:
; 0x00000100 : CLONE_VM      (Share virtual memory / page tables)
; 0x00000200 : CLONE_FS      (Share file system info)
; 0x00000400 : CLONE_FILES   (Share file descriptors)
; 0x00000800 : CLONE_SIGHAND (Share signal handlers)
; 0x00010000 : CLONE_THREAD  (Same thread group ID)
%define CLONE_FLAGS (0x00000100 | 0x00000200 | 0x00000400 | 0x00000800 | 0x00010000)

%define STACK_SIZE  16384     ; 16 KB thread stack

section .data
    msg_main_start  db "[Main Thread] Process started. Spawning worker thread via sys_clone...", 10
    len_main_start  equ $ - msg_main_start

    msg_worker_run  db "[Worker Thread] Hello from the raw kernel thread! Computing sum...", 10
    len_worker_run  equ $ - msg_worker_run

    msg_worker_done db "[Worker Thread] Computation complete. Exiting thread.", 10
    len_worker_done equ $ - msg_worker_done

    msg_main_done   db "[Main Thread] Worker finished! Shared counter value = 0x"
    len_main_done   equ $ - msg_main_done

    msg_success     db " [OK]", 10
    len_success     equ $ - msg_success

    newline         db 10

    ; Shared variable between main thread and worker thread
    align 8
    shared_counter  dq 0
    thread_finished dq 0       ; Flag set to 1 by worker when done

section .bss
    hex_buffer      resb 16

section .text

_start:
    ; 1. Print start message from main thread
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_main_start]
    mov     rdx, len_main_start
    syscall

    ; 2. Allocate separate stack for the child thread using sys_mmap
    ; mmap(NULL, STACK_SIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
    mov     rax, SYS_MMAP
    xor     rdi, rdi                    ; addr = NULL
    mov     rsi, STACK_SIZE             ; length = 16KB
    mov     rdx, PROT_READ | PROT_WRITE ; prot
    mov     r10, MAP_PRIVATE | MAP_ANON ; flags
    mov     r8, -1                      ; fd = -1
    xor     r9, r9                      ; offset = 0
    syscall

    test    rax, rax
    js      .error_exit                 ; Check if mmap failed (negative return)

    ; Calculate top of child stack:
    ; The stack grows DOWNWARDS from high memory to low memory.
    ; Top of stack = allocated_base + STACK_SIZE
    ; Also keep 16-byte alignment per System V AMD64 ABI.
    lea     rsi, [rax + STACK_SIZE - 16]

    ; 3. Call sys_clone (Syscall 56)
    ; In x86-64 Linux sys_clone:
    ; RAX = 56
    ; RDI = clone_flags
    ; RSI = child_stack top pointer
    ; RDX = ptid
    ; R10 = ctid
    ; R8  = tls
    mov     rax, SYS_CLONE
    mov     rdi, CLONE_FLAGS
    ; rsi is already set to the child stack top pointer
    xor     rdx, rdx                    ; ptid = NULL
    xor     r10, r10                    ; ctid = NULL
    xor     r8, r8                      ; tls = NULL
    syscall

    test    rax, rax
    js      .error_exit                 ; Error if rax < 0
    jz      .worker_thread_entry        ; If rax == 0, WE ARE IN THE CHILD THREAD!

    ; --------------------------------------------------------------------------
    ; MAIN THREAD EXECUTION PATH (rax > 0 contains child TID)
    ; --------------------------------------------------------------------------
.main_thread_wait:
    ; Spin-wait on thread_finished flag (relaxed pause instruction to reduce CPU contention)
    pause
    mov     rax, [rel thread_finished]
    test    rax, rax
    jz      .main_thread_wait

    ; Worker has finished! Output the computed shared counter
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_main_done]
    mov     rdx, len_main_done
    syscall

    ; Format shared_counter into hex_buffer
    mov     rax, [rel shared_counter]
    lea     rdi, [rel hex_buffer]
    call    to_hex_str

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel hex_buffer]
    mov     rdx, 16
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_success]
    mov     rdx, len_success
    syscall

    ; Clean exit for main process
    mov     rax, SYS_EXIT
    xor     rdi, rdi                    ; Exit code 0
    syscall

    ; --------------------------------------------------------------------------
    ; WORKER THREAD ENTRY POINT
    ; --------------------------------------------------------------------------
.worker_thread_entry:
    ; We are now executing in the child thread using our custom mmap-allocated stack!
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_worker_run]
    mov     rdx, len_worker_run
    syscall

    ; Perform concurrent work: increment shared_counter 10000 times atomically
    mov     rcx, 10000
.compute_loop:
    lock inc qword [rel shared_counter]
    loop    .compute_loop

    ; Print worker completed message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_worker_done]
    mov     rdx, len_worker_done
    syscall

    ; Set completion flag atomically so main thread wakes up
    mov     qword [rel thread_finished], 1

    ; Exit worker thread
    ; Note: With CLONE_THREAD, sys_exit (60) terminates only the calling thread,
    ; while sys_exit_group (231) would terminate all threads in the process!
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

.error_exit:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

; ------------------------------------------------------------------------------
; Helper: Convert 64-bit value in RAX to 16 hex characters in buffer RDI
; ------------------------------------------------------------------------------
to_hex_str:
    mov     rcx, 16                     ; 16 nibbles (64 bits)
.hex_loop:
    rol     rax, 4                      ; Rotate top nibble into bottom 4 bits
    mov     dl, al
    and     dl, 0x0F
    cmp     dl, 10
    jl      .is_digit
    add     dl, 'A' - 10
    jmp     .store_char
.is_digit:
    add     dl, '0'
.store_char:
    mov     [rdi], dl
    inc     rdi
    dec     rcx
    jnz     .hex_loop
    ret
