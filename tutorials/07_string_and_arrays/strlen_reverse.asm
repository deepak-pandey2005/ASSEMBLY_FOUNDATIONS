; ==============================================================================
; Program: strlen_reverse.asm
; Description: Calculates length of a string and reverses it in-place using pointers
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
;
; static char msg[] = "Assembly Rocks!"; // null-terminated string
;
; size_t my_strlen(const char *str) {
;     size_t len = 0;
;     while (str[len] != '\0') {
;         len++;
;     }
;     return len;
; }
;
; void my_reverse_string(char *str) {
;     size_t len = my_strlen(str);
;     if (len <= 1) return;
;
;     char *left = str;
;     char *right = str + len - 1;
;     while (left < right) {
;         char tmp = *left;
;         *left = *right;
;         *right = tmp;
;         left++;
;         right--;
;     }
; }
;
; int main(void) {
;     my_reverse_string(msg);
;     size_t len = my_strlen(msg);
;     write(STDOUT_FILENO, msg, len);
;     write(STDOUT_FILENO, "\n", 1);
;     _exit(0);
; }
; ==============================================================================

section .data
    msg: db "Assembly Rocks!", 0
    newline: db 10

section .text
global _start

; ------------------------------------------------------------------------------
; strlen: Calculate length of null-terminated string at RDI
; Signature (C): size_t my_strlen(const char *str)
; Returns length in RAX
; ------------------------------------------------------------------------------
strlen:
    xor rax, rax                ; size_t len = 0;
.loop:
    cmp byte [rdi + rax], 0     ; if (str[len] == '\0') break;
    je .done
    inc rax                     ; len++;
    jmp .loop
.done:
    ret                         ; return len;

; ------------------------------------------------------------------------------
; reverse_string: Reverses null-terminated string in RDI in-place
; Signature (C): void my_reverse_string(char *str)
; ------------------------------------------------------------------------------
reverse_string:
    push rbx                    ; preserve callee-saved registers
    push r12
    push r13

    mov r12, rdi                ; char *left = str;
    call strlen
    mov r13, rax                ; size_t len = strlen(str);

    test r13, r13
    jle .done_rev               ; if (len <= 0) return;

    lea rbx, [r12 + r13 - 1]    ; char *right = str + len - 1;

.rev_loop:
    cmp r12, rbx                ; while (left < right)
    jge .done_rev

    ; Swap bytes: char tmp = *left; *left = *right; *right = tmp;
    mov al, [r12]
    mov dl, [rbx]
    mov [r12], dl
    mov [rbx], al

    inc r12                     ; left++;
    dec rbx                     ; right--;
    jmp .rev_loop

.done_rev:
    pop r13                     ; restore callee-saved registers
    pop r12
    pop rbx
    ret

; ------------------------------------------------------------------------------
; Program Entry Point: int main(void)
; ------------------------------------------------------------------------------
_start:
    ; 1. Reverse string in-place
    ; C equivalent: my_reverse_string(msg);
    lea rdi, [msg]
    call reverse_string

    ; 2. Print reversed string to stdout
    ; C equivalent: write(1, msg, strlen(msg));
    lea rdi, [msg]
    call strlen
    mov rdx, rax                ; byte count
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [msg]              ; buffer
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    ; Clean exit
    ; C equivalent: _exit(0);
    mov rax, 60
    xor rdi, rdi
    syscall
