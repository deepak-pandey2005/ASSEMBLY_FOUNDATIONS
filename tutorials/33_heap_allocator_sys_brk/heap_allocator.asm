; ==============================================================================
; tutorials/33_heap_allocator_sys_brk/heap_allocator.asm
; Custom Dynamic Heap Allocator (malloc and free) in Pure x86-64 Assembly.
;
; Uses sys_brk (Syscall 12) to expand the program break and manages
; allocated/freed blocks using a metadata linked list header:
;
; Header Layout (24 bytes):
;   offset 0  : uint64_t size       ; Payload size (bytes)
;   offset 8  : uint64_t is_free    ; 1 = free, 0 = allocated
;   offset 16 : void* next          ; Pointer to next chunk header (or 0)
; ==============================================================================

global _start

%define SYS_WRITE 1
%define SYS_BRK   12
%define SYS_EXIT  60
%define STDOUT    1

; Size of our block header metadata (3 * 8 bytes = 24 bytes)
%define HEADER_SIZE 24

section .data
    title_msg       db "+================================================+", 10
                    db "|    CUSTOM HEAP MEMORY ALLOCATOR (sys_brk)      |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_msg

    msg_init_brk    db "[+] Initial process program break address: 0x"
    len_init_brk    equ $ - msg_init_brk

    msg_alloc_1     db "[+] asm_malloc(64): Allocated 64 bytes at payload address: 0x"
    len_alloc_1     equ $ - msg_alloc_1

    msg_alloc_2     db "[+] asm_malloc(128): Allocated 128 bytes at payload address: 0x"
    len_alloc_2     equ $ - msg_alloc_2

    msg_free_1      db "[+] asm_free(ptr1): Marked block 1 as FREE in linked list metadata.", 10
    len_free_1      equ $ - msg_free_1

    msg_alloc_reuse db "[+] asm_malloc(32): Reused freed block 1 without expanding heap break!", 10
    len_alloc_reuse equ $ - msg_alloc_reuse

    msg_verify_ok   db "[+] Heap allocation, reuse, and write verification PASSED!", 10
    len_verify_ok   equ $ - msg_verify_ok

    newline         db 10

    ; Head of our linked list of heap chunks
    align 8
    heap_head       dq 0
    current_brk     dq 0

section .bss
    hex_buf         resb 16

section .text

_start:
    ; Print Title Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel title_msg]
    mov     rdx, len_title
    syscall

    ; 1. Query initial program break: sys_brk(0)
    mov     rax, SYS_BRK
    xor     rdi, rdi                    ; Passing 0 returns current break address
    syscall
    mov     [rel current_brk], rax

    ; Print initial break address
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_init_brk]
    mov     rdx, len_init_brk
    syscall

    mov     rax, [rel current_brk]
    lea     rdi, [rel hex_buf]
    call    to_hex_str

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel hex_buf]
    mov     rdx, 16
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Test Case 1: Allocate first chunk of 64 bytes
    ; --------------------------------------------------------------------------
    mov     rdi, 64
    call    asm_malloc
    mov     r12, rax                    ; r12 = ptr1

    ; Verify writing to allocated heap payload
    mov     dword [r12], 0x41424344     ; "DCBA"

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_alloc_1]
    mov     rdx, len_alloc_1
    syscall

    mov     rax, r12
    lea     rdi, [rel hex_buf]
    call    to_hex_str

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel hex_buf]
    mov     rdx, 16
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Test Case 2: Allocate second chunk of 128 bytes
    ; --------------------------------------------------------------------------
    mov     rdi, 128
    call    asm_malloc
    mov     r13, rax                    ; r13 = ptr2

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_alloc_2]
    mov     rdx, len_alloc_2
    syscall

    mov     rax, r13
    lea     rdi, [rel hex_buf]
    call    to_hex_str

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel hex_buf]
    mov     rdx, 16
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Test Case 3: Free first chunk (ptr1)
    ; --------------------------------------------------------------------------
    mov     rdi, r12
    call    asm_free

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_free_1]
    mov     rdx, len_free_1
    syscall

    ; --------------------------------------------------------------------------
    ; Test Case 4: Allocate 32 bytes (should fit inside freed 64-byte block 1!)
    ; --------------------------------------------------------------------------
    mov     rdi, 32
    call    asm_malloc
    mov     r14, rax                    ; r14 = ptr3

    ; If allocator properly reused block 1, r14 must equal r12!
    cmp     r14, r12
    jne     .error_reuse

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_alloc_reuse]
    mov     rdx, len_alloc_reuse
    syscall

    ; Print success confirmation
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_verify_ok]
    mov     rdx, len_verify_ok
    syscall

    ; Exit cleanly
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

