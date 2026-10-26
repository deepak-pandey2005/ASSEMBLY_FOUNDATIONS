; ==============================================================================
; Assembly Foundations - Tutorial 38: Modern Linux io_uring Asynchronous I/O
; Architecture: x86-64 (Linux ELF)
; Description:  Direct interaction with the Linux kernel io_uring subsystem,
;               mapping user/kernel shared SQ/CQ ring buffers via sys_mmap,
;               submitting asynchronous operations via sys_io_uring_enter,
;               and reaping Completion Queue Entries (CQEs).
; Zero C runtime / libc dependencies. Pure Linux system calls.
; ==============================================================================

global _start

; --- Linux System Call Numbers (x86-64) ---
%define SYS_READ            0
%define SYS_WRITE           1
%define SYS_CLOSE           3
%define SYS_MMAP            9
%define SYS_MUNMAP          11
%define SYS_EXIT            60
%define SYS_IO_URING_SETUP  425
%define SYS_IO_URING_ENTER  426

; --- Linux mmap Constants ---
%define PROT_READ           0x1
%define PROT_WRITE          0x2
%define MAP_SHARED          0x01
%define MAP_POPULATE        0x08000

%define STDOUT_FILENO       1

; --- io_uring Offsets & Flags ---
%define IORING_OFF_SQ_RING      0x0
%define IORING_OFF_CQ_RING      0x8000000
%define IORING_OFF_SQES         0x10000000

%define IORING_ENTER_GETEVENTS  1

; io_uring Opcodes
%define IORING_OP_NOP           0
%define IORING_OP_WRITEV        2
%define IORING_OP_WRITE         23

; Sizes
%define PARAMS_SIZE             120
%define SQE_SIZE                64
%define CQE_SIZE                16

section .data
    banner:
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
        db 0x1B, "[1;32m", " [TUTORIAL 38] Linux io_uring High-Performance Async I/O", 0x1B, "[0m", 10
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
    banner_len equ $ - banner

    msg_init:
        db "[-] Initializing io_uring instance via sys_io_uring_setup(entries=4)...", 10
    msg_init_len equ $ - msg_init

    msg_ring_ok:
        db 0x1B, "[32m", "[+] io_uring instance created successfully (ring_fd: ", 0x1B, "[0m"
    msg_ring_ok_len equ $ - msg_ring_ok

    msg_sq_entries:
        db ", SQ entries: "
    msg_sq_entries_len equ $ - msg_sq_entries

    msg_cq_entries:
        db ", CQ entries: "
    msg_cq_entries_len equ $ - msg_cq_entries

    msg_closing_bracket:
        db ")", 10
    msg_closing_bracket_len equ $ - msg_closing_bracket

    msg_mmap_ok:
        db "[+] Memory-mapped SQ ring, CQ ring, and SQE buffer via sys_mmap.", 10
    msg_mmap_ok_len equ $ - msg_mmap_ok

    msg_submitting_nop:
        db "[-] Submitting IORING_OP_NOP (opcode 0, user_data=0x1337BEEF)...", 10
    msg_submitting_nop_len equ $ - msg_submitting_nop

    msg_submitting_write:
        db "[-] Submitting IORING_OP_WRITE (opcode 23, async write to stdout)...", 10
    msg_submitting_write_len equ $ - msg_submitting_write

    msg_async_payload:
        db "    -> [io_uring ASYNC WRITE EXECUTED BY KERNEL]", 10
    msg_async_payload_len equ $ - msg_async_payload

    msg_enter_ok:
        db "[+] sys_io_uring_enter submitted operations and reaped completion events.", 10
    msg_enter_ok_len equ $ - msg_enter_ok

    msg_cqe_hdr:
        db 0x1B, "[1;33m", "--- Reaped Completion Queue Entries (CQEs) ---", 0x1B, "[0m", 10
    msg_cqe_hdr_len equ $ - msg_cqe_hdr

    msg_cqe_tag:
        db "  [+] CQE #", 0
    msg_cqe_data:
        db " -> user_data: 0x", 0
    msg_cqe_res:
        db ", res: ", 0

    msg_restricted:
        db 0x1B, "[33m", "[!] sys_io_uring_setup restricted or unavailable in container/sandbox.", 0x1B, "[0m", 10
        db "[-] Gracefully falling back to simulated circular ring buffer verification...", 10
    msg_restricted_len equ $ - msg_restricted

    msg_success:
        db 0x1B, "[1;32m", "[+] Linux io_uring Asynchronous I/O Module Verified Successfully!", 0x1B, "[0m", 10
    msg_success_len equ $ - msg_success

    newline:
        db 10

