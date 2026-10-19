; ==============================================================================
; Project: b64encode.asm
; Description: Streaming Base64 file converter CLI in pure x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    b64_table: db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    in_filename:  db "input.bin", 0
    out_filename: db "output.b64", 0

    msg_done: db "[+] Successfully encoded input.bin -> output.b64 in pure assembly!", 10
    len_done: equ $ - msg_done

    err_open: db "[-] Failed to open input file input.bin", 10
    len_open: equ $ - err_open

    BUFFER_SIZE equ 3072        ; Multiple of 3 (3072 / 3 = 1024 triplets -> 4096 encoded bytes)

section .bss
    in_fd:   resq 1
    out_fd:  resq 1
    in_buf:  resb BUFFER_SIZE
    out_buf: resb 4096

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. OPEN INPUT FILE: sys_open("input.bin", O_RDONLY, 0)
    ; --------------------------------------------------------------------------
    mov rax, 2                  ; sys_open
    lea rdi, [in_filename]
    xor rsi, rsi                ; O_RDONLY
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .err_input
    mov [in_fd], rax

    ; --------------------------------------------------------------------------
    ; 2. CREATE OUTPUT FILE: sys_open("output.b64", O_CREAT|O_WRONLY|O_TRUNC, 0644)
    ; --------------------------------------------------------------------------
    mov rax, 2                  ; sys_open
    lea rdi, [out_filename]
    mov rsi, 577                ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 420                ; 0644
    syscall

    cmp rax, 0
    jl .fatal
    mov [out_fd], rax

.stream_loop:
    ; Read up to BUFFER_SIZE bytes
    mov rax, 0                  ; sys_read
    mov rdi, [in_fd]
    lea rsi, [in_buf]
    mov rdx, BUFFER_SIZE
    syscall

    cmp rax, 0
    jle .close_all              ; 0 = EOF, <0 = error

    mov rcx, rax                ; bytes read
    lea rsi, [in_buf]
    lea rdi, [out_buf]
    xor r8, r8                  ; encoded bytes counter

.triplet_loop:
    cmp rcx, 3
    jl .handle_tail

    ; Load 3 bytes: B0, B1, B2
    movzx eax, byte [rsi]
    movzx ebx, byte [rsi + 1]
    movzx edx, byte [rsi + 2]

    ; Char 1: B0 >> 2
    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    ; Char 2: ((B0 & 3) << 4) | (B1 >> 4)
    mov r9d, eax
    and r9d, 3
    shl r9d, 4
    mov r11d, ebx
    shr r11d, 4
    and r11d, 0x0F
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    ; Char 3: ((B1 & 15) << 2) | (B2 >> 6)
    mov r9d, ebx
    and r9d, 15
    shl r9d, 2
    mov r11d, edx
    shr r11d, 6
    and r11d, 3
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 2], r10b

    ; Char 4: B2 & 0x3F
    mov r9d, edx
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi + 3], r10b

    add rsi, 3
    add rdi, 4
    add r8, 4
    sub rcx, 3
    jmp .triplet_loop

.handle_tail:
    test rcx, rcx
    jz .write_chunk

    cmp rcx, 1
    je .tail_one

    ; Tail of 2 bytes:
    movzx eax, byte [rsi]
    movzx ebx, byte [rsi + 1]

    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    mov r9d, eax
    and r9d, 3
    shl r9d, 4
    mov r11d, ebx
    shr r11d, 4
    and r11d, 0x0F
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    mov r9d, ebx
    and r9d, 15
    shl r9d, 2
    mov r10b, [b64_table + r9]
    mov [rdi + 2], r10b

    mov byte [rdi + 3], '='     ; 1 padding char
    add r8, 4
    jmp .write_chunk

.tail_one:
    movzx eax, byte [rsi]
    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    mov r9d, eax
    and r9d, 3
    shl r9d, 4
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    mov byte [rdi + 2], '='     ; 2 padding chars
    mov byte [rdi + 3], '='
    add r8, 4

.write_chunk:
    ; Write encoded chunk to output file
    mov rax, 1                  ; sys_write
    mov rdi, [out_fd]
    lea rsi, [out_buf]
    mov rdx, r8
    syscall

    jmp .stream_loop

.close_all:
    ; Append newline to output file
    mov byte [out_buf], 10
    mov rax, 1
    mov rdi, [out_fd]
    lea rsi, [out_buf]
    mov rdx, 1
    syscall

    mov rax, 3                  ; sys_close
    mov rdi, [out_fd]
    syscall

    mov rax, 3                  ; sys_close
    mov rdi, [in_fd]
    syscall

    ; Print Done message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

.err_input:
    mov rax, 1
    mov rdi, 2                  ; stderr
    lea rsi, [err_open]
    mov rdx, len_open
    syscall

.fatal:
    mov rax, 60
    mov rdi, 1
    syscall
