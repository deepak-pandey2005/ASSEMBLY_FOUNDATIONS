; ==============================================================================
; Program: cat_file.asm
; Description: Open a file on disk, read its contents, and write them to stdout
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    filename: db "sample.txt", 0        ; Null-terminated string for open()
    err_msg:  db "Error opening file!", 10
    err_len:  equ $ - err_msg

section .bss
    fd:     resq 1                      ; File descriptor returned by kernel
    buffer: resb 512                    ; Read buffer

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. OPEN FILE: sys_open(filename, flags=O_RDONLY(0), mode=0)
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; sys_open
    mov rdi, filename                   ; const char *filename
    mov rsi, 0                          ; O_RDONLY
    mov rdx, 0                          ; mode
    syscall

    ; If RAX is negative, open failed (RAX contains -errno)
    cmp rax, 0
    jl  .open_error

    mov [fd], rax                       ; Save valid file descriptor

    ; --------------------------------------------------------------------------
    ; 2. READ FILE: sys_read(fd, buffer, 512)
    ; --------------------------------------------------------------------------
    mov rax, 0                          ; sys_read
    mov rdi, [fd]                       ; fd
    mov rsi, buffer                     ; buffer
    mov rdx, 512                        ; max bytes to read
    syscall

    mov r12, rax                        ; Save bytes read in callee-saved r12

    ; --------------------------------------------------------------------------
    ; 3. WRITE TO STDOUT: sys_write(stdout, buffer, bytes_read)
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, buffer
    mov rdx, r12
    syscall

    ; --------------------------------------------------------------------------
    ; 4. CLOSE FILE: sys_close(fd)
    ; --------------------------------------------------------------------------
    mov rax, 3                          ; sys_close
    mov rdi, [fd]
    syscall

    ; Exit success
    mov rax, 60
    xor rdi, rdi
    syscall

.open_error:
    mov rax, 1
    mov rdi, 2                          ; stderr
    mov rsi, err_msg
    mov rdx, err_len
    syscall

    mov rax, 60
    mov rdi, 1                          ; Exit with error code 1
    syscall
