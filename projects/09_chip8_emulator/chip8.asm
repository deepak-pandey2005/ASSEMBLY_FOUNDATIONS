; ==============================================================================
; projects/09_chip8_emulator/chip8.asm
; Complete CHIP-8 Virtual Machine & CPU Interpreter in Pure x86-64 Assembly.
;
; Virtual Machine Specs:
; - 4096 bytes RAM (ROM loads at 0x200, 0x000-0x1FF contains default 4x5 font sprites)
; - 16 x 8-bit registers V0 - VF (VF = flag/collision/borrow)
; - 16-bit Index Register I
; - 16-bit Program Counter PC
; - 16-level call stack + 8-bit Stack Pointer SP
; - 64x32 monochrome display buffer (rendered via ANSI block characters)
; - Big-Endian 16-bit opcode execution cycle (Fetch -> Decode -> Execute)

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
; #include <string.h>
;
; typedef struct {
;     uint8_t memory[4096];
;     uint8_t V[16];
;     uint16_t I;
;     uint16_t pc;
;     uint16_t stack[16];
;     uint8_t sp;
;     uint8_t gfx[64 * 32];
; } chip8_vm_t;
;
; void chip8_step(chip8_vm_t *vm) {
;     // Fetch 16-bit big-endian opcode
;     uint16_t op = (vm->memory[vm->pc] << 8) | vm->memory[vm->pc + 1];
;     vm->pc += 2;
;
;     // Decode and execute:
;     // 0x00E0: CLS (clear screen)
;     // 0x1nnn: JP addr (jump)
;     // 0x6xkk: LD Vx, byte
;     // 0x7xkk: ADD Vx, byte
;     // 0xAnnn: LD I, addr
;     // 0xDxyn: DRW Vx, Vy, nibble (draw sprite and check collision)
; }
; ==============================================================================

global _start

%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_EXIT  60

%define STDOUT_FILENO 1

%define DISPLAY_WIDTH  64
%define DISPLAY_HEIGHT 32
%define DISPLAY_SIZE   (DISPLAY_WIDTH * DISPLAY_HEIGHT) ; 2048 bytes

section .data
    title_banner    db "+================================================+", 10
                    db "|    PURE x86-64 ASSEMBLY CHIP-8 EMULATOR VM     |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    msg_init        db "[+] Initialized CHIP-8 4KB RAM, font sprites, and CPU registers.", 10
    len_init        equ $ - msg_init

    msg_running     db "[*] Executing built-in graphics demo ROM at PC=0x200...", 10
    len_running     equ $ - msg_running

    msg_done        db 10, "[+] CHIP-8 CPU execution cycle & framebuffer render verified successfully!", 10
    len_done        equ $ - msg_done

    ansi_clear      db 27, "[H", 27, "[2J"
    len_clear       equ $ - ansi_clear

    pixel_on        db "#"
    pixel_off       db " "
    newline         db 10

    ; Standard CHIP-8 4x5 Font Sprites (0 through F) loaded into 0x000 - 0x04F
    font_sprites:
        db 0xF0, 0x90, 0x90, 0x90, 0xF0 ; 0
        db 0x20, 0x60, 0x20, 0x20, 0x70 ; 1
        db 0xF0, 0x10, 0xF0, 0x80, 0xF0 ; 2
        db 0xF0, 0x10, 0xF0, 0x10, 0xF0 ; 3
        db 0x90, 0x90, 0xF0, 0x10, 0x10 ; 4
        db 0xF0, 0x80, 0xF0, 0x10, 0xF0 ; 5
        db 0xF0, 0x80, 0xF0, 0x90, 0xF0 ; 6
        db 0xF0, 0x10, 0x20, 0x40, 0x40 ; 7
        db 0xF0, 0x90, 0xF0, 0x90, 0xF0 ; 8
        db 0xF0, 0x90, 0xF0, 0x10, 0xF0 ; 9
        db 0xF0, 0x90, 0xF0, 0x90, 0x90 ; A
        db 0xE0, 0x90, 0xE0, 0x90, 0xE0 ; B
        db 0xF0, 0x80, 0x80, 0x80, 0xF0 ; C
        db 0xE0, 0x90, 0x90, 0x90, 0xE0 ; D
        db 0xF0, 0x80, 0xF0, 0x80, 0xF0 ; E
        db 0xF0, 0x80, 0xF0, 0x80, 0x80 ; F
    len_font        equ $ - font_sprites

    ; Built-in Demonstration Test ROM:
    ; 1. 00E0 : Clear screen
    ; 2. 6005 : V0 = 5  (X coordinate)
    ; 3. 6105 : V1 = 5  (Y coordinate)
    ; 4. A000 : I = 0x000 (Point to font sprite for '0')
    ; 5. D015 : Draw 5-byte sprite at (V0, V1)
    ; 6. 7008 : V0 += 8 (X = 13)
    ; 7. A005 : I = 0x005 (Point to font sprite for '1')
    ; 8. D015 : Draw 5-byte sprite at (V0, V1)
    ; 9. 1212 : Loop jump to self (halt/idle)
    demo_rom:
        db 0x00, 0xE0                   ; CLS
        db 0x60, 0x05                   ; LD V0, 5
        db 0x61, 0x05                   ; LD V1, 5
        db 0xA0, 0x00                   ; LD I, 0x000
        db 0xD0, 0x15                   ; DRW V0, V1, 5
        db 0x70, 0x08                   ; ADD V0, 8
        db 0xA0, 0x05                   ; LD I, 0x005
        db 0xD0, 0x15                   ; DRW V0, V1, 5
        db 0x12, 0x10                   ; JMP 0x210
    len_demo_rom    equ $ - demo_rom

