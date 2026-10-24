; ==============================================================================
; Program: epoll_server.asm
; Description: Asynchronous, event-driven TCP Echo Server using Linux epoll
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    ; struct sockaddr_in for 0.0.0.0:9090
    align 4
    server_addr:
        dw 2                            ; AF_INET = 2
        dw 0x8223                       ; Port 9090 in big-endian (htons(9090) = 0x2382 -> 0x8223)
        dd 0                            ; INADDR_ANY (0.0.0.0)
        dq 0                            ; padding
    addr_len equ $ - server_addr

    reuse_val dd 1

    msg_listen: db "[+] epoll Event-Driven Server listening on port 9090 ...", 10
    len_listen: equ $ - msg_listen

    echo_prefix: db "[Echo]: "
    len_echo_prefix: equ $ - echo_prefix

    MAX_EVENTS equ 16

    ; struct epoll_event layout for 64-bit Linux (packed: 4 bytes events + 8 bytes data)
    ; EPOLLIN = 0x00000001
    EPOLLIN equ 1
    EPOLL_CTL_ADD equ 1
    EPOLL_CTL_DEL equ 2

section .bss
    server_fd:  resq 1
    epoll_fd:   resq 1

    ; Event structure for registration (12 bytes)
    align 4
    ev_reg:
        resd 1                          ; uint32_t events
        resq 1                          ; epoll_data_t (FD or ptr)

    ; Event array for receiving active events from epoll_wait (16 * 12 bytes = 192 bytes)
    align 4
    events_arr: resb 192

    io_buf:     resb 1024

section .text
global _start

; ------------------------------------------------------------------------------
; Helper: Set a File Descriptor to Non-Blocking (O_NONBLOCK)
; Input: RDI = fd
; ------------------------------------------------------------------------------
set_nonblocking:
    push rbx
    mov rbx, rdi

    ; 1. Get current flags: sys_fcntl(fd, F_GETFL=3)
    mov rax, 72                         ; sys_fcntl
    mov rdi, rbx
    mov rsi, 3                          ; F_GETFL
    syscall

    ; 2. Add O_NONBLOCK (0x800) to flags
    or rax, 0x800                       ; O_NONBLOCK = 2048 (0x800)
    mov rdx, rax

    ; 3. Set updated flags: sys_fcntl(fd, F_SETFL=4, flags)
    mov rax, 72                         ; sys_fcntl
    mov rdi, rbx
    mov rsi, 4                          ; F_SETFL
    syscall

    pop rbx
    ret

; ------------------------------------------------------------------------------
; Main Program Entry Point
; ------------------------------------------------------------------------------
_start:
    ; --------------------------------------------------------------------------
    ; 1. CREATE LISTENING TCP SOCKET
    ; --------------------------------------------------------------------------
    mov rax, 41                         ; sys_socket
    mov rdi, 2                          ; AF_INET
    mov rsi, 1                          ; SOCK_STREAM
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .fatal
    mov [server_fd], rax

    ; SO_REUSEADDR
    mov rax, 54                         ; sys_setsockopt
    mov rdi, [server_fd]
    mov rsi, 1                          ; SOL_SOCKET
    mov rdx, 2                          ; SO_REUSEADDR
    lea r10, [reuse_val]
    mov r8, 4
    syscall

    ; Bind to 0.0.0.0:9090
    mov rax, 49                         ; sys_bind
    mov rdi, [server_fd]
    lea rsi, [server_addr]
    mov rdx, addr_len
    syscall

    cmp rax, 0
    jl .fatal

    ; Listen
    mov rax, 50                         ; sys_listen
    mov rdi, [server_fd]
    mov rsi, 32                         ; backlog
    syscall

    ; Set listening socket to non-blocking
    mov rdi, [server_fd]
    call set_nonblocking

    ; --------------------------------------------------------------------------
    ; 2. CREATE EPOLL INSTANCE: sys_epoll_create1(flags=0)
    ; Syscall: 291
    ; --------------------------------------------------------------------------
    mov rax, 291                        ; sys_epoll_create1
    xor rdi, rdi                        ; flags = 0
    syscall

    cmp rax, 0
    jl .fatal
    mov [epoll_fd], rax

    ; --------------------------------------------------------------------------
    ; 3. REGISTER LISTENING SOCKET WITH EPOLL
    ; sys_epoll_ctl(epfd, EPOLL_CTL_ADD=1, fd, &ev)
    ; Syscall: 233
    ; --------------------------------------------------------------------------
    mov dword [ev_reg], EPOLLIN         ; Monitor for read readiness
    mov rax, [server_fd]
    mov qword [ev_reg + 4], rax         ; user data = server_fd

    mov rax, 233                        ; sys_epoll_ctl
    mov rdi, [epoll_fd]
    mov rsi, EPOLL_CTL_ADD              ; 1
    mov rdx, [server_fd]
    lea r10, [ev_reg]
    syscall

    cmp rax, 0
    jl .fatal

    ; Print startup banner
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_listen]
    mov rdx, len_listen
    syscall

    ; --------------------------------------------------------------------------
    ; 4. ASYNCHRONOUS EVENT LOOP
    ; --------------------------------------------------------------------------
