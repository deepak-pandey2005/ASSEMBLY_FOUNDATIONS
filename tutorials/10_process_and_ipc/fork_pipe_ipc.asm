; ==============================================================================
; Program: fork_pipe_ipc.asm
; Description: Process creation via fork() and Inter-Process Communication via pipe()
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <sys/wait.h>
; #include <string.h>
;
; int main(void) {
;     int pipefds[2];
;     pipe(pipefds); // pipefds[0] = read fd, pipefds[1] = write fd
;
;     pid_t pid = fork();
;     if (pid == 0) {
;         // --- CHILD PROCESS ---
;         close(pipefds[0]); // Close unused read-end
;         const char msg[] = "Hello from Child process across the kernel pipe!\n";
;         write(pipefds[1], msg, sizeof(msg) - 1);
;         close(pipefds[1]);
;         _exit(0);
;     } else {
;         // --- PARENT PROCESS ---
;         close(pipefds[1]); // Close unused write-end
;         char read_buf[128];
;         ssize_t bytes_in = read(pipefds[0], read_buf, sizeof(read_buf));
;         close(pipefds[0]);
;
;         write(STDOUT_FILENO, "[Parent received]: ", 19);
;         if (bytes_in > 0) {
;             write(STDOUT_FILENO, read_buf, bytes_in);
;         }
;         waitpid(pid, NULL, 0); // Wait for child
;         _exit(0);
;     }
; }
; ==============================================================================

section .data
    msg_child:  db "Hello from Child process across the kernel pipe!", 10
    len_child:  equ $ - msg_child

    parent_hdr: db "[Parent received]: "
    parent_len: equ $ - parent_hdr

section .bss
    pipefds:   resd 2           ; pipefds[0] = read fd, pipefds[1] = write fd (4 bytes each)
    read_buf:  resb 128
    bytes_in:  resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. CREATE PIPE
    ; C equivalent: int pipefds[2]; pipe(pipefds);
    ; --------------------------------------------------------------------------
    mov rax, 22                 ; rax = SYS_pipe (22)
    mov rdi, pipefds            ; rdi = int pipefd[2]
    syscall

    ; --------------------------------------------------------------------------
    ; 2. FORK PROCESS
    ; C equivalent: pid_t pid = fork();
    ; --------------------------------------------------------------------------
    mov rax, 57                 ; rax = SYS_fork (57)
    syscall

    cmp rax, 0
    je  .child_code             ; if (pid == 0) goto child_code;
    ; Otherwise, pid > 0 (child PID), we are in the parent!

.parent_code:
    ; --------------------------------------------------------------------------
    ; PARENT PROCESS LOGIC
    ; C equivalent:
    ;   close(pipefds[1]);
    ;   ssize_t bytes_in = read(pipefds[0], read_buf, 128);
    ;   close(pipefds[0]);
    ; --------------------------------------------------------------------------
    ; Close unused write-end in parent
    mov rax, 3                  ; sys_close
    mov edi, [pipefds + 4]      ; int fd = pipefds[1] (write end)
    syscall

    ; Read message sent by child from read-end
    mov rax, 0                  ; sys_read
    mov edi, [pipefds]          ; int fd = pipefds[0] (read end)
    mov rsi, read_buf           ; buffer
    mov rdx, 128                ; max count
    syscall
    mov [bytes_in], rax         ; bytes_in = rax;

    ; Print parent header "[Parent received]: "
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, parent_hdr
    mov rdx, parent_len
    syscall

    ; Print message received through pipe
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, read_buf
    mov rdx, [bytes_in]
    syscall

    ; Close read-end
    mov rax, 3
    mov edi, [pipefds]
    syscall

    ; Wait for child to exit: sys_wait4(-1, 0, 0, 0)
    ; C equivalent: wait(NULL);
    mov rax, 61                 ; sys_wait4
    mov rdi, -1                 ; pid = -1 (any child)
    xor rsi, rsi                ; status = NULL
    xor rdx, rdx                ; options = 0
    xor r10, r10                ; rusage = NULL
    syscall

    ; Parent exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall

.child_code:
    ; --------------------------------------------------------------------------
    ; CHILD PROCESS LOGIC
    ; C equivalent:
    ;   close(pipefds[0]);
    ;   write(pipefds[1], msg_child, len_child);
    ;   close(pipefds[1]);
    ;   _exit(0);
    ; --------------------------------------------------------------------------
    ; Close unused read-end in child
    mov rax, 3                  ; sys_close
    mov edi, [pipefds]          ; pipefds[0]
    syscall

    ; Write message to pipe write-end
    mov rax, 1                  ; sys_write
    mov edi, [pipefds + 4]      ; pipefds[1] (write end)
    mov rsi, msg_child          ; string buffer
    mov rdx, len_child          ; length
    syscall

    ; Close write-end
    mov rax, 3
    mov edi, [pipefds + 4]
    syscall

    ; Child exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
