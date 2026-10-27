; ==============================================================================
; Program: debug_target.asm
; Description: Target binary designed for GDB exploration (stepping, flags, memory)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <stdint.h>
; #include <unistd.h>
;
; static const uint64_t magic_num = 0xCAFEBABE1337BEEFULL;
; static const char     secret[]    = "SecretPasscode";
;
; static uint64_t workspace[4];
;
; int main(void) {
;     // 1. Register addition
;     uint64_t rax = 0x1111222233334444ULL;
;     uint64_t rbx = 0x5555666677778888ULL;
;     rax += rbx; // 0x66668888AAAA CCCC
;
;     // 2. Signed overflow test
;     int64_t rcx = 0x7FFFFFFFFFFFFFFFULL; // INT64_MAX
;     rcx += 1; // Wraps around to negative INT64_MIN (-9223372036854775808), sets SF & OF!
;
;     // 3. String pointer
;     const char *rsi = secret;
;
;     // 4. Branching
;     int64_t rdi;
;     if (rcx < 0) {
;         rdi = 20;
;     } else {
;         rdi = 10;
;     }
;
;     // 5. Store into BSS array
;     workspace[0] = rax;
;     workspace[1] = (uint64_t)rcx;
;
;     _exit(0);
; }
; ==============================================================================

section .data
    magic_num: dq 0xCAFEBABE1337BEEF
    secret:    db "SecretPasscode", 0

section .bss
    workspace: resq 4

section .text
global _start

_start:
    ; [GDB Tip]: Set breakpoint here: `b *_start`
    nop
    mov rax, 0x1111222233334444 ; uint64_t rax = 0x1111222233334444ULL;
    mov rbx, 0x5555666677778888 ; uint64_t rbx = 0x5555666677778888ULL;
    add rax, rbx                ; rax += rbx; (Check RFLAGS in GDB: `info registers eflags`)

    ; Test overflow flag:
    mov rcx, 0x7FFFFFFFFFFFFFFF ; int64_t rcx = INT64_MAX;
    add rcx, 1                  ; rcx += 1; (OF and SF both get set because it wraps to negative!)

    ; Examine string memory:
    lea rsi, [secret]           ; const char *rsi = secret; (In GDB run: `x/s $rsi`)

    ; Test conditional branch:
    cmp rcx, 0                  ; if (rcx < 0)
    jl  .was_negative
    mov rdi, 10                 ; rdi = 10;
    jmp .done

.was_negative:
    mov rdi, 20                 ; rdi = 20;

.done:
    ; Store into BSS and examine with `x/4xg &workspace`
    mov [workspace], rax        ; workspace[0] = rax;
    mov [workspace + 8], rcx    ; workspace[1] = rcx;

    ; Exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
