; ==============================================================================
; Program: fork_pipe_ipc.asm
; Description: Process creation via fork() and Inter-Process Communication via pipe()
; Architecture: x86-64 Linux
; Assembler: NASM
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
    ; 1. CREATE PIPE: sys_pipe(pipefd[2]) -> syscall 22
    ; --------------------------------------------------------------------------
    mov rax, 22                 ; sys_pipe
    mov rdi, pipefds            ; int pipefd[2]
    syscall

    ; --------------------------------------------------------------------------
    ; 2. FORK PROCESS: sys_fork() -> syscall 57
    ; --------------------------------------------------------------------------
    mov rax, 57                 ; sys_fork
    syscall

    cmp rax, 0
    je  .child_code             ; If RAX == 0, we are in the CHILD!
    ; Otherwise, RAX > 0 (child PID), we are in the PARENT!

.parent_code:
    ; Close unused write-end in parent
    mov rax, 3                  ; sys_close
    mov edi, [pipefds + 4]      ; pipefds[1]
    syscall

    ; Read message sent by child from read-end
    mov rax, 0                  ; sys_read
    mov edi, [pipefds]          ; pipefds[0]
    mov rsi, read_buf
    mov rdx, 128
    syscall
    mov [bytes_in], rax

    ; Print parent header
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, parent_hdr
    mov rdx, parent_len
    syscall

    ; Print data received from pipe
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, read_buf
    mov rdx, [bytes_in]
    syscall

    ; Close read-end
    mov rax, 3                  ; sys_close
    mov edi, [pipefds]
    syscall

    ; Wait for child to terminate: sys_wait4(pid=-1, status=NULL, options=0, rusage=NULL)
    mov rax, 61                 ; sys_wait4
    mov rdi, -1                 ; wait for any child
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Exit parent
    mov rax, 60
    xor rdi, rdi
    syscall

.child_code:
    ; In child: close unused read-end
    mov rax, 3                  ; sys_close
    mov edi, [pipefds]          ; pipefds[0]
    syscall

    ; Write message to parent through write-end
    mov rax, 1                  ; sys_write
    mov edi, [pipefds + 4]      ; pipefds[1]
    mov rsi, msg_child
    mov rdx, len_child
    syscall

    ; Close write-end
    mov rax, 3                  ; sys_close
    mov edi, [pipefds + 4]
    syscall

    ; Exit child cleanly
    mov rax, 60
    xor rdi, rdi
    syscall