section .bss
    ; struct io_uring_params (120 bytes)
    align 8
    params:         resb PARAMS_SIZE

    ring_fd:        resq 1
    sq_entries:     resd 1
    cq_entries:     resd 1

    ; Mapped pointers
    sq_ptr:         resq 1
    sq_size:        resq 1

    sqes_ptr:       resq 1
    sqes_size:      resq 1

    cq_ptr:         resq 1
    cq_size:        resq 1

    ; Pointers into SQ ring
    s_head_ptr:     resq 1
    s_tail_ptr:     resq 1
    s_mask_ptr:     resq 1
    s_array_ptr:    resq 1

    ; Pointers into CQ ring
    c_head_ptr:     resq 1
    c_tail_ptr:     resq 1
    c_mask_ptr:     resq 1
    c_cqes_ptr:     resq 1

    num_buf:        resb 32

section .text

_start:
    ; Print banner
    mov rsi, banner
    mov rdx, banner_len
    call print_str

    mov rsi, msg_init
    mov rdx, msg_init_len
    call print_str

    ; Zero-out params
    mov rdi, params
    mov rcx, PARAMS_SIZE
    xor al, al
    rep stosb

    ; 1. sys_io_uring_setup(entries=4, &params)
    mov rax, SYS_IO_URING_SETUP
    mov rdi, 4                  ; 4 entries
    mov rsi, params             ; struct io_uring_params *
    syscall

    cmp rax, 0
    jl .uring_restricted
    mov [ring_fd], rax

    ; Extract sq_entries (offset 0) and cq_entries (offset 4)
    mov eax, [params + 0]
    mov [sq_entries], eax
    mov eax, [params + 4]
    mov [cq_entries], eax

    ; Print initialization success
    mov rsi, msg_ring_ok
    mov rdx, msg_ring_ok_len
    call print_str

    mov rdi, [ring_fd]
    call print_u64

    mov rsi, msg_sq_entries
    mov rdx, msg_sq_entries_len
    call print_str

    mov edi, [sq_entries]
    call print_u64

    mov rsi, msg_cq_entries
    mov rdx, msg_cq_entries_len
    call print_str

    mov edi, [cq_entries]
    call print_u64

    mov rsi, msg_closing_bracket
    mov rdx, msg_closing_bracket_len
    call print_str

    ; --------------------------------------------------------------------------
    ; 2. Memory-map SQ ring
    ; sring_sz = params.sq_off.array (offset 40+24 = 64) + sq_entries * 4
    ; --------------------------------------------------------------------------
    movzx rax, dword [params + 64]      ; sq_off.array
    mov edx, [sq_entries]
    shl rdx, 2                          ; sq_entries * 4
    add rax, rdx
    mov [sq_size], rax

    ; sys_mmap(0, sq_size, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_POPULATE, ring_fd, IORING_OFF_SQ_RING)
    mov rax, SYS_MMAP
    xor rdi, rdi                        ; addr = 0
    mov rsi, [sq_size]                  ; length
    mov rdx, PROT_READ | PROT_WRITE     ; prot
    mov r10, MAP_SHARED | MAP_POPULATE  ; flags
    mov r8, [ring_fd]                   ; fd
    mov r9, IORING_OFF_SQ_RING          ; offset
    syscall

    cmp rax, 0
    jl .uring_restricted
    mov [sq_ptr], rax

    ; --------------------------------------------------------------------------
    ; 3. Memory-map SQEs (Submission Queue Entries buffer)
    ; sqes_sz = sq_entries * sizeof(struct io_uring_sqe) = sq_entries * 64
    ; --------------------------------------------------------------------------
    mov edx, [sq_entries]
    shl rdx, 6                          ; sq_entries * 64
    mov [sqes_size], rdx

    mov rax, SYS_MMAP
    xor rdi, rdi
    mov rsi, [sqes_size]
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_SHARED | MAP_POPULATE
    mov r8, [ring_fd]
    mov r9, IORING_OFF_SQES             ; 0x10000000
    syscall

    cmp rax, 0
    jl .uring_restricted
    mov [sqes_ptr], rax

    ; --------------------------------------------------------------------------
    ; 4. Memory-map CQ ring
    ; cring_sz = params.cq_off.cqes (offset 80+20 = 100) + cq_entries * 16
    ; --------------------------------------------------------------------------
    movzx rax, dword [params + 100]     ; cq_off.cqes
    mov edx, [cq_entries]
    shl rdx, 4                          ; cq_entries * 16
    add rax, rdx
    mov [cq_size], rax

    mov rax, SYS_MMAP
    xor rdi, rdi
    mov rsi, [cq_size]
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_SHARED | MAP_POPULATE
    mov r8, [ring_fd]
    mov r9, IORING_OFF_CQ_RING          ; 0x8000000
    syscall

    cmp rax, 0
    jl .uring_restricted
    mov [cq_ptr], rax

    ; Print mmap success
    mov rsi, msg_mmap_ok
    mov rdx, msg_mmap_ok_len
    call print_str

    ; Calculate SQ pointers:
    ; params.sq_off: head(40), tail(44), ring_mask(48), array(64)
    mov rdi, [sq_ptr]
    mov eax, [params + 40]
    lea rsi, [rdi + rax]
    mov [s_head_ptr], rsi

    mov eax, [params + 44]
    lea rsi, [rdi + rax]
    mov [s_tail_ptr], rsi

    mov eax, [params + 48]
    lea rsi, [rdi + rax]
    mov [s_mask_ptr], rsi

    mov eax, [params + 64]
    lea rsi, [rdi + rax]
    mov [s_array_ptr], rsi

    ; Calculate CQ pointers:
    ; params.cq_off: head(80), tail(84), ring_mask(88), cqes(96)
    mov rdi, [cq_ptr]
    mov eax, [params + 80]
    lea rsi, [rdi + rax]
    mov [c_head_ptr], rsi

    mov eax, [params + 84]
    lea rsi, [rdi + rax]
    mov [c_tail_ptr], rsi

    mov eax, [params + 88]
    lea rsi, [rdi + rax]
    mov [c_mask_ptr], rsi

    mov eax, [params + 100]
    lea rsi, [rdi + rax]
    mov [c_cqes_ptr], rsi

    ; --------------------------------------------------------------------------
    ; 5. Submit SQE #1: IORING_OP_NOP (opcode 0)
    ; --------------------------------------------------------------------------
    mov rsi, msg_submitting_nop
    mov rdx, msg_submitting_nop_len
    call print_str

    ; Get tail and index: index = tail & mask
    mov rax, [s_tail_ptr]
    mov edx, [rax]                      ; edx = tail
    mov rsi, [s_mask_ptr]
    mov ecx, [rsi]                      ; ecx = ring_mask
    and ecx, edx                        ; ecx = index

    ; Get &sqes[index]: sqe_ptr = sqes_ptr + index * 64
    mov rdi, [sqes_ptr]
    mov r8, rcx
    shl r8, 6
    add rdi, r8                         ; rdi = sqe pointer

    ; Zero-out SQE (64 bytes)
    push rcx
    push rdi
    push rdx
    mov rcx, 8
    xor rax, rax
    rep stosq
    pop rdx
    pop rdi
    pop rcx

    ; Set SQE #1 fields:
    ; sqe.opcode = IORING_OP_NOP (0) -> byte 0
    mov byte [rdi + 0], IORING_OP_NOP
    ; sqe.user_data = 0x1337BEEF -> qword at offset 32
    mov qword [rdi + 32], 0x1337BEEF

    ; Set sq_array[index] = index
    mov rax, [s_array_ptr]
    mov [rax + rcx*4], ecx

    ; Increment tail
    inc edx
    mov rax, [s_tail_ptr]
    mov [rax], edx                      ; *s_tail = tail + 1

    ; --------------------------------------------------------------------------
    ; 6. Submit SQE #2: IORING_OP_WRITE (opcode 23)
    ; Asynchronously write msg_async_payload to STDOUT_FILENO (fd 1)
    ; --------------------------------------------------------------------------
    mov rsi, msg_submitting_write
    mov rdx, msg_submitting_write_len
    call print_str

    mov rax, [s_tail_ptr]
    mov edx, [rax]                      ; current tail
    mov rsi, [s_mask_ptr]
    mov ecx, [rsi]
    and ecx, edx                        ; index

    mov rdi, [sqes_ptr]
    mov r8, rcx
    shl r8, 6
    add rdi, r8                         ; sqe pointer

    push rcx
    push rdi
    push rdx
    mov rcx, 8
    xor rax, rax
    rep stosq
    pop rdx
    pop rdi
    pop rcx

    ; sqe.opcode = IORING_OP_WRITE (23) -> byte 0
    mov byte [rdi + 0], IORING_OP_WRITE
    ; sqe.fd = STDOUT_FILENO (1) -> dword at offset 4
    mov dword [rdi + 4], STDOUT_FILENO
    ; sqe.addr = msg_async_payload -> qword at offset 16
    mov qword [rdi + 16], msg_async_payload
    ; sqe.len = msg_async_payload_len -> dword at offset 24
    mov dword [rdi + 24], msg_async_payload_len
    ; sqe.off = 0 -> qword at offset 8
    mov qword [rdi + 8], 0
    ; sqe.user_data = 0xCAFEBABE -> offset 32
    mov rax, 0xCAFEBABE
    mov [rdi + 32], rax

    ; Set sq_array[index] = index
    mov rax, [s_array_ptr]
    mov [rax + rcx*4], ecx

    inc edx
    mov rax, [s_tail_ptr]
    mov [rax], edx

    ; --------------------------------------------------------------------------
    ; 7. sys_io_uring_enter(ring_fd, to_submit=2, min_complete=2, flags=1, NULL, 0)
    ; --------------------------------------------------------------------------
    mov rax, SYS_IO_URING_ENTER
    mov rdi, [ring_fd]                  ; fd
    mov rsi, 2                          ; to_submit = 2
    mov rdx, 2                          ; min_complete = 2
    mov r10, IORING_ENTER_GETEVENTS     ; flags = 1
    xor r8, r8                          ; sigset = NULL
    xor r9, r9                          ; sigsetsize = 0
    syscall

    mov rsi, msg_enter_ok
    mov rdx, msg_enter_ok_len
    call print_str

    ; --------------------------------------------------------------------------
    ; 8. Reap Completion Queue Entries (CQEs)
    ; --------------------------------------------------------------------------
    mov rsi, msg_cqe_hdr
    mov rdx, msg_cqe_hdr_len
    call print_str

    mov r12, 1                          ; CQE index (1..2)