.error_reuse:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

; ==============================================================================
; asm_malloc(uint64_t size) -> void* payload_ptr
; Input:  RDI = size of requested payload in bytes
; Output: RAX = pointer to allocated memory payload (or 0 if failed)
; ==============================================================================
asm_malloc:
    push    rbx
    push    r12
    push    r13

    ; Align requested size up to an 8-byte boundary
    add     rdi, 7
    and     rdi, ~7
    mov     r12, rdi                    ; r12 = aligned requested size

    ; 1. Search free-list starting at heap_head
    mov     rbx, [rel heap_head]
    xor     r13, r13                    ; r13 will track the last visited block (for linking)

.search_loop:
    test    rbx, rbx
    jz      .no_free_block_found

    ; Check if current block is free: [rbx + 8] == 1
    cmp     qword [rbx + 8], 1
    jne     .next_block

    ; Check if current block is large enough: [rbx] >= r12
    cmp     qword [rbx], r12
    jae     .reuse_found

.next_block:
    mov     r13, rbx                    ; Track tail block
    mov     rbx, [rbx + 16]             ; rbx = rbx->next
    jmp     .search_loop

.reuse_found:
    ; Mark as in-use
    mov     qword [rbx + 8], 0          ; is_free = 0
    lea     rax, [rbx + HEADER_SIZE]    ; Return payload pointer
    jmp     .malloc_done

.no_free_block_found:
    ; We need to expand the heap via sys_brk!
    ; New program break = current_brk + HEADER_SIZE + requested_size
    mov     rax, [rel current_brk]
    mov     rbx, rax                    ; rbx = old break (start of new chunk header)

    lea     rdi, [rax + HEADER_SIZE + r12]
    mov     rax, SYS_BRK
    syscall

    ; Check if sys_brk succeeded (returned address should equal new requested break)
    cmp     rax, rdi
    jne     .malloc_failed

    ; Update current_brk record
    mov     [rel current_brk], rax

    ; Initialize new block header at rbx:
    mov     [rbx + 0], r12              ; size
    mov     qword [rbx + 8], 0          ; is_free = 0
    mov     qword [rbx + 16], 0         ; next = NULL

    ; Link into the linked list
    test    r13, r13
    jz      .set_head
    mov     [r13 + 16], rbx             ; tail->next = new_block
    jmp     .return_new_payload

.set_head:
    mov     [rel heap_head], rbx

.return_new_payload:
    lea     rax, [rbx + HEADER_SIZE]
    jmp     .malloc_done

.malloc_failed:
    xor     rax, rax

.malloc_done:
    pop     r13
    pop     r12
    pop     rbx
    ret

; ==============================================================================
; asm_free(void* payload_ptr)
; Input: RDI = pointer to memory returned by asm_malloc
; ==============================================================================
asm_free:
    test    rdi, rdi
    jz      .free_done

    ; Locate header: payload_ptr - HEADER_SIZE
    lea     rax, [rdi - HEADER_SIZE]
    mov     qword [rax + 8], 1          ; Set is_free = 1

.free_done:
    ret

; ==============================================================================
; Helper: Convert 64-bit value in RAX to 16 hex characters in buffer RDI
; ==============================================================================
to_hex_str:
    mov     rcx, 16
.hex_loop:
    rol     rax, 4
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