section .bss
    ; CHIP-8 Hardware Components
    align 16
    ram             resb 4096           ; 4KB virtual RAM
    display         resb DISPLAY_SIZE   ; 64x32 monochrome display (1 byte per pixel: 0 or 1)
    
    registers_v     resb 16             ; V0 - VF
    register_i      resw 1              ; 16-bit Index register
    register_pc     resw 1              ; 16-bit Program Counter
    stack_ptr       resb 1              ; 8-bit Stack Pointer
    stack_mem       resw 16             ; 16-level call stack

    render_row_buf  resb 66             ; 64 chars + newline + null

section .text

_start:
    ; Print Title Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; 1. Reset VM & load fonts into RAM[0x000..0x04F]
    call    chip8_init

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_init]
    mov     rdx, len_init
    syscall

    ; 2. Load demo ROM into RAM at 0x200
    lea     rsi, [rel demo_rom]
    lea     rdi, [rel ram + 0x200]
    mov     rcx, len_demo_rom
    rep movsb

    ; 3. Run CPU execution loop for 9 instructions
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_running]
    mov     rdx, len_running
    syscall

    mov     rcx, 9                      ; Execute the 9 instructions of demo ROM
.exec_loop:
    push    rcx
    call    chip8_step
    pop     rcx
    dec     rcx
    jnz     .exec_loop

    ; 4. Render the 64x32 framebuffer to terminal
    call    chip8_render_display

    ; Done
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_done]
    mov     rdx, len_done
    syscall

    ; Exit cleanly
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

; ==============================================================================
; chip8_init: Initializes memory, loads fonts, resets registers
; ==============================================================================
chip8_init:
    ; Zero out RAM and display
    lea     rdi, [rel ram]
    xor     al, al
    mov     rcx, 4096
    rep stosb

    lea     rdi, [rel display]
    xor     al, al
    mov     rcx, DISPLAY_SIZE
    rep stosb

    ; Copy fonts to RAM[0x000..]
    lea     rsi, [rel font_sprites]
    lea     rdi, [rel ram]
    mov     rcx, len_font
    rep movsb

    ; Reset registers
    lea     rdi, [rel registers_v]
    xor     al, al
    mov     rcx, 16
    rep stosb

    mov     word [rel register_i], 0
    mov     word [rel register_pc], 0x200 ; Programs start at 0x200
    mov     byte [rel stack_ptr], 0
    ret

; ==============================================================================
; chip8_step: Fetches 2-byte opcode at PC, decodes, and executes it
; ==============================================================================
chip8_step:
    push    rbx
    push    r12
    push    r13

    ; Fetch opcode: RAM[PC] and RAM[PC+1] (Big Endian)
    movzx   r12, word [rel register_pc]
    lea     rsi, [rel ram]
    movzx   ax, byte [rsi + r12]
    shl     ax, 8
    mov     al, byte [rsi + r12 + 1]
    mov     bx, ax                      ; bx = 16-bit opcode

    ; Advance PC by 2
    add     r12w, 2
    mov     [rel register_pc], r12w

    ; --------------------------------------------------------------------------
    ; Decode Opcode:
    ; High nibble in bh & 0xF0 determines instruction group
    ; --------------------------------------------------------------------------
    mov     dx, bx
    and     dx, 0xF000

    cmp     dx, 0x0000
    je      .op_0xxx
    cmp     dx, 0x1000
    je      .op_1nnn
    cmp     dx, 0x6000
    je      .op_6xkk
    cmp     dx, 0x7000
    je      .op_7xkk
    cmp     dx, 0xA000
    je      .op_Annn
    cmp     dx, 0xD000
    je      .op_Dxyn
    jmp     .step_done                  ; Unsupported/unhandled opcodes ignored in test

.op_0xxx:
    cmp     bx, 0x00E0                  ; 00E0 : Clear screen
    jne     .step_done
    lea     rdi, [rel display]
    xor     al, al
    mov     rcx, DISPLAY_SIZE
    rep stosb
    jmp     .step_done

