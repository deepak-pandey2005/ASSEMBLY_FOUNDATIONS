; ==============================================================================
; Program: base64_encoder.asm
; Description: High-performance binary to Base64 encoder in pure x86-64 assembly
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
; #include <string.h>
;
; static const char b64_table[] =
;     "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
;
; static const char input_text[] = "Assembly Language Powers The World!";
; static char encoded_buf[128];
;
; size_t base64_encode(const uint8_t *src, size_t len, char *dst) {
;     size_t out_len = 0;
;     size_t rem = len;
;     const uint8_t *s = src;
;     char *d = dst;
;
;     // 1. Process 3-byte blocks -> 4 Base64 characters
;     while (rem >= 3) {
;         uint32_t b0 = s[0], b1 = s[1], b2 = s[2];
;         d[0] = b64_table[(b0 >> 2) & 0x3F];
;         d[1] = b64_table[((b0 & 0x03) << 4) | ((b1 >> 4) & 0x0F)];
;         d[2] = b64_table[((b1 & 0x0F) << 2) | ((b2 >> 6) & 0x03)];
;         d[3] = b64_table[b2 & 0x3F];
;         s += 3; d += 4; rem -= 3; out_len += 4;
;     }
;
;     // 2. Handle 1 or 2 leftover bytes with '=' padding
;     if (rem == 2) {
;         uint32_t b0 = s[0], b1 = s[1];
;         d[0] = b64_table[(b0 >> 2) & 0x3F];
;         d[1] = b64_table[((b0 & 0x03) << 4) | ((b1 >> 4) & 0x0F)];
;         d[2] = b64_table[(b1 & 0x0F) << 2];
;         d[3] = '=';
;         out_len += 4;
;     } else if (rem == 1) {
;         uint32_t b0 = s[0];
;         d[0] = b64_table[(b0 >> 2) & 0x3F];
;         d[1] = b64_table[(b0 & 0x03) << 4];
;         d[2] = '=';
;         d[3] = '=';
;         out_len += 4;
;     }
;     return out_len;
; }
;
; int main(void) {
;     size_t out_len = base64_encode((const uint8_t *)input_text, strlen(input_text), encoded_buf);
;     write(STDOUT_FILENO, encoded_buf, out_len);
;     write(STDOUT_FILENO, "\n", 1);
;     _exit(0);
; }
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
    lea rsi, [input_text]       ; const uint8_t *s = input_text;
    lea rdi, [encoded_buf]      ; char *d = encoded_buf;
    mov rcx, input_len          ; size_t rem = input_len;
    xor r8, r8                  ; size_t out_len = 0;

.encode_loop:
    cmp rcx, 3                  ; while (rem >= 3)
    jl .handle_tail

    ; Load 3 input bytes: b0, b1, b2
    movzx eax, byte [rsi]       ; uint32_t b0 = s[0];
    movzx ebx, byte [rsi + 1]   ; uint32_t b1 = s[1];
    movzx edx, byte [rsi + 2]   ; uint32_t b2 = s[2];

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

    ; Advance pointers
    add rsi, 3                  ; s += 3;
    add rdi, 4                  ; d += 4;
    sub rcx, 3                  ; rem -= 3;
    add r8, 4                   ; out_len += 4;
    jmp .encode_loop

.handle_tail:
    cmp rcx, 2
    je .two_bytes_left
    cmp rcx, 1
    je .one_byte_left
    jmp .done_encoding

.two_bytes_left:
    ; 2 leftover bytes: produces 3 chars + '='
    movzx eax, byte [rsi]       ; b0
    movzx ebx, byte [rsi + 1]   ; b1

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

    ; char 3: (b1 & 0x0F) << 2
    mov r9d, ebx
    and r9d, 0x0F
    shl r9d, 2
    mov r10b, [b64_table + r9]
    mov [rdi + 2], r10b

    ; char 4: '=' padding
    mov byte [rdi + 3], '='

    add r8, 4
    jmp .done_encoding

.one_byte_left:
    ; 1 leftover byte: produces 2 chars + '=='
    movzx eax, byte [rsi]       ; b0

    ; char 1: (b0 >> 2) & 0x3F
    mov r9d, eax
    shr r9d, 2
    and r9d, 0x3F
    mov r10b, [b64_table + r9]
    mov [rdi], r10b

    ; char 2: (b0 & 0x03) << 4
    mov r9d, eax
    and r9d, 0x03
    shl r9d, 4
    mov r10b, [b64_table + r9]
    mov [rdi + 1], r10b

    ; padding: "=="
    mov byte [rdi + 2], '='
    mov byte [rdi + 3], '='

    add r8, 4

.done_encoding:
    mov [encoded_len], r8

    ; Write encoded output to stdout
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [encoded_buf]
    mov rdx, [encoded_len]
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
