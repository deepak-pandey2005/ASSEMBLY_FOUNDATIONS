; ==============================================================================
; Program: loop_sum.asm
; Description: Compute sum of 1..N and iterate through an integer array
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    array: dq 10, 20, 30, 40, 50
    array_len: equ 5

section .bss
    total: resq 1

section .text
global _start

_start:
    ; 1. Calculate sum of 1 to 10
    xor rax, rax            ; accumulator (sum = 0)
    mov rcx, 1              ; loop counter (i = 1)

.for_loop:
    cmp rcx, 10
    jg .loop_end
    add rax, rcx            ; sum += i
    inc rcx                 ; i++
    jmp .for_loop

.loop_end:
    ; RAX is now 55 (1+2+3+4+5+6+7+8+9+10)

    ; 2. Iterate through array and sum elements
    xor r8, r8              ; array sum = 0
    xor rsi, rsi            ; index = 0

.array_loop:
    cmp rsi, array_len
    jge .done_array

    add r8, [array + rsi*8] ; r8 += array[rsi]
    inc rsi
    jmp .array_loop

.done_array:
    mov [total], r8         ; total = 150

    ; Exit with status 0
    mov rax, 60
    xor rdi, rdi
    syscall
