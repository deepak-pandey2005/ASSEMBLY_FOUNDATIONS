; ==============================================================================
; Program: strlen_reverse.asm
; Description: Calculates length of a string and reverses it in-place using pointers
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    msg: db "Assembly Rocks!", 0
    newline: db 10

section .text
global _start

; ------------------------------------------------------------------------------
; strlen: Calculate length of null-terminated string at RDI
; Returns length in RAX
; ------------------------------------------------------------------------------
strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; ------------------------------------------------------------------------------
; reverse_string: Reverses null-terminated string in RDI in-place
; ------------------------------------------------------------------------------
reverse_string:
    push rbx
    push r12
    push r13

    mov r12, rdi            ; r12 = start pointer
    call strlen
    mov r13, rax            ; r13 = length

    test r13, r13
    jle .done_rev

    lea rbx, [r12 + r13 - 1]; rbx = end pointer (points to last character)

.rev_loop:
    cmp r12, rbx
    jge .done_rev

    ; Swap bytes at [r12] and [rbx]
    mov al, [r12]
    mov dl, [rbx]
    mov [r12], dl
    mov [rbx], al

    inc r12
    dec rbx
    jmp .rev_loop

.done_rev:
    pop r13
    pop r12
    pop rbx
    ret

_start:
    ; 1. Reverse the string in-place
    mov rdi, msg
    call reverse_string

    ; 2. Print reversed string
    mov rdi, msg
    call strlen
    mov rdx, rax            ; length
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg            ; reversed buffer
    syscall

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
