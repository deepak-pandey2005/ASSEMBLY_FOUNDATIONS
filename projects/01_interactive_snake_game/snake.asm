; ==============================================================================
; Project: snake.asm
; Description: Fully playable terminal Snake game in pure x86-64 Linux assembly
; Assembler: NASM (Intel syntax)
; Linker: GNU ld (no libc)

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <termios.h>
; #include <unistd.h>
; #include <time.h>
; #include <stdlib.h>
; #include <stdbool.h>
;
; #define BOARD_W 40
; #define BOARD_H 20
;
; typedef struct { int x, y; } Point;
; static Point snake[400];
; static int snake_len = 4;
; static int dir_x = 1, dir_y = 0;
; static Point food = { 20, 10 };
; static int score = 0;
; static bool game_over = false;
;
; int main(void) {
;     // 1. Enter terminal raw mode (disable canonical buffer and echo)
;     struct termios orig_t, raw_t;
;     tcgetattr(0, &orig_t);
;     raw_t = orig_t;
;     raw_t.c_lflag &= ~(ICANON | ECHO);
;     tcsetattr(0, TCSANOW, &raw_t);
;
;     // 2. Hide cursor and clear terminal
;     write(1, "\033[2J\033[H\033[?25l", 14);
;
;     // Initialize snake body
;     for (int i = 0; i < snake_len; i++) {
;         snake[i].x = 10 - i; snake[i].y = 10;
;     }
;
;     struct timespec frame_delay = { .tv_sec = 0, .tv_nsec = 80000000 }; // 80ms
;
;     while (!game_over) {
;         // 3. Render board, snake, and food via ANSI escapes
;         // 4. Non-blocking input read (W/A/S/D/Q)
;         // 5. Shift snake segments: snake[i] = snake[i-1]
;         // 6. Update head: snake[0].x += dir_x; snake[0].y += dir_y;
;         // 7. Check collisions (walls: 0..BOARD_W, 0..BOARD_H; self-collision)
;         // 8. Check food eaten: score += 10, snake_len++, spawn_new_food()
;         nanosleep(&frame_delay, NULL);
;     }
;
;     // Restore terminal settings and exit
;     tcsetattr(0, TCSANOW, &orig_t);
;     write(1, "\033[?25h\033[0m\n", 9);
;     _exit(0);
; }
; ==============================================================================

section .data
    ; ANSI Codes
    clear_screen: db 27, "[2J", 27, "[H", 27, "[?25l" ; clear + hide cursor
    len_clear:    equ $ - clear_screen

    show_cursor:  db 27, "[?25h", 27, "[0m", 10
    len_show_cur: equ $ - show_cursor

    c_border:     db 27, "[1;34m"                       ; Blue
    len_c_border: equ $ - c_border

    c_snake:      db 27, "[1;32m"                       ; Green
    len_c_snake:  equ $ - c_snake

    c_food:       db 27, "[1;31m"                       ; Red
    len_c_food:   equ $ - c_food

    c_reset:      db 27, "[0m"
    len_c_reset:  equ $ - c_reset

    msg_title:    db "=== ASSEMBLY SNAKE === [W/A/S/D to move, Q to quit]", 10
    len_title:    equ $ - msg_title

    msg_gameover: db 27, "[12;15H", 27, "[1;31m*** GAME OVER! *** Final Score: "
    len_gameover: equ $ - msg_gameover

    ; Board settings (20 rows x 40 cols)
    BOARD_W       equ 40
    BOARD_H       equ 20

    ; Initial state
    dir_x:        dd 1                                  ; Moving right (+1, 0)
    dir_y:        dd 0
    snake_len:    dd 4
    score:        dd 0
    game_over:    db 0

    ; Delay between frames: 80 ms (80,000,000 ns)
    align 8
    frame_delay:
        dq 0                                            ; tv_sec
        dq 80000000                                     ; tv_nsec (80 ms)

section .bss
    ; termios structures (60 bytes each on Linux x86_64)
    orig_termios: resb 64
    raw_termios:  resb 64

    key_buf:      resb 4
    score_str:    resb 16

    ; Snake segment coordinate arrays (max 400 segments)
    snake_x:      resd 400
    snake_y:      resd 400

    food_x:       resd 1
    food_y:       resd 1

    ; Screen frame buffer for line drawing (row of 42 chars + newline)
    row_buf:      resb 48

section .text
global _start

