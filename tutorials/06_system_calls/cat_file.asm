; ==============================================================================
; Program: cat_file.asm
; Description: Open a file on disk, read its contents, and write them to stdout
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <fcntl.h>
; #include <unistd.h>
; #include <stdlib.h>
;
; int main(void) {
;     const char filename[] = "sample.txt";
;     char buffer[512];
;
;     // 1. Open file
;     int fd = open(filename, O_RDONLY);
;     if (fd < 0) {
;         write(STDERR_FILENO, "Error opening file!\n", 20);
;         _exit(1);
;     }
;
;     // 2. Read from file
;     ssize_t bytes_read = read(fd, buffer, sizeof(buffer));
;
;     // 3. Write to stdout
;     if (bytes_read > 0) {
;         write(STDOUT_FILENO, buffer, bytes_read);
;     }
;
;     // 4. Close file
;     close(fd);
;
;     _exit(0);
; }
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
    ; 1. OPEN FILE
    ; C equivalent: int fd = open("sample.txt", O_RDONLY, 0);
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; rax = SYS_open (2)
    mov rdi, filename                   ; rdi = "sample.txt" (const char *pathname)
    mov rsi, 0                          ; rsi = O_RDONLY (flags = 0)
    mov rdx, 0                          ; rdx = mode (0)
    syscall

    ; In Linux syscalls, negative return value (-1..-4095) indicates -errno
    ; C equivalent: if (fd < 0) goto open_error;
    cmp rax, 0
    jl  .open_error

    mov [fd], rax                       ; fd = rax;

    ; --------------------------------------------------------------------------
    ; 2. READ FILE
    ; C equivalent: ssize_t bytes_read = read(fd, buffer, 512);
    ; --------------------------------------------------------------------------
    mov rax, 0                          ; rax = SYS_read (0)
    mov rdi, [fd]                       ; rdi = int fd
    mov rsi, buffer                     ; rsi = void *buf (&buffer[0])
    mov rdx, 512                        ; rdx = size_t count (512)
    syscall

    mov r12, rax                        ; ssize_t bytes_read = rax (saved in r12)

    ; --------------------------------------------------------------------------
    ; 3. WRITE TO STDOUT
    ; C equivalent: write(STDOUT_FILENO, buffer, bytes_read);
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; rax = SYS_write (1)
    mov rdi, 1                          ; rdi = STDOUT_FILENO (1)
    mov rsi, buffer                     ; rsi = &buffer[0]
    mov rdx, r12                        ; rdx = bytes_read
    syscall

    ; --------------------------------------------------------------------------
    ; 4. CLOSE FILE
    ; C equivalent: close(fd);
    ; --------------------------------------------------------------------------
    mov rax, 3                          ; rax = SYS_close (3)
    mov rdi, [fd]                       ; rdi = int fd
    syscall

    ; Clean exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall

.open_error:
    ; --------------------------------------------------------------------------
    ; Error Handler
    ; C equivalent: write(2, err_msg, err_len); _exit(1);
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, 2                          ; stderr (2)
    mov rsi, err_msg
    mov rdx, err_len
    syscall

    mov rax, 60                         ; sys_exit
    mov rdi, 1                          ; status = 1 (failure)
    syscall