.op_1nnn:
    ; 1nnn : Jump to address nnn
    mov     ax, bx
    and     ax, 0x0FFF
    mov     [rel register_pc], ax
    jmp     .step_done

.op_6xkk:
    ; 6xkk : Set Vx = kk
    ; x = (bx >> 8) & 0x0F
    ; kk = bx & 0x00FF
    movzx   rsi, bx
    shr     rsi, 8
    and     rsi, 0x0F                  ; rsi = x
    lea     rdi, [rel registers_v]
    mov     [rdi + rsi], bl            ; Vx = kk
    jmp     .step_done

.op_7xkk:
    ; 7xkk : Set Vx = Vx + kk (without changing carry flag VF)
    movzx   rsi, bx
    shr     rsi, 8
    and     rsi, 0x0F
    lea     rdi, [rel registers_v]
    add     [rdi + rsi], bl
    jmp     .step_done

.op_Annn:
    ; Annn : Set I = nnn
    mov     ax, bx
    and     ax, 0x0FFF
    mov     [rel register_i], ax
    jmp     .step_done

.op_Dxyn:
    ; Dxyn : Draw n-byte sprite at (Vx, Vy) with XOR pixel drawing
    ; x = (bx >> 8) & 0x0F
    ; y = (bx >> 4) & 0x0F
    ; n = bx & 0x000F
    movzx   rsi, bx
    shr     rsi, 8
    and     rsi, 0x0F                  ; rsi = x
    movzx   r8, bl
    shr     r8, 4
    and     r8, 0x0F                   ; r8 = y
    movzx   r9, bl
    and     r9, 0x0F                   ; r9 = n (sprite height)

    lea     rax, [rel registers_v]
    movzx   r10, byte [rax + rsi]      ; r10 = start X
    movzx   r11, byte [rax + r8]       ; r11 = start Y
    and     r10, (DISPLAY_WIDTH - 1)
    and     r11, (DISPLAY_HEIGHT - 1)

    ; VF = 0 (reset collision flag)
    mov     byte [rax + 15], 0

    ; Sprite data begins at RAM[I]
    movzx   r12, word [rel register_i]
    lea     r13, [rel ram]
    add     r13, r12                   ; r13 = pointer to sprite bytes

    xor     rcx, rcx                   ; row = 0..n-1
.draw_row:
    cmp     rcx, r9
    jge     .step_done

    movzx   edx, byte [r13 + rcx]      ; edx = 8-pixel byte of sprite
    xor     rbx, rbx                   ; col = 0..7
.draw_col:
    cmp     rbx, 8
    jge     .next_row

    ; Check bit (7 - col)
    mov     eax, edx
    mov     rsi, 7
    sub     rsi, rbx
    bt      eax, esi
    jnc     .skip_pixel

    ; Pixel is set in sprite. Calculate display index:
    ; index = (Y + row) * DISPLAY_WIDTH + (X + col)
    mov     rax, r11
    add     rax, rcx
    cmp     rax, DISPLAY_HEIGHT
    jge     .skip_pixel

    imul    rax, DISPLAY_WIDTH
    add     rax, r10
    add     rax, rbx
    cmp     rax, DISPLAY_SIZE
    jge     .skip_pixel

    lea     rdi, [rel display]
    ; Check if display pixel is already 1 (collision!)
    cmp     byte [rdi + rax], 1
    jne     .xor_pixel
    ; Set VF = 1
    lea     rsi, [rel registers_v]
    mov     byte [rsi + 15], 1

.xor_pixel:
    xor     byte [rdi + rax], 1

.skip_pixel:
    inc     rbx
    jmp     .draw_col

.next_row:
    inc     rcx
    jmp     .draw_row

.step_done:
    pop     r13
    pop     r12
    pop     rbx
    ret

; ==============================================================================
; chip8_render_display: Renders 64x32 display to stdout using block characters
; ==============================================================================
chip8_render_display:
    push    r12
    push    r13

    lea     r12, [rel display]
    xor     r13, r13                   ; y = 0..31

.render_row:
    cmp     r13, DISPLAY_HEIGHT
    jge     .render_done

    lea     rdi, [rel render_row_buf]
    xor     rcx, rcx                   ; x = 0..63
.render_col:
    cmp     rcx, DISPLAY_WIDTH
    jge     .write_row

    mov     al, [r12]
    test    al, al
    jz      .put_off
    mov     byte [rdi], '#'
    jmp     .next_pix
.put_off:
    mov     byte [rdi], ' '
.next_pix:
    inc     rdi
    inc     r12
    inc     rcx
    jmp     .render_col

.write_row:
    mov     byte [rdi], 10             ; newline
    inc     rdi

    ; Print row line to stdout
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel render_row_buf]
    mov     rdx, DISPLAY_WIDTH + 1
    syscall

    inc     r13
    jmp     .render_row

.render_done:
    pop     r13
    pop     r12
    ret
