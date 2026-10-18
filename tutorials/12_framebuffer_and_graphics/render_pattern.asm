; ==============================================================================
; Program: render_pattern.asm
; Description: Generates a 256x256 24-bit RGB graphical image (PPM P6 format)
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    filename: db "canvas.ppm", 0

    ; PPM Header: P6 format, 256 width, 256 height, 255 max color
    header:   db "P6", 10, "256 256", 10, "255", 10
    header_len: equ $ - header

    msg_done: db "[+] Rendered 256x256 image to canvas.ppm successfully!", 10
    len_done: equ $ - msg_done

section .bss
    fd:        resq 1
    ; 256 * 256 pixels * 3 bytes (R, G, B) = 196,608 bytes
    pixel_buf: resb 196608

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. GENERATE PIXEL DATA IN MEMORY
    ; Color formula: Red = X, Green = Y, Blue = (X XOR Y)
    ; --------------------------------------------------------------------------
    lea rdi, [pixel_buf]        ; pointer to current pixel byte in buffer
    xor rbx, rbx                ; Y coordinate (0 .. 255)

.y_loop:
    cmp rbx, 256
    jge .done_rendering

    xor rcx, rcx                ; X coordinate (0 .. 255)

.x_loop:
    cmp rcx, 256
    jge .next_row

    ; Compute Red: X coordinate
    mov byte [rdi], cl          ; R = X
    inc rdi

    ; Compute Green: Y coordinate
    mov byte [rdi], bl          ; G = Y
    inc rdi

    ; Compute Blue: X XOR Y (creates classic demoscene fractal pattern!)
    mov al, cl
    xor al, bl
    mov byte [rdi], al          ; B = X XOR Y
    inc rdi

    inc rcx                     ; X++
    jmp .x_loop

.next_row:
    inc rbx                     ; Y++
    jmp .y_loop

.done_rendering:
    ; --------------------------------------------------------------------------
    ; 2. CREATE AND OPEN FILE: sys_open("canvas.ppm", O_CREAT|O_WRONLY|O_TRUNC, 0644)
    ; Flags: O_CREAT(64) | O_WRONLY(1) | O_TRUNC(512) = 577 (0x241)
    ; Mode:  0644 (octal) = 420 (decimal)
    ; --------------------------------------------------------------------------
    mov rax, 2                  ; sys_open
    mov rdi, filename
    mov rsi, 577                ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 420                ; 0644 permissions
    syscall

    cmp rax, 0
    jl  .error
    mov [fd], rax

    ; --------------------------------------------------------------------------
    ; 3. WRITE PPM HEADER
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; sys_write
    mov rdi, [fd]
    mov rsi, header
    mov rdx, header_len
    syscall

    ; --------------------------------------------------------------------------
    ; 4. WRITE PIXEL BUFFER
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; sys_write
    mov rdi, [fd]
    mov rsi, pixel_buf
    mov rdx, 196608             ; 256 * 256 * 3 bytes
    syscall

    ; --------------------------------------------------------------------------
    ; 5. CLOSE FILE
    ; --------------------------------------------------------------------------
    mov rax, 3                  ; sys_close
    mov rdi, [fd]
    syscall

    ; Print success message
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, msg_done
    mov rdx, len_done
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
