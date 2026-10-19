; ==============================================================================
; Project: raytrace.asm
; Description: 3D Sphere Raytracer with directional diffuse lighting in pure assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    filename: db "render.ppm", 0

    WIDTH     equ 320
    HEIGHT    equ 320
    TOTAL_PX  equ WIDTH * HEIGHT
    TOTAL_RGB equ TOTAL_PX * 3

    ppm_header:
        db "P6", 10
        db "320 320", 10
        db "255", 10
    len_header equ $ - ppm_header

    msg_done: db "[+] 3D Sphere Raytracer rendered 320x320 image to render.ppm!", 10
    len_done: equ $ - msg_done

    ; Sphere parameters (fixed point scale 1000)
    ; Center: (0, 0, 3000), Radius = 1200 -> Radius^2 = 1,440,000
    SPHERE_Z equ 3000
    RADIUS_SQ equ 1440000

    ; Directional Light Vector (normalized approx: L_x = 577, L_y = 577, L_z = -577)
    LIGHT_X equ 577
    LIGHT_Y equ 577
    LIGHT_Z equ -577

section .bss
    fd:        resq 1
    image_buf: resb TOTAL_RGB

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. RAYTRACING LOOP OVER ALL PIXELS (X in -160..159, Y in -160..159)
    ; Ray origin O = (0, 0, 0)
    ; Ray direction D = (X * 6, Y * 6, 1000)
    ; --------------------------------------------------------------------------
    lea rdi, [image_buf]
    mov r12, -160                       ; Y loop (-160 to +159)

.y_loop:
    cmp r12, 160
    jge .done_render

    mov r13, -160                       ; X loop (-160 to +159)

.x_loop:
    cmp r13, 160
    jge .next_y

    ; Ray direction D:
    ; dx = r13 * 6, dy = -r12 * 6 (flip Y for standard screen coordinates)
    mov rax, r13
    imul rax, 6
    mov r8, rax                         ; r8 = dx

    mov rax, r12
    neg rax
    imul rax, 6
    mov r9, rax                         ; r9 = dy

    mov r10, 1000                       ; r10 = dz

    ; Check if ray intersects sphere:
    ; Ray: P(t) = (dx*t, dy*t, dz*t) / 1000
    ; At t ≈ SPHERE_Z / dz = 3000 / 1000 = 3:
    ; P_x = dx * 3, P_y = dy * 3
    ; Distance squared from sphere center (0, 0): dist_sq = P_x^2 + P_y^2
    mov rax, r8
    imul rax, 3
    imul rax, rax
    mov r14, rax                        ; r14 = P_x^2

    mov rax, r9
    imul rax, 3
    imul rax, rax
    add r14, rax                        ; r14 = P_x^2 + P_y^2

    ; If dist_sq > RADIUS_SQ, ray misses sphere -> Background color (Dark Slate)
    cmp r14, RADIUS_SQ
    jg .background

    ; HIT! Compute diffuse shading
    ; Normal vector at hit point approx:
    ; N_x = P_x = r8 * 3
    ; N_y = P_y = r9 * 3
    ; N_z = -sqrt(RADIUS_SQ - dist_sq)
    ; Dot product with light (LIGHT_X, LIGHT_Y, LIGHT_Z):
    ; diffuse = (N_x * LIGHT_X + N_y * LIGHT_Y + N_z * LIGHT_Z)
    mov rax, r8
    imul rax, 3
    imul rax, LIGHT_X
    mov r15, rax

    mov rax, r9
    imul rax, 3
    imul rax, LIGHT_Y
    add r15, rax

    ; Normalize intensity to 0..255
    sar r15, 22                         ; scale down
    add r15, 60                         ; ambient light base
    cmp r15, 0
    jge .check_max
    xor r15, r15
.check_max:
    cmp r15, 255
    jle .store_color
    mov r15, 255

.store_color:
    ; Cyan-tinted shaded sphere: Red = intensity/2, Green = intensity, Blue = intensity
    mov rax, r15
    shr rax, 1
    mov [rdi], al                       ; Red
    mov [rdi + 1], r15b                 ; Green
    mov [rdi + 2], r15b                 ; Blue
    add rdi, 3
    jmp .next_x

.background:
    ; Background pixel: Navy Blue (R=15, G=22, B=36)
    mov byte [rdi], 15
    mov byte [rdi + 1], 22
    mov byte [rdi + 2], 36
    add rdi, 3

.next_x:
    inc r13
    jmp .x_loop

.next_y:
    inc r12
    jmp .y_loop

.done_render:
    ; --------------------------------------------------------------------------
    ; 2. WRITE RENDERED IMAGE: sys_open("render.ppm", O_CREAT|O_WRONLY|O_TRUNC, 0644)
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; sys_open
    lea rdi, [filename]
    mov rsi, 577                        ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 420                        ; 0644
    syscall

    cmp rax, 0
    jl .error
    mov [fd], rax

    ; Write Header
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [ppm_header]
    mov rdx, len_header
    syscall

    ; Write Pixel Buffer
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [image_buf]
    mov rdx, TOTAL_RGB
    syscall

    ; Close File
    mov rax, 3                          ; sys_close
    mov rdi, [fd]
    syscall

    ; Print Done
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
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
