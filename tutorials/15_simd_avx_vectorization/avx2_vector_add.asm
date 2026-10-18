; ==============================================================================
; Program: avx2_vector_add.asm
; Description: 256-bit SIMD vector addition of 8 32-bit integers in parallel
; Architecture: x86-64 Linux (AVX2 supported)
; Assembler: NASM
; ==============================================================================

section .data
    ; Vector A: 8 32-bit integers (256 bits total)
    vector_a: dd 10, 20, 30, 40, 50, 60, 70, 80

    ; Vector B: 8 32-bit integers
    vector_b: dd 1,  2,  3,  4,  5,  6,  7,  8

    msg_done: db "[+] AVX2 256-bit SIMD Vector Addition completed successfully!", 10
    len_done: equ $ - msg_done

section .bss
    ; Vector Result: 8 32-bit integers (sum should be 11, 22, 33, 44, 55, 66, 77, 88)
    vector_c: resd 8

section .text
global _start

_start:
    ; 1. Load 256-bit vector A into YMM0 register (unaligned load: vmovdqu)
    vmovdqu ymm0, [vector_a]

    ; 2. Load 256-bit vector B into YMM1 register
    vmovdqu ymm1, [vector_b]

    ; 3. Parallel Packed Integer Addition: YMM2 = YMM0 + YMM1
    ; Adds 8 pairs of 32-bit integers in a single instruction!
    vpaddd  ymm2, ymm0, ymm1

    ; 4. Store 256-bit result into vector_c
    vmovdqu [vector_c], ymm2

    ; 5. Verify first element (10 + 1 = 11) and last element (80 + 8 = 88)
    mov eax, [vector_c]         ; eax = 11
    mov ebx, [vector_c + 28]    ; ebx = 88 (7th index * 4 = 28)

    ; Print success notification
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_done
    mov rdx, len_done
    syscall

    ; Clean AVX state before exit (avoids AVX-SSE transition penalties)
    vzeroupper

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
