; ==============================================================================
; Program: hash_algorithms.asm
; Description: Implementation of DJB2 and FNV-1a hashing algorithms in assembly
; Architecture: x86-64 Linux
; Assembler: NASM
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
; Input: RDI = pointer to null-terminated string
; Output: RAX = 64-bit hash
; ------------------------------------------------------------------------------
djb2_hash:
    mov rax, 5381               ; initial hash seed = 5381
.loop:
    movzx rcx, byte [rdi]       ; load byte
    test cl, cl                 ; check for '\0'
    jz .done

    ; hash * 33 + char:
    mov rdx, rax
    shl rdx, 5                  ; rdx = hash * 32
    add rax, rdx                ; rax = hash * 33
    xor rax, rcx                ; rax = (hash * 33) ^ char

    inc rdi
    jmp .loop
.done:
    ret

; ------------------------------------------------------------------------------
; Routine: print_hex_64
; Input: RAX = 64-bit integer to print in hexadecimal
; ------------------------------------------------------------------------------
print_hex_64:
    mov rcx, 16                 ; 16 nibbles (64 bits)
    lea rdi, [hex_output + 15]  ; fill from right to left
.hex_loop:
    mov rdx, rax
    and rdx, 0x0F               ; lowest 4 bits
    mov dl, [hex_chars + rdx]
    mov [rdi], dl
    shr rax, 4
    dec rdi
    dec rcx
    jnz .hex_loop

    ; Write 16 hex chars
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, hex_output
    mov rdx, 16
    syscall
    ret

_start:
    ; 1. Print message header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_djb2
    mov rdx, len_djb2
    syscall

    ; 2. Compute DJB2 hash of "antigravity"
    lea rdi, [target_str]
    call djb2_hash

    ; 3. Print resulting hash in hexadecimal
    call print_hex_64

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
