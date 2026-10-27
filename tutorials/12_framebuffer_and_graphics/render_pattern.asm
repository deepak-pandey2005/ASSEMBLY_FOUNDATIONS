; ==============================================================================
; Program: render_pattern.asm
; Description: Generates a 256x256 24-bit RGB graphical image (PPM P6 format)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <fcntl.h>
; #include <unistd.h>
; #include <stdint.h>
;
; static uint8_t pixel_buf[256 * 256 * 3]; // 196,608 bytes (256x256 24-bit RGB)
;
; int main(void) {
;     // 1. Generate pixel data (fractal pattern)
;     size_t ptr = 0;
;     for (uint32_t y = 0; y < 256; y++) {
;         for (uint32_t x = 0; x < 256; x++) {
;             pixel_buf[ptr++] = (uint8_t)x;           // Red: X coordinate
;             pixel_buf[ptr++] = (uint8_t)y;           // Green: Y coordinate
;             pixel_buf[ptr++] = (uint8_t)(x ^ y);     // Blue: X XOR Y (fractal)
;         }
;     }
;
;     // 2. Open canvas.ppm file
;     int fd = open("canvas.ppm", O_CREAT | O_WRONLY | O_TRUNC, 0644);
;
;     // 3. Write PPM P6 Header
;     const char header[] = "P6\n256 256\n255\n";
;     write(fd, header, sizeof(header) - 1);
;
;     // 4. Write pixel buffer
;     write(fd, pixel_buf, sizeof(pixel_buf));
;     close(fd);
;
;     write(STDOUT_FILENO, "[+] Rendered 256x256 image to canvas.ppm successfully!\n", 56);
;     _exit(0);
; }
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
    ; C equivalent:
    ;   for (int y = 0; y < 256; y++) {
    ;       for (int x = 0; x < 256; x++) {
    ;           *p++ = x; *p++ = y; *p++ = x ^ y;
    ;       }
    ;   }
    ; --------------------------------------------------------------------------
    lea rdi, [pixel_buf]        ; pointer to current pixel byte in buffer
    xor rbx, rbx                ; uint32_t y = 0 (0 .. 255)

.y_loop:
    cmp rbx, 256                ; if (y >= 256) goto done_rendering;
    jge .done_rendering

    xor rcx, rcx                ; uint32_t x = 0 (0 .. 255)

.x_loop:
    cmp rcx, 256                ; if (x >= 256) goto next_row;
    jge .next_row

    ; Compute Red: X coordinate
    mov byte [rdi], cl          ; *rdi = (uint8_t)x;
    inc rdi

    ; Compute Green: Y coordinate
    mov byte [rdi], bl          ; *rdi = (uint8_t)y;
    inc rdi

    ; Compute Blue: X XOR Y (creates classic demoscene fractal pattern!)
    mov al, cl
    xor al, bl
    mov byte [rdi], al          ; *rdi = (uint8_t)(x ^ y);
    inc rdi

    inc rcx                     ; x++;
    jmp .x_loop

.next_row:
    inc rbx                     ; y++;
    jmp .y_loop

.done_rendering:
    ; --------------------------------------------------------------------------
    ; 2. CREATE / OPEN PPM FILE ON DISK
    ; C equivalent: int fd = open("canvas.ppm", O_CREAT|O_WRONLY|O_TRUNC, 0644);
    ; --------------------------------------------------------------------------
    mov rax, 2                  ; rax = SYS_open (2)
    lea rdi, [filename]         ; "canvas.ppm"
    mov rsi, 577                ; flags = O_CREAT(64) | O_WRONLY(1) | O_TRUNC(512) = 577
    mov rdx, 0644o              ; file permissions = 0644 octal
    syscall

    cmp rax, 0
    jl  .error
    mov [fd], rax

    ; --------------------------------------------------------------------------
    ; 3. WRITE PPM P6 HEADER (15 bytes)
    ; C equivalent: write(fd, header, header_len);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; sys_write
    mov rdi, [fd]
    lea rsi, [header]
    mov rdx, header_len
    syscall

    ; --------------------------------------------------------------------------
    ; 4. WRITE 196,608 BYTES OF PIXEL DATA
    ; C equivalent: write(fd, pixel_buf, 196608);
    ; --------------------------------------------------------------------------
    mov rax, 1                  ; sys_write
    mov rdi, [fd]
    lea rsi, [pixel_buf]
    mov rdx, 196608             ; 256 * 256 * 3 bytes
    syscall

    ; --------------------------------------------------------------------------
    ; 5. CLOSE FILE
    ; C equivalent: close(fd);
    ; --------------------------------------------------------------------------
    mov rax, 3                  ; sys_close
    mov rdi, [fd]
    syscall

    ; Print success confirmation
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_done]
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
