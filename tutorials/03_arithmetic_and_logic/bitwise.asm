; ==============================================================================
; Program: bitwise.asm
; Description: AND, OR, XOR, NOT, Bit-shifts (SHL, SHR, SAR) and bit-test (BT)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <stdbool.h>
; #include <unistd.h>
;
; static uint64_t flags = 0b10110011; // 0xB3 = 179 in decimal
; static int64_t  result;
;
; int main(void) {
;     // 1. Bitwise AND (Masking)
;     uint64_t a = flags & 0x0F;      // 0b10110011 & 0b00001111 = 0b00000011 (3)
;
;     // 2. Bitwise OR (Setting bits)
;     uint64_t b = flags | 0x0C;      // Sets bits 2 and 3
;
;     // 3. Bitwise XOR (Toggling bits)
;     uint64_t c = flags ^ 0xFF;      // Inverts lower 8 bits (NOT operation)
;
;     // 4. Bit Shifts (Logical)
;     uint64_t d = (10ULL << 3) >> 2; // (10 * 8) / 4 = 20
;
;     // 5. Arithmetic Shift Right (Signed division preserving sign bit)
;     int64_t  e = (-16LL) >> 2;      // -16 / 4 = -4
;     result = e;
;
;     // 6. Bit Test
;     bool bit4_set = (flags & (1ULL << 4)) != 0; // checks bit 4 -> true
;
;     _exit(0);
; }
; ==============================================================================

section .data
    ; C equivalent: static uint64_t flags = 0b10110011;
    flags: dq 0b10110011        ; 0xB3 in binary

section .bss
    ; C equivalent: static int64_t result;
    result: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. Bitwise AND (Masking bits)
    ; C equivalent: rax = flags & 0b00001111; // 3
    ; --------------------------------------------------------------------------
    mov rax, [flags]
    and rax, 0b00001111         ; Keep only lower 4 bits -> rax = 0b0011 (3)

    ; --------------------------------------------------------------------------
    ; 2. Bitwise OR (Setting bits)
    ; C equivalent: rax = flags | 0b00001100;
    ; --------------------------------------------------------------------------
    mov rax, [flags]
    or  rax, 0b00001100         ; Set bits 2 and 3

    ; --------------------------------------------------------------------------
    ; 3. Bitwise XOR (Toggling bits or fast zeroing)
    ; C equivalent: rax = flags ^ 0b11111111;
    ; --------------------------------------------------------------------------
    mov rax, [flags]
    xor rax, 0b11111111         ; Invert lower byte

    ; --------------------------------------------------------------------------
    ; 4. Bit Shifts (Logical)
    ; C equivalent: rax = (10 << 3) >> 2;
    ; --------------------------------------------------------------------------
    mov rax, 10
    shl rax, 3                  ; rax = 10 * (2^3) = 80 (Logical Shift Left)
    shr rax, 2                  ; rax = 80 / (2^2) = 20 (Logical Shift Right)

    ; --------------------------------------------------------------------------
    ; 5. Arithmetic Shift Right (SAR) vs Logical (SHR)
    ; SAR preserves the sign bit (MSB), essential for signed negative numbers!
    ; C equivalent: result = (-16) >> 2; // -4
    ; --------------------------------------------------------------------------
    mov rax, -16
    sar rax, 2                  ; rax = -16 / 4 = -4 (sign bit 1 replicated)
    mov [result], rax

    ; --------------------------------------------------------------------------
    ; 6. Bit Test (BT)
    ; Tests if bit index 4 is set without modifying register; copies bit to CF.
    ; C equivalent: bool is_set = (flags & (1 << 4)) != 0;
    ; --------------------------------------------------------------------------
    bt  qword [flags], 4        ; checks bit 4 -> CF = 1

    ; Clean exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
