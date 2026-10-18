; ==============================================================================
; Program: elf_inspector.asm
; Description: Inspects ELF magic numbers and validates 64-bit ELF format
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    filename: db "/proc/self/exe", 0    ; Linux virtual link to current executable

    msg_valid: db "[+] Valid 64-bit Little-Endian ELF Binary Verified!", 10
    len_valid: equ $ - msg_valid

    msg_magic: db "[+] ELF Magic Bytes: 0x7F 'E' 'L' 'F'", 10
    len_magic: equ $ - msg_magic

section .bss
    fd:         resq 1
    elf_header: resb 64                 ; 64 bytes for Elf64_Ehdr

section .text
global _start

_start:
    ; 1. Open /proc/self/exe
    mov rax, 2                          ; sys_open
    lea rdi, [filename]
    xor rsi, rsi                        ; O_RDONLY
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .error
    mov [fd], rax

    ; 2. Read first 64 bytes (Elf64_Ehdr)
    mov rax, 0                          ; sys_read
    mov rdi, [fd]
    lea rsi, [elf_header]
    mov rdx, 64
    syscall

    ; 3. Verify ELF Magic Bytes: 0x7F, 'E', 'L', 'F' (0x464C457F little-endian)
    cmp dword [elf_header], 0x464C457F
    jne .error

    ; Print Magic Verified
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_magic]
    mov rdx, len_magic
    syscall

    ; 4. Verify 64-bit (byte 4 == 2) and Little-Endian (byte 5 == 1)
    cmp byte [elf_header + 4], 2         ; EI_CLASS: 2 = 64-bit
    jne .error
    cmp byte [elf_header + 5], 1         ; EI_DATA: 1 = 2's complement, little-endian
    jne .error

    ; Print 64-bit ELF Validated
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_valid]
    mov rdx, len_valid
    syscall

    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