; ------------------------------------------------------------------------------
; Helper: Print string
; RDI = string, RSI = length
; ------------------------------------------------------------------------------
print_str:
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 1                  ; sys_write
    mov rdx, rsi                ; length
    mov rsi, rdi                ; buffer
    mov rdi, 1                  ; stdout
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; ------------------------------------------------------------------------------
; Terminal: Set Raw Non-Blocking Mode
; ------------------------------------------------------------------------------
set_raw_terminal:
    ; Get current termios: sys_ioctl(0, TCGETS(0x5401), orig_termios)
    mov rax, 16                 ; sys_ioctl
    mov rdi, 0                  ; stdin
    mov rsi, 0x5401             ; TCGETS
    lea rdx, [orig_termios]
    syscall

    ; Copy orig to raw
    cld
    lea rsi, [orig_termios]
    lea rdi, [raw_termios]
    mov rcx, 60
    rep movsb

    ; Disable ICANON (bit 1) and ECHO (bit 3) in c_lflag (offset 12)
    and dword [raw_termios + 12], ~(0x00000002 | 0x00000008)

    ; Set non-blocking read: VMIN=0 (offset 22), VTIME=0 (offset 23)
    mov byte [raw_termios + 22], 0 ; VMIN
    mov byte [raw_termios + 23], 0 ; VTIME

    ; Apply raw termios: sys_ioctl(0, TCSETS(0x5402), raw_termios)
    mov rax, 16
    mov rdi, 0
    mov rsi, 0x5402             ; TCSETS
    lea rdx, [raw_termios]
    syscall
    ret

; ------------------------------------------------------------------------------
; Terminal: Restore Original Mode
; ------------------------------------------------------------------------------
restore_terminal:
    mov rax, 16                 ; sys_ioctl
    mov rdi, 0
    mov rsi, 0x5402             ; TCSETS
    lea rdx, [orig_termios]
    syscall

    ; Show cursor and reset colors
    lea rdi, [show_cursor]
    mov rsi, len_show_cur
    call print_str
    ret

; ------------------------------------------------------------------------------
; Game: Render the Board and Objects
; ------------------------------------------------------------------------------
render_board:
    ; Move cursor home
    lea rdi, [clear_screen]
    mov rsi, len_clear
    call print_str

    ; Print title
    lea rdi, [msg_title]
    mov rsi, len_title
    call print_str

    ; Draw Top Border (Blue)
    lea rdi, [c_border]
    mov rsi, len_c_border
    call print_str

    mov byte [row_buf], '#'
    mov rcx, BOARD_W
    lea rdi, [row_buf + 1]
    mov al, '#'
    rep stosb
    mov byte [rdi], '#'
    mov byte [rdi + 1], 10
    mov byte [rdi + 2], 0
    lea rdi, [row_buf]
    mov rsi, BOARD_W + 3
    call print_str

    ; Draw Grid Rows Y = 0 .. BOARD_H-1
    xor r12d, r12d              ; row Y = 0

.row_loop:
    cmp r12d, BOARD_H
    jge .board_bottom

    lea rdi, [row_buf]
    mov byte [rdi], '#'         ; Left wall
    inc rdi

    xor r13d, r13d              ; col X = 0
.col_loop:
    cmp r13d, BOARD_W
    jge .row_end

    ; Check if (r13d, r12d) is Snake Head
    cmp r13d, [snake_x]
    jne .check_body
    cmp r12d, [snake_y]
    jne .check_body
    mov byte [rdi], '@'         ; Snake head
    jmp .next_col

.check_body:
    ; Check if in snake segments 1..snake_len-1
    mov ebx, 1
.body_check_loop:
    cmp ebx, [snake_len]
    jge .check_food
    cmp r13d, [snake_x + rbx*4]
    jne .next_seg
    cmp r12d, [snake_y + rbx*4]
    jne .next_seg
    mov byte [rdi], 'o'         ; Snake body
    jmp .next_col
.next_seg:
    inc ebx
    jmp .body_check_loop

.check_food:
    ; Check if Food
    cmp r13d, [food_x]
    jne .empty_cell
    cmp r12d, [food_y]
    jne .empty_cell
    mov byte [rdi], '*'         ; Food item
    jmp .next_col

.empty_cell:
    mov byte [rdi], ' '         ; Empty space

.next_col:
    inc rdi
    inc r13d
    jmp .col_loop

.row_end:
    mov byte [rdi], '#'         ; Right wall
    mov byte [rdi + 1], 10      ; Newline
    inc rdi
    inc rdi
    lea rsi, [row_buf]
    mov rdx, rdi
    sub rdx, rsi                ; len
    mov rdi, rsi
    mov rsi, rdx
    call print_str

    inc r12d
    jmp .row_loop

.board_bottom:
    ; Draw Bottom Border
    mov byte [row_buf], '#'
    mov rcx, BOARD_W
    lea rdi, [row_buf + 1]
    mov al, '#'
    rep stosb
    mov byte [rdi], '#'
    mov byte [rdi + 1], 10
    mov byte [rdi + 2], 0
    lea rdi, [row_buf]
    mov rsi, BOARD_W + 3
    call print_str

    ; Reset color
    lea rdi, [c_reset]
    mov rsi, len_c_reset
    call print_str
    ret