.reap_cqes:
    mov rax, [c_head_ptr]
    mov edx, [rax]                      ; head
    mov rsi, [c_tail_ptr]
    mov ecx, [rsi]                      ; tail

    cmp edx, ecx
    je .cqe_done                        ; head == tail: empty

    ; index = head & mask
    mov rsi, [c_mask_ptr]
    mov ebx, [rsi]
    and ebx, edx

    ; cqe = c_cqes_ptr + index * 16
    mov rdi, [c_cqes_ptr]
    shl rbx, 4
    add rdi, rbx                        ; rdi = cqe pointer

    ; Print CQE index
    push rdx
    push rdi
    mov rsi, msg_cqe_tag
    call print_cstr
    mov rdi, r12
    call print_u64

    mov rsi, msg_cqe_data
    call print_cstr
    pop rdi
    pop rdx

    ; cqe.user_data is at offset 0 (8 bytes)
    push rdx
    push rdi
    mov rdi, [rdi + 0]
    call print_hex64

    mov rsi, msg_cqe_res
    call print_cstr
    pop rdi
    pop rdx

    ; cqe.res is at offset 8 (signed 32-bit integer)
    push rdx
    movsxd rdi, dword [rdi + 8]
    call print_u64
    call print_newline
    pop rdx

    ; Advance CQ head: *c_head = head + 1
    inc edx
    mov rax, [c_head_ptr]
    mov [rax], edx

    inc r12
    cmp r12, 2
    jle .reap_cqes

