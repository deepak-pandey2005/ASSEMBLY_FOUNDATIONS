; ==============================================================================
; Program: bitwise.asm
; Description: AND, OR, XOR, NOT, Bit-shifts (SHL, SHR, SAR) and rotates (ROL, ROR)
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    flags: dq 0b10110011        ; 0xB3 in binary

section .bss
    result: resq 1

section .text
global _start

_start:
    ; 1. Bitwise AND (Masking bits)
    mov rax, [flags]
    and rax, 0b00001111         ; Keep only lower 4 bits -> rax = 0b0011 (3)

    ; 2. Bitwise OR (Setting bits)
    mov rax, [flags]
    or  rax, 0b00001100         ; Set bits 2 and 3

    ; 3. Bitwise XOR (Toggling bits or fast zeroing)
    mov rax, [flags]
    xor rax, 0b11111111         ; Invert lower byte

    ; 4. Bit Shifts
    mov rax, 10
    shl rax, 3                  ; rax = 10 * 2^3 = 80 (Logical Shift Left)
    shr rax, 2                  ; rax = 80 / 4 = 20   (Logical Shift Right)

    ; 5. Arithmetic Shift Right (SAR) vs Logical (SHR)
    ; SAR preserves the sign bit (MSB), essential for negative numbers!
    mov rax, -16
    sar rax, 2                  ; rax = -16 / 4 = -4
    mov [result], rax

    ; 6. Bit Test (BT)
    ; Tests if bit 4 is set without modifying register, sets CF
    bt  qword [flags], 4        ; checks bit 4 -> CF = 1

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
