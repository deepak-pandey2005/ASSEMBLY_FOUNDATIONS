; ==============================================================================
; Program: addressing_modes.asm
; Description: Demonstrates all x86-64 memory addressing modes and LEA instruction
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; static int64_t array[5] = {10, 25, 45, 70, 95};
; static int64_t val = 1337;
;
; int main(void) {
;     int64_t rax = val;                      // 1. Direct: 1337
;     int64_t *rbx = array;                   // 2. Register Indirect pointer: &array[0]
;     int64_t rcx = *rbx;                     //    rcx = array[0] = 10
;     int64_t rdx = *(rbx + 1);               // 3. Base + Offset: array[1] = 25
;     size_t  rdi = 3;                        // 4. Index: 3
;     int64_t r8  = array[rdi];               //    r8 = array[3] = 70
;     int64_t r9  = array[rdi - 1];           // 5. Base + (Index*Scale) - Offset: array[2] = 45
;     int64_t *r10 = &array[rdi];             // 6. LEA (Address-of): &array[3]
;     int64_t r11 = rdi * 9 + 4;              //    Fast arithmetic via LEA: 31
;
;     _exit(0);
; }
; ==============================================================================

section .data
    ; C equivalent: static int64_t array[5] = {10, 25, 45, 70, 95};
    array: dq 10, 25, 45, 70, 95

    ; C equivalent: static int64_t val = 1337;
    val:   dq 1337

section .text
global _start

_start:
    ; 1. Direct Addressing: load from an absolute symbol/offset
    ; C equivalent: int64_t rax = val;
    mov rax, [val]              ; rax = 1337

    ; 2. Register Indirect: address is stored in a register
    ; C equivalent: int64_t *rbx = &array[0]; int64_t rcx = *rbx;
    lea rbx, [array]            ; rbx = &array[0] (pointer to array start)
    mov rcx, [rbx]              ; rcx = *rbx = array[0] = 10

    ; 3. Base + Displacement: offset by a constant byte distance (8 bytes = 1 uint64_t)
    ; C equivalent: int64_t rdx = *(rbx + 1); // array[1]
    mov rdx, [rbx + 8]          ; rdx = *(rbx + 8 bytes) = array[1] = 25

    ; 4. Base + (Index * Scale): standard array indexing
    ;    scale can be 1 (char), 2 (short), 4 (int), or 8 (int64_t)
    ; C equivalent: size_t rdi = 3; int64_t r8 = array[rdi];
    mov rdi, 3                  ; rdi = 3 (index)
    mov r8, [rbx + rdi*8]       ; r8 = array[3] = 70

    ; 5. Base + (Index * Scale) + Displacement
    ; C equivalent: int64_t r9 = array[rdi - 1]; // array[2]
    mov r9, [rbx + rdi*8 - 8]   ; r9 = array[2] = 45

    ; 6. LEA (Load Effective Address):
    ;    Computes pointer arithmetic (&array[3]) without fetching memory!
    ; C equivalent: int64_t *r10 = &array[rdi];
    lea r10, [rbx + rdi*8]      ; r10 = &array[3] (pointer address, NOT the value 70)

    ; LEA can also be used for zero-latency 3-operand integer arithmetic:
    ; C equivalent: int64_t r11 = rdi * 9 + 4; // 3 * 9 + 4 = 31
    lea r11, [rdi + rdi*8 + 4]  ; r11 = rdi + (rdi * 8) + 4 = 3 + 24 + 4 = 31

    ; Clean exit returning 0
    ; C equivalent: _exit(0);
    mov rax, 60                 ; rax = SYS_exit (60)
    xor rdi, rdi                ; rdi = 0 (status = 0)
    syscall
