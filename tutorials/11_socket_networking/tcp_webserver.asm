; ==============================================================================
; Program: tcp_webserver.asm
; Description: Standalone HTTP/1.1 TCP Web Server written in pure x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    ; struct sockaddr_in {
    ;    sa_family_t     sin_family;   // 2 bytes: AF_INET = 2
    ;    in_port_t       sin_port;     // 2 bytes: Port 8080 (0x901F big-endian)
    ;    struct in_addr  sin_addr;     // 4 bytes: INADDR_ANY = 0.0.0.0
    ;    char            sin_zero[8];  // 8 bytes padding
    ; };
    server_addr:
        dw 2                            ; sin_family: AF_INET (2)
        dw 0x901F                       ; sin_port: 8080 in network byte order (htons(8080) = 0x901F)
        dd 0                            ; sin_addr: 0.0.0.0 (INADDR_ANY)
        dq 0                            ; sin_zero padding (8 bytes)
    server_addr_len: equ $ - server_addr

    http_response:
        db "HTTP/1.1 200 OK", 13, 10
        db "Content-Type: text/html", 13, 10
        db "Connection: close", 13, 10
        db 13, 10
        db "<h1>Hello from Pure x86-64 Assembly Web Server!</h1>", 10
    http_len: equ $ - http_response

    msg_listen: db "[+] Assembly HTTP Server listening on http://0.0.0.0:8080 ...", 10
    len_listen: equ $ - msg_listen

section .bss
    server_fd: resq 1
    client_fd: resq 1
    req_buf:   resb 1024

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. CREATE SOCKET: sys_socket(family=AF_INET(2), type=SOCK_STREAM(1), proto=0)
    ; --------------------------------------------------------------------------
    mov rax, 41                         ; sys_socket
    mov rdi, 2                          ; AF_INET
    mov rsi, 1                          ; SOCK_STREAM
    xor rdx, rdx                        ; protocol = 0
    syscall

    cmp rax, 0
    jl  .error
    mov [server_fd], rax

    ; --------------------------------------------------------------------------
    ; 2. BIND SOCKET: sys_bind(sockfd, &server_addr, addrlen)
    ; --------------------------------------------------------------------------
    mov rax, 49                         ; sys_bind
    mov rdi, [server_fd]
    mov rsi, server_addr
    mov rdx, server_addr_len
    syscall

    cmp rax, 0
    jl  .error

    ; --------------------------------------------------------------------------
    ; 3. LISTEN: sys_listen(sockfd, backlog=10)
    ; --------------------------------------------------------------------------
    mov rax, 50                         ; sys_listen
    mov rdi, [server_fd]
    mov rsi, 10                         ; backlog
    syscall

    ; Print listening notification
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, msg_listen
    mov rdx, len_listen
    syscall

    ; --------------------------------------------------------------------------
    ; 4. ACCEPT CONNECTION: sys_accept(sockfd, NULL, NULL)
    ; --------------------------------------------------------------------------
    mov rax, 43                         ; sys_accept
    mov rdi, [server_fd]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl  .error
    mov [client_fd], rax

    ; --------------------------------------------------------------------------
    ; 5. READ REQUEST: sys_read(client_fd, req_buf, 1024)
    ; --------------------------------------------------------------------------
    mov rax, 0                          ; sys_read
    mov rdi, [client_fd]
    mov rsi, req_buf
    mov rdx, 1024
    syscall

    ; --------------------------------------------------------------------------
    ; 6. SEND HTTP RESPONSE: sys_write(client_fd, http_response, http_len)
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, [client_fd]
    mov rsi, http_response
    mov rdx, http_len
    syscall

    ; --------------------------------------------------------------------------
    ; 7. CLOSE CONNECTIONS
    ; --------------------------------------------------------------------------
    mov rax, 3                          ; sys_close client
    mov rdi, [client_fd]
    syscall

    mov rax, 3                          ; sys_close server
    mov rdi, [server_fd]
    syscall

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
