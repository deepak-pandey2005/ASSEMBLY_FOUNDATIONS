; =========================
; SECTION: DATA (variables)
; =========================
section .data
    char db 'A'        ; define a byte with value 'A'

; =========================
; SECTION: TEXT (code)
; =========================
section .text
global _start          ; entry point

_start:

    ; -------------------------
    ; write(1, char, 1)
    ; -------------------------
    mov eax, 4         ; syscall number (sys_write)
    mov ebx, 1         ; file descriptor (stdout)
    mov ecx, char      ; address of data
    mov edx, 1         ; number of bytes
    int 0x80           ; invoke kernel

    ; -------------------------
    ; exit(0)
    ; -------------------------
    mov eax, 1         ; syscall number (sys_exit)
    xor ebx, ebx       ; return 0
    int 0x80           ; invoke kernel