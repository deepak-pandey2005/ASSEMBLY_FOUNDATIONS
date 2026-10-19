; ==============================================================================
; Program: ansi_canvas.asm
; Description: Terminal UI rendering with ANSI escape codes and colors
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    ; ANSI Escape Sequences:
    ; \033[2J = Clear screen, \033[H = Cursor to home (1,1)
    clear_screen: db 27, "[2J", 27, "[H"
    len_clear:    equ $ - clear_screen

    ; Color escape codes
    c_cyan:   db 27, "[1;36m"
    len_cyan: equ $ - c_cyan

    c_green:  db 27, "[1;32m"
    len_green:equ $ - c_green

    c_reset:  db 27, "[0m", 10
    len_reset:equ $ - c_reset

    ; UI Graphics
    title_box:
        db "+================================================+", 10
        db "|   ASSEMBLY FOUNDATIONS TERMINAL CANVAS UI      |", 10
        db "+================================================+", 10
    len_title: equ $ - title_box

    status_line:
        db "[+] Pure x86-64 Assembly Direct Terminal Control!", 10
        db "[+] Framebuffer rendering active. Zero dependencies.", 10
    len_status: equ $ - status_line

section .text
global _start

_start:
    ; 1. Clear screen and move cursor to (1, 1)
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [clear_screen]
    mov rdx, len_clear
    syscall

    ; 2. Set color to Cyan
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_cyan]
    mov rdx, len_cyan
    syscall

    ; 3. Draw Title Box
    mov rax, 1
    mov rdi, 1
    lea rsi, [title_box]
    mov rdx, len_title
    syscall

    ; 4. Set color to Green
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_green]
    mov rdx, len_green
    syscall

    ; 5. Draw Status Lines
    mov rax, 1
    mov rdi, 1
    lea rsi, [status_line]
    mov rdx, len_status
    syscall

    ; 6. Reset terminal colors
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_reset]
    mov rdx, len_reset
    syscall

    ; Clean Exit
    mov rax, 60
    xor rdi, rdi
    syscall
