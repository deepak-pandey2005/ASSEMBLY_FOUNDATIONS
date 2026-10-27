; ==============================================================================
; Program: hash_algorithms.asm
; Description: Implementation of DJB2 and FNV-1a hashing algorithms in assembly
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <stdio.h>
; #include <unistd.h>
;
; uint64_t djb2_hash(const char *str) {
;     uint64_t hash = 5381;
;     while (*str != '\0') {
;         // hash * 33 ^ c
;         hash = ((hash << 5) + hash) ^ (uint64_t)(unsigned char)(*str);
;         str++;
;     }
;     return hash;
; }
;
; int main(void) {
;     const char target_str[] = "antigravity";
;     uint64_t h = djb2_hash(target_str);
;     printf("[+] DJB2 Hash (hex): 0x%016lx\n", h);
;     _exit(0);
; }
; ==============================================================================

section .data
    target_str: db "antigravity", 0

    msg_djb2:   db "[+] DJB2 Hash (hex): 0x"
    len_djb2:   equ $ - msg_djb2

    newline:    db 10

    hex_chars:  db "0123456789abcdef"

section .bss
    hex_output: resb 16

section .text
global _start

; ------------------------------------------------------------------------------
; Routine: djb2_hash
; Input: RDI = pointer to null-terminated string (const char *str)
; Output: RAX = 64-bit hash (uint64_t)
;
; C equivalent:
;   uint64_t hash = 5381;
;   while (*str) { hash = ((hash << 5) + hash) ^ *str++; }
;   return hash;
; ------------------------------------------------------------------------------
djb2_hash:
    mov rax, 5381               ; uint64_t hash = 5381;
.loop:
    movzx rcx, byte [rdi]       ; unsigned char c = *str;
    test cl, cl                 ; if (c == '\0') break;
    jz .done

    ; hash * 33 + char:
    mov rdx, rax
    shl rdx, 5                  ; rdx = hash * 32 (hash << 5)
    add rax, rdx                ; rax = hash * 33 ((hash << 5) + hash)
    xor rax, rcx                ; rax = (hash * 33) ^ c

    inc rdi                     ; str++;
    jmp .loop
.done:
    ret                         ; return hash;

; ------------------------------------------------------------------------------
; Routine: print_hex_64
; Input: RAX = 64-bit integer to print in hexadecimal
; C equivalent: printf("%016lx\n", val);
; ------------------------------------------------------------------------------
print_hex_64:
    mov rcx, 16                 ; 16 nibbles (64 bits)
    lea rdi, [hex_output + 15]  ; fill from right to left
.hex_loop:
    mov rdx, rax
    and rdx, 0x0F               ; uint8_t nibble = val & 0x0F;
    mov dl, [hex_chars + rdx]
    mov [rdi], dl               ; hex_output[i] = hex_chars[nibble];
    shr rax, 4                  ; val >>= 4;
    dec rdi
    dec rcx
    jnz .hex_loop

    ; Write 16 hex characters
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [hex_output]
    mov rdx, 16
    syscall

    ; Write newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall
    ret

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; Print message prefix: "[+] DJB2 Hash (hex): 0x"
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_djb2]
    mov rdx, len_djb2
    syscall

    ; Compute DJB2 hash of target_str
    lea rdi, [target_str]
    call djb2_hash

    ; Print hash value in hex
    call print_hex_64

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall
