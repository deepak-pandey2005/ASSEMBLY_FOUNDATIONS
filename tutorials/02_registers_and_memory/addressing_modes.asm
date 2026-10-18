; ==============================================================================
; Program: addressing_modes.asm
; Description: Demonstrates all x86-64 memory addressing modes and LEA instruction
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    ; Array of 5 64-bit integers (8 bytes each)
    array: dq 10, 25, 45, 70, 95
    val:   dq 1337

section .text
global _start

_start:
    ; 1. Direct Addressing: load from an absolute symbol/offset
    mov rax, [val]              ; rax = 1337

    ; 2. Register Indirect: address is stored in a register
    lea rbx, [array]            ; rbx = pointer to array
    mov rcx, [rbx]              ; rcx = array[0] = 10

    ; 3. Base + Displacement: offset by a constant byte distance
    mov rdx, [rbx + 8]          ; rdx = array[1] = 25 (offset by 8 bytes)

    ; 4. Base + (Index * Scale): standard array indexing
    ;    scale can be 1, 2, 4, or 8 (8 for 64-bit quadwords)
    mov rdi, 3                  ; index = 3
    mov r8, [rbx + rdi*8]       ; r8 = array[3] = 70

    ; 5. Base + (Index * Scale) + Displacement
    mov r9, [rbx + rdi*8 - 8]   ; r9 = array[2] = 45

    ; 6. LEA (Load Effective Address):
    ;    Computes pointer arithmetic without fetching memory!
    lea r10, [rbx + rdi*8]      ; r10 is the memory address &array[3], not value 70
    ; You can even abuse LEA for fast arithmetic:
    ; Example: r11 = rdi * 9 + 4
    lea r11, [rdi + rdi*8 + 4]  ; r11 = 3 + 24 + 4 = 31 in a single CPU cycle!

    ; Clean exit returning 0
    mov rax, 60                 ; sys_exit
    xor rdi, rdi                ; status = 0
    syscall