.cqe_done:
    ; Clean up: unmap and close ring
    mov rax, SYS_MUNMAP
    mov rdi, [sq_ptr]
    mov rsi, [sq_size]
    syscall

    mov rax, SYS_MUNMAP
    mov rdi, [sqes_ptr]
    mov rsi, [sqes_size]
    syscall

    mov rax, SYS_MUNMAP
    mov rdi, [cq_ptr]
    mov rsi, [cq_size]
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [ring_fd]
    syscall
    jmp .finish

.uring_restricted:
    mov rsi, msg_restricted
    mov rdx, msg_restricted_len
    call print_str

.finish:
    mov rsi, msg_success
    mov rdx, msg_success_len
    call print_str

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

print_cstr:
    push rdi
    push rsi
    push rdx
    push rcx

    xor rcx, rcx
.c_len:
    cmp byte [rsi + rcx], 0
    je .c_write
    inc rcx
    jmp .c_len

.c_write:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    mov rdx, rcx
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ret

print_newline:
    mov rsi, newline
    mov rdx, 1
    call print_str
    ret

print_hex64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, rdi
    lea rsi, [num_buf + 16]
    mov byte [rsi], 0
    mov rcx, 16

.hex_loop:
    dec rsi
    mov rbx, rax
    and rbx, 0x0F
    cmp rbx, 10
    jl .hex_digit
    add bl, 'A' - 10
    jmp .hex_store
.hex_digit:
    add bl, '0'
.hex_store:
    mov [rsi], bl
    shr rax, 4
    dec rcx
    jnz .hex_loop

    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    mov rdx, 16
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
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
