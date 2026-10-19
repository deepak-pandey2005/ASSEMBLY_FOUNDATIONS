; ==============================================================================
; Project: server_daemon.asm
; Description: Multi-route concurrent HTTP/1.1 Web Server Daemon in pure assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    ; struct sockaddr_in for 0.0.0.0:8080
    align 4
    server_addr:
        dw 2                            ; AF_INET = 2
        dw 0x901F                       ; Port 8080 (htons(8080) = 0x901F)
        dd 0                            ; INADDR_ANY (0.0.0.0)
        dq 0                            ; padding
    addr_len equ $ - server_addr

    ; Socket option: SO_REUSEADDR (level: SOL_SOCKET=1, optname: SO_REUSEADDR=2, val: 1)
    reuse_val dd 1

    ; Route paths
    path_root:   db "GET / ", 0
    path_index:  db "GET /index.html", 0
    path_api:    db "GET /api/status", 0

    ; HTTP Responses
    http_200_html:
        db "HTTP/1.1 200 OK", 13, 10
        db "Content-Type: text/html", 13, 10
        db "Connection: close", 13, 10
        db 13, 10
        db "<!DOCTYPE html><html><body style='font-family:sans-serif;background:#0d1117;color:#58a6ff;padding:40px;'>"
        db "<h1>Assembly Foundations HTTP Server Daemon</h1>"
        db "<p>Running in pure x86-64 Linux Machine Code!</p>"
        db "<ul><li>Architecture: AMD64 CISC</li><li>Kernel: Linux Syscalls</li><li>Zero C Runtime</li></ul>"
        db "</body></html>", 10
    len_200_html equ $ - http_200_html

    http_200_json:
        db "HTTP/1.1 200 OK", 13, 10
        db "Content-Type: application/json", 13, 10
        db "Connection: close", 13, 10
        db 13, 10
        db '{"status":"online","engine":"pure_assembly_x86_64","port":8080}', 10
    len_200_json equ $ - http_200_json

    http_404:
        db "HTTP/1.1 404 Not Found", 13, 10
        db "Content-Type: text/plain", 13, 10
        db "Connection: close", 13, 10
        db 13, 10
        db "404 Not Found - Assembly Foundations Daemon", 10
    len_404 equ $ - http_404

    msg_start: db "[+] Assembly HTTP Server Daemon online at http://0.0.0.0:8080 ...", 10
    len_start: equ $ - msg_start

section .bss
    server_fd: resq 1
    client_fd: resq 1
    req_buf:   resb 2048

section .text
global _start

; ------------------------------------------------------------------------------
; Helper: Check prefix match
; RDI = buffer, RSI = target prefix
; Returns RAX = 1 if match, 0 if no match
; ------------------------------------------------------------------------------
matches_prefix:
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]
    test al, al
    jz .match
    cmp al, [rdi + rcx]
    jne .nomatch
    inc rcx
    jmp .loop
.match:
    mov rax, 1
    ret
.nomatch:
    xor rax, rax
    ret

; ------------------------------------------------------------------------------
; Handle Connected HTTP Client
; ------------------------------------------------------------------------------
handle_client:
    ; Read HTTP Request from client_fd
    mov rax, 0                          ; sys_read
    mov rdi, [client_fd]
    lea rsi, [req_buf]
    mov rdx, 2047
    syscall

    cmp rax, 0
    jle .close_client

    ; Route: /api/status
    lea rdi, [req_buf]
    lea rsi, [path_api]
    call matches_prefix
    test rax, rax
    jnz .send_json

    ; Route: / or /index.html
    lea rdi, [req_buf]
    lea rsi, [path_root]
    call matches_prefix
    test rax, rax
    jnz .send_html

    lea rdi, [req_buf]
    lea rsi, [path_index]
    call matches_prefix
    test rax, rax
    jnz .send_html

    ; Fallthrough: 404 Not Found
    mov rax, 1                          ; sys_write
    mov rdi, [client_fd]
    lea rsi, [http_404]
    mov rdx, len_404
    syscall
    jmp .close_client

.send_json:
    mov rax, 1                          ; sys_write
    mov rdi, [client_fd]
    lea rsi, [http_200_json]
    mov rdx, len_200_json
    syscall
    jmp .close_client

.send_html:
    mov rax, 1                          ; sys_write
    mov rdi, [client_fd]
    lea rsi, [http_200_html]
    mov rdx, len_200_html
    syscall

.close_client:
    mov rax, 3                          ; sys_close
    mov rdi, [client_fd]
    syscall
    ret

; ------------------------------------------------------------------------------
; Main Server Loop
; ------------------------------------------------------------------------------
_start:
    ; 1. Create TCP Socket: sys_socket(AF_INET=2, SOCK_STREAM=1, 0)
    mov rax, 41                         ; sys_socket
    mov rdi, 2                          ; AF_INET
    mov rsi, 1                          ; SOCK_STREAM
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .fatal_error
    mov [server_fd], rax

    ; 2. Enable SO_REUSEADDR: sys_setsockopt(sockfd, SOL_SOCKET=1, SO_REUSEADDR=2, &opt, 4)
    mov rax, 54                         ; sys_setsockopt
    mov rdi, [server_fd]
    mov rsi, 1                          ; SOL_SOCKET
    mov rdx, 2                          ; SO_REUSEADDR
    lea r10, [reuse_val]
    mov r8, 4
    syscall

    ; 3. Bind to 0.0.0.0:8080: sys_bind(sockfd, &server_addr, addr_len)
    mov rax, 49                         ; sys_bind
    mov rdi, [server_fd]
    lea rsi, [server_addr]
    mov rdx, addr_len
    syscall

    cmp rax, 0
    jl .fatal_error

    ; 4. Listen: sys_listen(sockfd, backlog=16)
    mov rax, 50                         ; sys_listen
    mov rdi, [server_fd]
    mov rsi, 16
    syscall

    ; Print startup banner
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_start]
    mov rdx, len_start
    syscall

.accept_loop:
    ; 5. Accept Client: sys_accept(server_fd, NULL, NULL)
    mov rax, 43                         ; sys_accept
    mov rdi, [server_fd]
    xor rsi, rsi
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .accept_loop
    mov [client_fd], rax

    ; Handle request directly and close connection
    call handle_client

    jmp .accept_loop

.fatal_error:
    mov rax, 60
    mov rdi, 1
    syscall
