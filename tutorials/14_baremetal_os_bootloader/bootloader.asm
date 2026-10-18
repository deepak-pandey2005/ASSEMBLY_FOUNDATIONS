; ==============================================================================
; Program: bootloader.asm
; Description: 16-bit Real Mode MBR Boot Sector (Loads at 0x7C00)
; Architecture: x86 Bare-Metal (No OS, executes directly on CPU)
; Assembler: NASM (Raw Binary output: `nasm -f bin bootloader.asm -o bootloader.bin`)
;
; Test with QEMU:
;   qemu-system-x86_64 -drive format=raw,file=bootloader.bin
; ==============================================================================

[org 0x7c00]                    ; Tell the assembler memory addresses start at 0x7C00
[bits 16]                       ; Emit 16-bit machine instructions

start:
    ; Initialize data segment registers to 0
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00              ; Setup stack growing downwards from 0x7C00

    ; Print boot message
    mov si, boot_msg
    call print_string

hang:
    cli                         ; Clear interrupts
    hlt                         ; Halt CPU until next interrupt
    jmp hang                    ; Infinite safety loop

; ------------------------------------------------------------------------------
; Routine: print_string
; Input: SI = pointer to null-terminated string
; Uses BIOS Interrupt 0x10, Service 0x0E (Teletype Output)
; ------------------------------------------------------------------------------
print_string:
    pusha                       ; Save all 16-bit registers
.loop:
    lodsb                       ; AL = [SI], SI = SI + 1
    cmp al, 0                   ; Null terminator reached?
    je .done
    mov ah, 0x0e                ; BIOS teletype function
    int 0x10                    ; Trigger video interrupt
    jmp .loop
.done:
    popa                        ; Restore registers
    ret

; ------------------------------------------------------------------------------
; Data Strings
; ------------------------------------------------------------------------------
boot_msg:
    db "========================================", 13, 10
    db " [!] Booted Assembly Foundations OS!    ", 13, 10
    db " Pure x86 Bare-Metal MBR Execution!     ", 13, 10
    db "========================================", 13, 10, 0

; ------------------------------------------------------------------------------
; Boot Sector Signature Padding
; A valid boot sector must be exactly 512 bytes, ending in 0xAA55
; ------------------------------------------------------------------------------
times 510 - ($ - $$) db 0       ; Pad remaining bytes with zeroes
dw 0xaa55                       ; Magic BIOS boot signature (0x55, 0xAA in memory)