.event_loop:
    ; sys_epoll_wait(epfd, events, maxevents, timeout_ms=-1)
    ; Syscall: 232
    mov rax, 232                        ; sys_epoll_wait
    mov rdi, [epoll_fd]
    lea rsi, [events_arr]
    mov rdx, MAX_EVENTS
    mov r10, 5000                       ; 5-second timeout (for testing/graceful exit)
    syscall

    cmp rax, 0
    jle .event_loop                     ; Timeout or interrupted, loop again

    mov r12, rax                        ; r12 = number of ready file descriptors
    xor r13, r13                        ; event index = 0

.process_events:
    cmp r13, r12
    jge .event_loop

    ; Calculate pointer to events_arr[r13] (each event is 12 bytes on Linux)
    ; Offset: r13 * 12
    mov rax, r13
    imul rax, 12
    lea r14, [events_arr + rax]

    mov ebx, dword [r14]                ; ready events flags (e.g. EPOLLIN)
    mov r15, qword [r14 + 4]            ; ready FD

    ; Is the ready FD our server_fd?
    cmp r15, [server_fd]
    je .handle_new_connection

    ; Otherwise, it is an active client socket!
    jmp .handle_client_data

.handle_new_connection:
    ; Accept incoming client connection: sys_accept(server_fd, NULL, NULL)
    mov rax, 43                         ; sys_accept
    mov rdi, [server_fd]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .next_event                      ; Non-blocking accept returned EAGAIN/EWOULDBLOCK

    mov rdi, rax                        ; rdi = client_fd
    call set_nonblocking

    ; Add new client_fd to epoll interest list
    mov dword [ev_reg], EPOLLIN
    mov qword [ev_reg + 4], rdi         ; user data = client_fd

    mov rax, 233                        ; sys_epoll_ctl
    mov rsi, EPOLL_CTL_ADD
    mov rdx, rdi                        ; client_fd
    mov rdi, [epoll_fd]
    lea r10, [ev_reg]
    syscall
    jmp .next_event

.handle_client_data:
    ; Read incoming data from non-blocking client: sys_read(client_fd, buf, 1024)
    mov rax, 0                          ; sys_read
    mov rdi, r15                        ; client_fd
    lea rsi, [io_buf]
    mov rdx, 1024
    syscall

    cmp rax, 0
    jle .close_client                   ; Client disconnected (EOF = 0) or error (<0)

    mov rbx, rax                        ; bytes read

    ; Echo data back to client: sys_write(client_fd, echo_prefix, len)
    mov rax, 1                          ; sys_write
    mov rdi, r15
    lea rsi, [echo_prefix]
    mov rdx, len_echo_prefix
    syscall

    ; sys_write(client_fd, io_buf, bytes_read)
    mov rax, 1                          ; sys_write
    mov rdi, r15
    lea rsi, [io_buf]
    mov rdx, rbx
    syscall

    jmp .next_event

.close_client:
    ; Remove client from epoll and close socket
    mov rax, 233                        ; sys_epoll_ctl(epfd, EPOLL_CTL_DEL, client_fd, NULL)
    mov rdi, [epoll_fd]
    mov rsi, EPOLL_CTL_DEL
    mov rdx, r15                        ; client_fd
    xor r10, r10
    syscall

    mov rax, 3                          ; sys_close
    mov rdi, r15
    syscall

.next_event:
    inc r13
    jmp .process_events

.fatal:
    mov rax, 60
    mov rdi, 1
    syscall
