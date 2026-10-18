; ==============================================================================
; Program: debug_target.asm
; Description: Target binary designed for GDB exploration (stepping, flags, memory)
; Architecture: x86-64 Linux
; Assembler: NASM
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
    mov rax, 0x1111222233334444
    mov rbx, 0x5555666677778888
    add rax, rbx                ; Check RFLAGS: notice flags changes!

    ; Test overflow flag:
    mov rcx, 0x7FFFFFFFFFFFFFFF ; Max positive signed int64
    add rcx, 1                  ; OF and SF both get set!

    ; Examine string memory:
    lea rsi, [secret]           ; In GDB run: `x/s $rsi`

    ; Test conditional branch:
    cmp rcx, 0
    jl  .was_negative
    mov rdi, 10
    jmp .done

.was_negative:
    mov rdi, 20

.done:
    ; Store into BSS and examine with `x/4xg &workspace`
    mov [workspace], rax
    mov [workspace + 8], rcx

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
