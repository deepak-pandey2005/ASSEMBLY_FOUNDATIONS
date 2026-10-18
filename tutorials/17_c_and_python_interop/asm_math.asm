; ==============================================================================
; Program: asm_math.asm
; Description: Native math kernel exportable to C and Python via System V ABI
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .text
global fast_multiply_add
global fast_factorial

; ------------------------------------------------------------------------------
; int64_t fast_multiply_add(int64_t a, int64_t b, int64_t c)
; Computes: (a * b) + c
; ABI Registers:
;   RDI = a
;   RSI = b
;   RDX = c
; Returns in RAX
; ------------------------------------------------------------------------------
fast_multiply_add:
    mov rax, rdi        ; rax = a
    imul rax, rsi       ; rax = a * b
    add rax, rdx        ; rax = (a * b) + c
    ret

; ------------------------------------------------------------------------------
; int64_t fast_factorial(int64_t n)
; Computes n! iteratively
; ABI: RDI = n, Returns in RAX
; ------------------------------------------------------------------------------
fast_factorial:
    mov rax, 1          ; result = 1
    cmp rdi, 1
    jle .done

.loop:
    imul rax, rdi       ; result *= n
    dec rdi             ; n--
    cmp rdi, 1
    jg .loop

.done:
    ret
