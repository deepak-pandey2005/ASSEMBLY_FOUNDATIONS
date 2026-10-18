; ==============================================================================
; Program: arithmetic.asm
; Description: Addition, subtraction, multi-word carry, multiplication and division
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    val1: dq 100
    val2: dq 30

section .bss
    sum:       resq 1
    diff:      resq 1
    product:   resq 1
    quotient:  resq 1
    remainder: resq 1

section .text
global _start

_start:
    ; 1. Basic Addition & Subtraction
    mov rax, [val1]             ; rax = 100
    add rax, [val2]             ; rax = 130
    mov [sum], rax

    mov rax, [val1]             ; rax = 100
    sub rax, [val2]             ; rax = 70
    mov [diff], rax

    ; 2. Multiplication (IMUL - signed)
    ; 2-operand form: dest = dest * src
    mov rax, [val1]
    imul rax, [val2]            ; rax = 100 * 30 = 3000
    mov [product], rax

    ; 3. Division (IDIV - signed 64-bit)
    ; Dividend must be in RDX:RAX
    mov rax, [val1]             ; rax = 100
    cqo                         ; Sign-extend RAX into RDX:RAX (RDX becomes 0 for positive)
    mov rbx, [val2]             ; divisor = 30
    idiv rbx                    ; rax = quotient (3), rdx = remainder (10)

    mov [quotient], rax         ; store 3
    mov [remainder], rdx        ; store 10

    ; 4. Multi-precision Addition with Carry (ADC)
    ; Example: Adding two 128-bit integers represented by two quadwords each
    mov rax, 0xFFFFFFFFFFFFFFFF ; Max 64-bit int
    add rax, 1                  ; Causes unsigned overflow -> CF (Carry Flag) is set to 1, RAX = 0
    mov rbx, 10
    adc rbx, 0                  ; rbx = 10 + 0 + CF = 11

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