; ------------------------------------------------------------------------------
; Read Keyboard Input (Non-blocking)
; ------------------------------------------------------------------------------
process_input:
    mov rax, 0                  ; sys_read
    mov rdi, 0                  ; stdin
    lea rsi, [key_buf]
    mov rdx, 1
    syscall

    cmp rax, 1
    jne .no_input

    mov al, [key_buf]
    ; Case insensitive handling
    cmp al, 'w'
    je .move_up
    cmp al, 'W'
    je .move_up

    cmp al, 's'
    je .move_down
    cmp al, 'S'
    je .move_down

    cmp al, 'a'
    je .move_left
    cmp al, 'A'
    je .move_left

    cmp al, 'd'
    je .move_right
    cmp al, 'D'
    je .move_right

    cmp al, 'q'
    je .quit
    cmp al, 'Q'
    je .quit
    ret

.move_up:
    ; Prevent 180 reverse if moving down
    cmp dword [dir_y], 1
    je .no_input
    mov dword [dir_x], 0
    mov dword [dir_y], -1
    ret

.move_down:
    cmp dword [dir_y], -1
    je .no_input
    mov dword [dir_x], 0
    mov dword [dir_y], 1
    ret

.move_left:
    cmp dword [dir_x], 1
    je .no_input
    mov dword [dir_x], -1
    mov dword [dir_y], 0
    ret

.move_right:
    cmp dword [dir_x], -1
    je .no_input
    mov dword [dir_x], 1
    mov dword [dir_y], 0
    ret

.quit:
    mov byte [game_over], 1
.no_input:
    ret

; ------------------------------------------------------------------------------
; Game Logic: Update Snake Positions & Collisions
; ------------------------------------------------------------------------------
update_game:
    ; Shift tail segments forward: segment[i] = segment[i - 1]
    mov ecx, [snake_len]
    dec ecx                     ; i = len - 1

.shift_loop:
    cmp ecx, 0
    jle .update_head
    mov eax, [snake_x + rcx*4 - 4]
    mov [snake_x + rcx*4], eax
    mov eax, [snake_y + rcx*4 - 4]
    mov [snake_y + rcx*4], eax
    dec ecx
    jmp .shift_loop

.update_head:
    ; Update head: snake_x[0] += dir_x, snake_y[0] += dir_y
    mov eax, [snake_x]
    add eax, [dir_x]
    mov [snake_x], eax

    mov eax, [snake_y]
    add eax, [dir_y]
    mov [snake_y], eax

    ; Check Wall Collisions (X in 0..BOARD_W-1, Y in 0..BOARD_H-1)
    cmp dword [snake_x], 0
    jl .collision
    cmp dword [snake_x], BOARD_W
    jge .collision
    cmp dword [snake_y], 0
    jl .collision
    cmp dword [snake_y], BOARD_H
    jge .collision

    ; Check Self-Collision
    mov ecx, 1
.self_loop:
    cmp ecx, [snake_len]
    jge .check_food_collision
    mov eax, [snake_x]
    cmp eax, [snake_x + rcx*4]
    jne .next_self
    mov eax, [snake_y]
    cmp eax, [snake_y + rcx*4]
    je .collision
.next_self:
    inc ecx
    jmp .self_loop

.check_food_collision:
    mov eax, [snake_x]
    cmp eax, [food_x]
    jne .done_update
    mov eax, [snake_y]
    cmp eax, [food_y]
    jne .done_update

    ; Ate food! Grow snake & increment score
    inc dword [snake_len]
    add dword [score], 10

    ; Spawn new food (deterministic pseudo-random wrap)
    mov eax, [food_x]
    imul eax, 7
    add eax, 13
    xor edx, edx
    mov ebx, BOARD_W - 2
    div ebx
    inc edx
    mov [food_x], edx

    mov eax, [food_y]
    imul eax, 11
    add eax, 17
    xor edx, edx
    mov ebx, BOARD_H - 2
    div ebx
    inc edx
    mov [food_y], edx

.done_update:
    ret

.collision:
    mov byte [game_over], 1
    ret

; ------------------------------------------------------------------------------
; Main Program Entry Point
; ------------------------------------------------------------------------------
_start:
    ; Initialize Snake Head at (10, 10)
    mov dword [snake_x], 10
    mov dword [snake_y], 10

    ; Initial body segments
    mov dword [snake_x + 4], 9
    mov dword [snake_y + 4], 10
    mov dword [snake_x + 8], 8
    mov dword [snake_y + 8], 10
    mov dword [snake_x + 12], 7
    mov dword [snake_y + 12], 10

    ; Initial food position
    mov dword [food_x], 25
    mov dword [food_y], 8

    ; Setup raw terminal mode
    call set_raw_terminal

.game_loop:
    cmp byte [game_over], 0
    jne .end_game

    call render_board
    call process_input
    call update_game

    ; Frame delay: sys_nanosleep(80ms)
    mov rax, 35                 ; sys_nanosleep
    lea rdi, [frame_delay]
    xor rsi, rsi
    syscall

    jmp .game_loop

.end_game:
    call restore_terminal

    ; Print Game Over notification
    lea rdi, [msg_gameover]
    mov rsi, len_gameover
    call print_str

    ; Clean Exit
    mov rax, 60
    xor rdi, rdi
    syscall
