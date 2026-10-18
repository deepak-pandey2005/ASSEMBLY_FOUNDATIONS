; ==============================================================================
; Program: mmap_allocator.asm
; Description: Custom dynamic memory allocation and deallocation using raw mmap/munmap
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    msg_alloc: db "[+] Successfully mapped 4096 bytes via sys_mmap!", 10
    len_alloc: equ $ - msg_alloc

    msg_freed: db "[+] Successfully unmapped memory via sys_munmap!", 10
    len_freed: equ $ - msg_freed

section .bss
    allocated_ptr: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. ALLOCATE 1 PAGE (4096 BYTES) ANONYMOUS MEMORY
    ; sys_mmap(addr=0, len=4096, prot=PROT_READ|PROT_WRITE, flags=MAP_ANON|MAP_PRIVATE, fd=-1, off=0)
    ; --------------------------------------------------------------------------
    mov rax, 9                  ; sys_mmap
    xor rdi, rdi                ; addr = NULL (kernel selects address)
    mov rsi, 4096               ; length = 1 page (4096 bytes)
    mov rdx, 3                  ; prot = PROT_READ (1) | PROT_WRITE (2)
    mov r10, 34                 ; flags = MAP_PRIVATE (0x02) | MAP_ANONYMOUS (0x20)
    mov r8, -1                  ; fd = -1
    xor r9, r9                  ; offset = 0
    syscall

    ; Check if mmap failed (RAX < 0)
    cmp rax, 0
    jl  .error

    mov [allocated_ptr], rax    ; Store mapped pointer

    ; Print allocation success message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_alloc
    mov rdx, len_alloc
    syscall

    ; --------------------------------------------------------------------------
    ; 2. WRITE AND READ DATA IN THE DYNAMICALLY ALLOCATED MEMORY
    ; --------------------------------------------------------------------------
    mov rbx, [allocated_ptr]
    mov dword [rbx], 0x41424344 ; Store "DCBA" (little endian)
    mov dword [rbx + 4], 0x0A21 ; Store "!\n"

    ; Write the data from the mmap page to stdout
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, [allocated_ptr]    ; pointer to our allocated page
    mov rdx, 6                  ; 6 bytes
    syscall

    ; --------------------------------------------------------------------------
    ; 3. DEALLOCATE / FREE MEMORY: sys_munmap(addr, len)
    ; --------------------------------------------------------------------------
    mov rax, 11                 ; sys_munmap
    mov rdi, [allocated_ptr]    ; pointer to unmap
    mov rsi, 4096               ; length
    syscall

    ; Print freed message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_freed
    mov rdx, len_freed
    syscall

    ; Exit success
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1                  ; Exit with error code 1
    syscall
