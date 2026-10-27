; ==============================================================================
; Program: mmap_allocator.asm
; Description: Custom dynamic memory allocation and deallocation using raw mmap/munmap
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <sys/mman.h>
; #include <unistd.h>
; #include <string.h>
;
; int main(void) {
;     // 1. Allocate 1 page (4096 bytes) anonymous memory
;     void *ptr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
;                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
;     if (ptr == MAP_FAILED) {
;         write(STDERR_FILENO, "Error during mmap!\n", 19);
;         _exit(1);
;     }
;
;     write(STDOUT_FILENO, "[+] Successfully mapped 4096 bytes via sys_mmap!\n", 50);
;
;     // 2. Write and read data
;     char *buf = (char *)ptr;
;     memcpy(buf, "DCBA!\n", 6);
;     write(STDOUT_FILENO, ptr, 6);
;
;     // 3. Deallocate memory
;     munmap(ptr, 4096);
;     write(STDOUT_FILENO, "[+] Successfully unmapped memory via sys_munmap!\n", 50);
;
;     _exit(0);
; }
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
    ; C equivalent:
    ;   void *ptr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
    ;                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    ;
    ; Syscall argument registers:
    ;   rax = 9 (SYS_mmap)
    ;   rdi = addr (NULL: 0)
    ;   rsi = length (4096)
    ;   rdx = prot (PROT_READ(1) | PROT_WRITE(2) = 3)
    ;   r10 = flags (MAP_PRIVATE(0x02) | MAP_ANONYMOUS(0x20) = 0x22 / 34)
    ;   r8  = fd (-1)
    ;   r9  = offset (0)
    ; --------------------------------------------------------------------------
    mov rax, 9                  ; rax = SYS_mmap (9)
    xor rdi, rdi                ; rdi = NULL (kernel decides address)
    mov rsi, 4096               ; rsi = 4096 bytes (1 page)
    mov rdx, 3                  ; rdx = PROT_READ | PROT_WRITE
    mov r10, 34                 ; r10 = MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                  ; r8  = -1 (no backing file)
    xor r9, r9                  ; r9  = 0 offset
    syscall

    ; Check if mmap failed (RAX < 0)
    cmp rax, 0
    jl  .error

    mov [allocated_ptr], rax    ; allocated_ptr = ptr;

    ; Print allocation success message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_alloc
    mov rdx, len_alloc
    syscall

    ; --------------------------------------------------------------------------
    ; 2. WRITE AND READ DATA IN THE DYNAMICALLY ALLOCATED MEMORY
    ; C equivalent:
    ;   char *buf = (char *)ptr;
    ;   *(uint32_t *)buf = 0x41424344; // "DCBA"
    ;   *(uint16_t *)(buf + 4) = 0x0A21; // "!\n"
    ;   write(1, ptr, 6);
    ; --------------------------------------------------------------------------
    mov rbx, [allocated_ptr]
    mov dword [rbx], 0x41424344 ; Store "DCBA" (little endian)
    mov word [rbx + 4], 0x0A21  ; Store "!\n"

    ; Write the data from the mmap page to stdout
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, [allocated_ptr]    ; pointer to our allocated page
    mov rdx, 6                  ; 6 bytes
    syscall

    ; --------------------------------------------------------------------------
    ; 3. DEALLOCATE MEMORY: sys_munmap(allocated_ptr, 4096)
    ; C equivalent:
    ;   munmap(ptr, 4096);
    ; --------------------------------------------------------------------------
    mov rax, 11                 ; rax = SYS_munmap (11)
    mov rdi, [allocated_ptr]    ; rdi = pointer to unmap
    mov rsi, 4096               ; rsi = length
    syscall

    ; Print freed confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_freed
    mov rdx, len_freed
    syscall

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1                  ; exit status 1 (error)
    syscall
