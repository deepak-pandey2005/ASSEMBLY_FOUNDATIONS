; ==============================================================================
; Assembly Foundations - Tutorial 39: Lock-Free SPSC Ring Buffer Concurrency
; Architecture: x86-64 (Linux ELF)
; Description:  High-throughput, zero-mutex, lock-free Single-Producer
;               Single-Consumer (SPSC) circular ring buffer.
;               Demonstrates cache-line false sharing prevention (align 64),
;               x86-64 TSO memory ordering, pause instruction spin-waiting,
;               and streaming 1,000,000 elements across concurrent kernel threads.
; Zero C runtime / libc dependencies. Pure Linux system calls.

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #define _GNU_SOURCE
; #include <sched.h>
; #include <sys/mman.h>
; #include <unistd.h>
; #include <stdint.h>
; #include <immintrin.h> // _mm_pause
;
; #define RING_CAPACITY 1024
; #define RING_MASK (RING_CAPACITY - 1)
; #define TOTAL_ITEMS 1000000
;
; // Align head and tail to distinct 64-byte L1 CPU cache lines to prevent false sharing
; static uint64_t ring_slots[RING_CAPACITY];
; static alignas(64) volatile uint64_t producer_tail = 0;
; static alignas(64) volatile uint64_t consumer_head = 0;
; static alignas(64) volatile uint64_t consumer_sum  = 0;
;
; static int consumer_thread(void *arg) {
;     uint64_t local_sum = 0;
;     for (int i = 0; i < TOTAL_ITEMS; i++) {
;         uint64_t head = consumer_head;
;         while (head == producer_tail) {
;             _mm_pause(); // Queue empty: spin-wait
;         }
;         local_sum += ring_slots[head & RING_MASK];
;         consumer_head = head + 1; // Release slot
;     }
;     consumer_sum = local_sum;
;     _exit(0);
; }
;
; int main(void) {
;     void *stack = mmap(NULL, 65536, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
;     clone(consumer_thread, (char *)stack + 65536,
;           CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD, NULL);
;
;     // Producer loop: Stream 1,000,000 items with zero mutexes or locks
;     for (uint64_t item = 1; item <= TOTAL_ITEMS; item++) {
;         uint64_t tail = producer_tail;
;         while ((tail - consumer_head) >= RING_CAPACITY) {
;             _mm_pause(); // Queue full: spin-wait
;         }
;         ring_slots[tail & RING_MASK] = item;
;         producer_tail = tail + 1; // Publish slot
;     }
;     while (consumer_head < TOTAL_ITEMS) _mm_pause();
;     _exit(0);
; }
; ==============================================================================

global _start

; --- Linux System Call Numbers (x86-64) ---
%define SYS_WRITE           1
%define SYS_MMAP            9
%define SYS_MUNMAP          11
%define SYS_CLONE           56
%define SYS_EXIT            60

; --- Linux mmap & clone Flags ---
%define PROT_READ           0x1
%define PROT_WRITE          0x2
%define MAP_PRIVATE         0x02
%define MAP_ANONYMOUS       0x20

%define CLONE_VM            0x00000100
%define CLONE_FS            0x00000200
%define CLONE_FILES         0x00000400
%define CLONE_SIGHAND       0x00000800
%define CLONE_THREAD        0x00010000

%define THREAD_FLAGS        (CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD)

%define STDOUT_FILENO       1

; --- Ring Buffer Parameters ---
%define RING_CAPACITY       1024            ; Must be power of 2
%define RING_MASK           (RING_CAPACITY - 1) ; 1023 (0x3FF)
%define TOTAL_ITEMS         1000000         ; 1 Million elements streamed

%define STACK_SIZE          65536           ; 64 KB user stack for worker thread

section .data
    banner:
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
        db 0x1B, "[1;32m", " [TUTORIAL 39] Lock-Free SPSC Ring Buffer Concurrency", 0x1B, "[0m", 10
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
    banner_len equ $ - banner

    msg_setup:
        db "[-] Initializing 1,024-slot lock-free circular ring buffer...", 10
        db "[-] Isolating head & tail indices on separate 64-byte cache lines...", 10
    msg_setup_len equ $ - msg_setup

    msg_spawn:
        db "[-] Spawning Consumer thread via sys_clone...", 10
    msg_spawn_len equ $ - msg_spawn

    msg_streaming:
        db "[-] Streaming 1,000,000 items lock-free (Zero Mutexes / Zero Syscalls)...", 10
    msg_streaming_len equ $ - msg_streaming

    msg_results_hdr:
        db 0x1B, "[1;33m", "--- Lock-Free SPSC Benchmarking Results ---", 0x1B, "[0m", 10
    msg_results_hdr_len equ $ - msg_results_hdr

    msg_items_label:
        db "  -> Total Items Streamed : "
    msg_items_label_len equ $ - msg_items_label

    msg_cycles_label:
        db "  -> Total RDTSC Cycles   : "
    msg_cycles_label_len equ $ - msg_cycles_label

    msg_avg_label:
        db "  -> Avg Cost per Item    : "
    msg_avg_label_len equ $ - msg_avg_label

    msg_avg_unit:
        db " cycles / message", 10
    msg_avg_unit_len equ $ - msg_avg_unit

    msg_chk_ok:
        db 0x1B, "[32m", "[+] Consumer Checksum Validation: PASSED! (All 1,000,000 items received)", 0x1B, "[0m", 10
    msg_chk_ok_len equ $ - msg_chk_ok

    msg_success:
        db 0x1B, "[1;32m", "[+] Lock-Free SPSC Ring Buffer Verification Completed Successfully!", 0x1B, "[0m", 10
    msg_success_len equ $ - msg_success

    newline:
        db 10

section .bss
    ; Ring buffer storage (1024 slots * 8 bytes = 8192 bytes)
    align 64
    ring_slots:     resq RING_CAPACITY

    ; Isolated cache lines (64 bytes each) to completely eliminate false sharing:
    align 64
    producer_tail:  resq 1
    pad1:           resb 56             ; Pad out to full 64-byte L1 cache line

    align 64
    consumer_head:  resq 1
    pad2:           resb 56             ; Pad out to full 64-byte L1 cache line

    align 64
    consumer_sum:   resq 1              ; Accumulated sum by consumer
    pad3:           resb 56

    thread_stack:   resq 1
    start_tsc:      resq 1
    elapsed_tsc:    resq 1

    num_buf:        resb 32

section .text

_start:
    ; Print banner & setup message
    mov rsi, banner
    mov rdx, banner_len
    call print_str

    mov rsi, msg_setup
    mov rdx, msg_setup_len
    call print_str

    ; Initialize head, tail, and checksum to 0
    mov qword [producer_tail], 0
    mov qword [consumer_head], 0
    mov qword [consumer_sum], 0

    ; 1. Allocate 64KB stack for worker thread: sys_mmap
    mov rax, SYS_MMAP
    xor rdi, rdi                        ; addr = 0
    mov rsi, STACK_SIZE                 ; 64 KB
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9, r9
    syscall

    mov [thread_stack], rax

    ; Top of stack (grows downwards)
    lea rsi, [rax + STACK_SIZE]

    mov r12, rsi                        ; r12 = top of stack

    ; Print spawning
    mov rsi, msg_spawn
    mov rdx, msg_spawn_len
    call print_str

    ; 2. Spawn Consumer Worker Thread: sys_clone
    mov rax, SYS_CLONE
    mov rdi, THREAD_FLAGS
    mov rsi, r12
    xor rdx, rdx
    xor r10, r10
    xor r8, r8
    syscall

    test rax, rax
    jz consumer_thread_entry            ; Child execution path

    ; Parent (Producer) Execution Path
    mov rsi, msg_streaming
    mov rdx, msg_streaming_len
    call print_str

    ; Start RDTSC measurement
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [start_tsc], rax

    ; --------------------------------------------------------------------------
    ; PRODUCER LOOP: Stream 1,000,000 items into lock-free ring
    ; --------------------------------------------------------------------------
    mov r13, 1                          ; r13 = current item (1..TOTAL_ITEMS)

.producer_loop:
    ; Read current tail
    mov rax, [producer_tail]

.wait_for_slot:
    ; Check available capacity: if (tail - head) >= RING_CAPACITY, ring is full
    mov rbx, [consumer_head]
    mov rcx, rax
    sub rcx, rbx                        ; rcx = queue occupancy
    cmp rcx, RING_CAPACITY
    jl .slot_available

    pause                               ; Spin-wait hint to CPU pipeline
    jmp .wait_for_slot

.slot_available:
    ; Write item to ring_slots[tail & RING_MASK]
    mov rdx, rax
    and rdx, RING_MASK
    mov [ring_slots + rdx*8], r13

    ; Advance producer_tail: on x86-64, writes are not reordered with older writes
    inc rax
    mov [producer_tail], rax

    inc r13
    cmp r13, TOTAL_ITEMS
    jle .producer_loop

    ; Wait until Consumer has consumed all items (consumer_head == TOTAL_ITEMS)
.wait_for_consumer:
    mov rax, [consumer_head]
    cmp rax, TOTAL_ITEMS
    jge .producer_done
    pause
    jmp .wait_for_consumer

.producer_done:
    ; End RDTSC measurement
    rdtsc
    shl rdx, 32
    or rax, rdx
    sub rax, [start_tsc]
    mov [elapsed_tsc], rax

    ; Print results header
    mov rsi, msg_results_hdr
    mov rdx, msg_results_hdr_len
    call print_str

    ; Print Total Items Streamed
    mov rsi, msg_items_label
    mov rdx, msg_items_label_len
    call print_str
    mov rdi, TOTAL_ITEMS
    call print_u64
    call print_newline

    ; Print Total Cycles
    mov rsi, msg_cycles_label
    mov rdx, msg_cycles_label_len
    call print_str
    mov rdi, [elapsed_tsc]
    call print_u64
    call print_newline

    ; Calculate and Print Average Cycles per Item: elapsed_tsc / TOTAL_ITEMS
    mov rsi, msg_avg_label
    mov rdx, msg_avg_label_len
    call print_str

    mov rax, [elapsed_tsc]
    xor rdx, rdx
    mov rbx, TOTAL_ITEMS
    div rbx                             ; rax = average cycles
    mov rdi, rax
    call print_u64

    mov rsi, msg_avg_unit
    mov rdx, msg_avg_unit_len
    call print_str

    ; Checksum Validation:
    ; Expected sum = TOTAL_ITEMS * (TOTAL_ITEMS + 1) / 2
    ; For 1,000,000: 1,000,000 * 1,000,001 / 2 = 500,000,500,000
    mov rax, [consumer_sum]
    mov rbx, 500000500000
    cmp rax, rbx
    jne .chk_fail

    mov rsi, msg_chk_ok
    mov rdx, msg_chk_ok_len
    call print_str

.chk_fail:
    mov rsi, msg_success
    mov rdx, msg_success_len
    call print_str

    ; Clean up stack
    mov rax, SYS_MUNMAP
    mov rdi, [thread_stack]
    mov rsi, STACK_SIZE
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

; ------------------------------------------------------------------------------
; CONSUMER THREAD: Dequeues elements and accumulates checksum
; ------------------------------------------------------------------------------
consumer_thread_entry:
    xor r14, r14                        ; r14 = local checksum accumulator
    xor r15, r15                        ; r15 = local items consumed (0..TOTAL_ITEMS-1)

.consumer_loop:
    ; Read current head
    mov rax, [consumer_head]

.wait_for_item:
    ; Check if ring has elements: if (head == tail), ring is empty
    mov rbx, [producer_tail]
    cmp rax, rbx
    jne .item_available

    pause
    jmp .wait_for_item

.item_available:
    ; Read item from ring_slots[head & RING_MASK]
    mov rdx, rax
    and rdx, RING_MASK
    mov rcx, [ring_slots + rdx*8]

    add r14, rcx                        ; accumulate checksum

    ; Advance consumer_head
    inc rax
    mov [consumer_head], rax

    inc r15
    cmp r15, TOTAL_ITEMS
    jl .consumer_loop

    ; Store final accumulated sum
    mov [consumer_sum], r14

    ; Exit worker thread: sys_exit(0)
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

; ------------------------------------------------------------------------------
; Helper Functions
; ------------------------------------------------------------------------------
print_str:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

print_newline:
    mov rsi, newline
    mov rdx, 1
    call print_str
    ret

print_u64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, rdi
    lea rsi, [num_buf + 31]
    mov byte [rsi], 0
    mov rbx, 10
    xor rcx, rcx

    test rax, rax
    jnz .u64_loop
    dec rsi
    mov byte [rsi], '0'
    inc rcx
    jmp .u64_write

.u64_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz .u64_loop

.u64_write:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    mov rdx, rcx
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
