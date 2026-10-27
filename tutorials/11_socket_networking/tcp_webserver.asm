; ==============================================================================
; Program: tcp_webserver.asm
; Description: Standalone HTTP/1.1 TCP Web Server written in pure x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <sys/socket.h>
; #include <netinet/in.h>
; #include <unistd.h>
; #include <string.h>
;
; static const char http_response[] =
;     "HTTP/1.1 200 OK\r\n"
;     "Content-Type: text/html\r\n"
;     "Connection: close\r\n\r\n"
;     "<h1>Hello from Pure x86-64 Assembly Web Server!</h1>\n";
;
; int main(void) {
;     // 1. Create socket
;     int server_fd = socket(AF_INET, SOCK_STREAM, 0);
;
;     // 2. Bind to 0.0.0.0:8080
;     struct sockaddr_in server_addr;
;     memset(&server_addr, 0, sizeof(server_addr));
;     server_addr.sin_family = AF_INET;
;     server_addr.sin_port = htons(8080); // 0x901F
;     server_addr.sin_addr.s_addr = INADDR_ANY;
;     bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
;
;     // 3. Listen
;     listen(server_fd, 10);
;     write(STDOUT_FILENO, "[+] Assembly HTTP Server listening on http://0.0.0.0:8080 ...\n", 60);
;
;     // 4. Accept single connection
;     int client_fd = accept(server_fd, NULL, NULL);
;
;     // 5. Read request and send HTTP response
;     char req_buf[1024];
;     read(client_fd, req_buf, sizeof(req_buf));
;     write(client_fd, http_response, sizeof(http_response) - 1);
;
;     // 6. Close sockets
;     close(client_fd);
;     close(server_fd);
;     _exit(0);
; }
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
    ; C equivalent: int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    ; --------------------------------------------------------------------------
    mov rax, 41                         ; rax = SYS_socket (41)
    mov rdi, 2                          ; rdi = AF_INET (2)
    mov rsi, 1                          ; rsi = SOCK_STREAM (1)
    xor rdx, rdx                        ; rdx = protocol 0
    syscall

    cmp rax, 0
    jl  .error
    mov [server_fd], rax

    ; --------------------------------------------------------------------------
    ; 2. BIND SOCKET: sys_bind(sockfd, &server_addr, addrlen)
    ; C equivalent: bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    ; --------------------------------------------------------------------------
    mov rax, 49                         ; rax = SYS_bind (49)
    mov rdi, [server_fd]                ; rdi = server_fd
    mov rsi, server_addr                ; rsi = pointer to sockaddr_in
    mov rdx, server_addr_len            ; rdx = 16 bytes
    syscall

    cmp rax, 0
    jl  .error

    ; --------------------------------------------------------------------------
    ; 3. LISTEN: sys_listen(sockfd, backlog=10)
    ; C equivalent: listen(server_fd, 10);
    ; --------------------------------------------------------------------------
    mov rax, 50                         ; rax = SYS_listen (50)
    mov rdi, [server_fd]                ; rdi = server_fd
    mov rsi, 10                         ; rsi = backlog (10 connections queue)
    syscall

    cmp rax, 0
    jl  .error

    ; Print listening status to console
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_listen
    mov rdx, len_listen
    syscall

    ; --------------------------------------------------------------------------
    ; 4. ACCEPT INCOMING CONNECTION: sys_accept(sockfd, NULL, NULL)
    ; C equivalent: int client_fd = accept(server_fd, NULL, NULL);
    ; --------------------------------------------------------------------------
    mov rax, 43                         ; rax = SYS_accept (43)
    mov rdi, [server_fd]                ; rdi = server_fd
    xor rsi, rsi                        ; rsi = NULL (sockaddr)
    xor rdx, rdx                        ; rdx = NULL (addrlen)
    syscall

    cmp rax, 0
    jl  .error
    mov [client_fd], rax

    ; --------------------------------------------------------------------------
    ; 5. READ HTTP REQUEST: sys_read(client_fd, req_buf, 1024)
    ; C equivalent: read(client_fd, req_buf, 1024);
    ; --------------------------------------------------------------------------
    mov rax, 0                          ; sys_read
    mov rdi, [client_fd]
    mov rsi, req_buf
    mov rdx, 1024
    syscall

    ; --------------------------------------------------------------------------
    ; 6. WRITE HTTP RESPONSE: sys_write(client_fd, http_response, len)
    ; C equivalent: write(client_fd, http_response, http_len);
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, [client_fd]                ; client socket
    mov rsi, http_response
    mov rdx, http_len
    syscall

    ; --------------------------------------------------------------------------
    ; 7. CLOSE CLIENT AND SERVER SOCKETS
    ; C equivalent: close(client_fd); close(server_fd);
    ; --------------------------------------------------------------------------
    mov rax, 3                          ; sys_close
    mov rdi, [client_fd]
    syscall

    mov rax, 3                          ; sys_close
    mov rdi, [server_fd]
    syscall

    ; Exit cleanly
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
