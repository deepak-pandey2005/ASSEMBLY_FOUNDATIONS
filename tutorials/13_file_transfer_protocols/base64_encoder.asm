; ==============================================================================
; Program: base64_encoder.asm
; Description: High-performance binary to Base64 encoder in pure x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    b64_table: db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    input_text: db "Assembly Language Powers The World!"
    input_len:  equ $ - input_text

    newline: db 10

section .bss
    ; Output takes ceil(len / 3) * 4 bytes
    encoded_buf: resb 128
    encoded_len: resq 1

section .text
global _start

_start:
    lea rsi, [input_text]       ; source pointer
    lea rdi, [encoded_buf]      ; destination pointer
    mov rcx, input_len          ; bytes remaining
    xor r8, r8                  ; total encoded bytes counter

.encode_loop:
    cmp rcx, 3
    jl .handle_tail

    ; Load 3 input bytes: b0, b1, b2
    movzx eax, byte [rsi]       ; b0
    movzx ebx, byte [rsi + 1]   ; b1
    movzx edx, byte [rsi + 2]   ; b2

    ; char 1: (b0 >> 2) & 0x3F
    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    ; char 2: ((b0 & 0x03) << 4) | ((b1 >> 4) & 0x0F)
    mov r9d, eax
    and r9d, 0x03
    shl r9d, 4
    mov r11d, ebx
    shr r11d, 4
    and r11d, 0x0F
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    ; char 3: ((b1 & 0x0F) << 2) | ((b2 >> 6) & 0x03)
    mov r9d, ebx
    and r9d, 0x0F
    shl r9d, 2
    mov r11d, edx
    shr r11d, 6
    and r11d, 0x03
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 2], r10b

    ; char 4: b2 & 0x3F
    mov r9d, edx
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi + 3], r10b

    add rsi, 3                  ; advance source by 3 bytes
    add rdi, 4                  ; advance destination by 4 bytes
    add r8, 4                   ; output count += 4
    sub rcx, 3                  ; remaining -= 3
    jmp .encode_loop

.handle_tail:
    ; For remainder (1 or 2 bytes padding with '='):
    cmp rcx, 0
    je .done

    cmp rcx, 1
    je .tail_1_byte

    ; 2 bytes remainder:
    movzx eax, byte [rsi]
    movzx ebx, byte [rsi + 1]

    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    mov r9d, eax
    and r9d, 0x03
    shl r9d, 4
    mov r11d, ebx
    shr r11d, 4
    and r11d, 0x0F
    or  r9d, r11d
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    mov r9d, ebx
    and r9d, 0x0F
    shl r9d, 2
    mov r10b, [b64_table + r9]
    mov [rdi + 2], r10b

    mov byte [rdi + 3], '='     ; 1 padding byte
    add r8, 4
    jmp .done

.tail_1_byte:
    movzx eax, byte [rsi]
    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    mov r9d, eax
    and r9d, 0x03
    shl r9d, 4
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    mov byte [rdi + 2], '='     ; padding
    mov byte [rdi + 3], '='     ; padding
    add r8, 4

.done:
    mov [encoded_len], r8

    ; Print encoded Base64 string to stdout
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, encoded_buf
    mov rdx, [encoded_len]
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
