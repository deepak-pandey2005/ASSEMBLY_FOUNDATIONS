; ==============================================================================
; Program: ansi_canvas.asm
; Description: Terminal UI rendering with ANSI escape codes and colors
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
;
; static const char clear_screen[] = "\033[2J\033[H";
; static const char c_cyan[]       = "\033[1;36m";
; static const char c_green[]      = "\033[1;32m";
; static const char c_reset[]      = "\033[0m\n";
;
; static const char title_box[] =
;     "+================================================+\n"
;     "|   ASSEMBLY FOUNDATIONS TERMINAL CANVAS UI      |\n"
;     "+================================================+\n";
;
; static const char status_line[] =
;     "[+] Pure x86-64 Assembly Direct Terminal Control!\n"
;     "[+] Framebuffer rendering active. Zero dependencies.\n";
;
; int main(void) {
;     write(STDOUT_FILENO, clear_screen, sizeof(clear_screen) - 1);
;     write(STDOUT_FILENO, c_cyan, sizeof(c_cyan) - 1);
;     write(STDOUT_FILENO, title_box, sizeof(title_box) - 1);
;     write(STDOUT_FILENO, c_green, sizeof(c_green) - 1);
;     write(STDOUT_FILENO, status_line, sizeof(status_line) - 1);
;     write(STDOUT_FILENO, c_reset, sizeof(c_reset) - 1);
;     _exit(0);
; }
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
    ; C equivalent: write(1, clear_screen, len_clear);
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [clear_screen]
    mov rdx, len_clear
    syscall

    ; 2. Set color to Cyan
    ; C equivalent: write(1, c_cyan, len_cyan);
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_cyan]
    mov rdx, len_cyan
    syscall

    ; 3. Draw Title Box
    ; C equivalent: write(1, title_box, len_title);
    mov rax, 1
    mov rdi, 1
    lea rsi, [title_box]
    mov rdx, len_title
    syscall

    ; 4. Set color to Green
    ; C equivalent: write(1, c_green, len_green);
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_green]
    mov rdx, len_green
    syscall

    ; 5. Print Status Messages
    ; C equivalent: write(1, status_line, len_status);
    mov rax, 1
    mov rdi, 1
    lea rsi, [status_line]
    mov rdx, len_status
    syscall

    ; 6. Reset Color and Output Final Newline
    ; C equivalent: write(1, c_reset, len_reset);
    mov rax, 1
    mov rdi, 1
    lea rsi, [c_reset]
    mov rdx, len_reset
    syscall

    ; Exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
