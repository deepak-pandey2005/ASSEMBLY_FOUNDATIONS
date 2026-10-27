; ==============================================================================
; Program: bootloader.asm
; Description: 16-bit Real Mode MBR Boot Sector (Loads at 0x7C00)
; Architecture: x86 Bare-Metal (No OS, executes directly on CPU)
; Assembler: NASM (Raw Binary output: `nasm -f bin bootloader.asm -o bootloader.bin`)
;
; Test with QEMU:
;   qemu-system-x86_64 -drive format=raw,file=bootloader.bin
; ==============================================================================
;
; Equivalent Conceptual C Representation (Embedded Bare-Metal):
; ------------------------------------------------------------------------------
; // BIOS Video Interrupt 0x10 Teletype Service in freestanding C:
; static inline void bios_putchar(char c) {
;     __asm__ volatile (
;         "movb $0x0e, %%ah\n"
;         "movb %0, %%al\n"
;         "int $0x10\n"
;         :
;         : "r"(c)
;         : "ax"
;     );
; }
;
; void bios_print(const char *str) {
;     while (*str != '\0') {
;         bios_putchar(*str++);
;     }
; }
;
; void __attribute__((section(".text.entry"))) main(void) {
;     // Data segment registers DS, ES, SS = 0, Stack pointer SP = 0x7C00
;     bios_print("========================================\r\n"
;                " [!] Booted Assembly Foundations OS!    \r\n"
;                " Pure x86 Bare-Metal MBR Execution!     \r\n"
;                "========================================\r\n");
;     while (1) {
;         __asm__ volatile ("cli; hlt");
;     }
; }
; ==============================================================================

[org 0x7c00]                    ; Tell the assembler memory addresses start at 0x7C00
[bits 16]                       ; Emit 16-bit machine instructions

start:
    ; Initialize data segment registers to 0
    ; C equivalent: DS = ES = SS = 0; SP = 0x7C00;
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00              ; Setup stack growing downwards from 0x7C00

    ; Print boot message
    ; C equivalent: bios_print(boot_msg);
    mov si, boot_msg
    call print_string

hang:
    ; C equivalent: while (1) { __asm__ volatile ("cli; hlt"); }
    cli                         ; Clear interrupts (disable maskable interrupts)
    hlt                         ; Halt CPU until next interrupt
    jmp hang                    ; Infinite safety loop

; ------------------------------------------------------------------------------
; Routine: print_string
; Input: SI = pointer to null-terminated string
; Uses BIOS Interrupt 0x10, Service 0x0E (Teletype Output)
; C equivalent: void bios_print(const char *str)
; ------------------------------------------------------------------------------
print_string:
    pusha                       ; Save all 16-bit registers (AX, CX, DX, BX, SP, BP, SI, DI)
.loop:
    lodsb                       ; AL = *SI++;
    cmp al, 0                   ; if (al == '\0') break;
    je .done
    mov ah, 0x0e                ; BIOS teletype function 0x0E
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
times 510 - ($ - $$) db 0       ; Pad remainder of sector with zeroes
dw 0xaa55                       ; MBR Boot signature (Little Endian: 0x55, 0xAA)
