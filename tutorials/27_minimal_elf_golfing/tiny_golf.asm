; ==============================================================================
; Program: tiny_golf.asm
; Description: Handcrafted minimal 64-bit Linux ELF executable (~127 bytes)
; Architecture: x86-64 Linux
; Assembler: NASM (Raw Binary output: `nasm -f bin tiny_golf.asm -o tiny_golf`)
;
; ==============================================================================
; Equivalent C Representation:
; ------------------------------------------------------------------------------
; #include <unistd.h>
;
; int main(void) {
;     _exit(42);
; }
;
; // Note: In C with glibc, the resulting linked executable is typically ~16,000 bytes.
; // In raw handcrafted NASM binary mode, we manually pack the 64-byte ELF header
; // and 56-byte Program Header directly with 7 bytes of machine instructions,
; // producing a fully compliant 127-byte executable that returns code 42!
; ==============================================================================

BITS 64
org 0x400000

; ------------------------------------------------------------------------------
; 1. ELF-64 HEADER (Elf64_Ehdr - 64 bytes)
; ------------------------------------------------------------------------------
ehdr:
    db 0x7F, "ELF"                      ; e_ident[EI_MAG0..3]
    db 2                                ; EI_CLASS: 2 = 64-bit
    db 1                                ; EI_DATA: 1 = Little-endian
    db 1                                ; EI_VERSION: 1
    db 0                                ; EI_OSABI: 0 = System V
    dq 0                                ; EI_PAD (8 bytes)

    dw 2                                ; e_type: ET_EXEC (Executable)
    dw 0x3E                             ; e_machine: x86-64 (EM_X86_64 = 62 / 0x3E)
    dd 1                                ; e_version: 1
    dq _start                           ; e_entry: Entry point virtual address
    dq phdr - $$                        ; e_phoff: Program header table offset
    dq 0                                ; e_shoff: Section header table offset (none!)
    dd 0                                ; e_flags: 0
    dw 64                               ; e_ehsize: ELF header size (64 bytes)
    dw 56                               ; e_phentsize: Program header entry size (56 bytes)
    dw 1                                ; e_phnum: Number of program headers (1)
    dw 0                                ; e_shentsize: Section header size
    dw 0                                ; e_shnum: 0
    dw 0                                ; e_shstrndx: 0

; ------------------------------------------------------------------------------
; 2. PROGRAM HEADER (Elf64_Phdr - 56 bytes)
; ------------------------------------------------------------------------------
phdr:
    dd 1                                ; p_type: PT_LOAD (Loadable segment)
    dd 7                                ; p_flags: PF_R | PF_W | PF_X (Read, Write, Execute)
    dq 0                                ; p_offset: File offset 0
    dq 0x400000                         ; p_vaddr: Virtual address in RAM
    dq 0x400000                         ; p_paddr: Physical address
    dq file_end - $$                    ; p_filesz: Size in file
    dq file_end - $$                    ; p_memsz: Size in memory
    dq 0x1000                           ; p_align: 4096 bytes alignment

; ------------------------------------------------------------------------------
; 3. EXECUTABLE MACHINE CODE
; C equivalent: _exit(42);
; ------------------------------------------------------------------------------
_start:
    ; sys_exit(42)
    mov al, 60                          ; sys_exit (RAX = 60, concise 8-bit mov)
    mov dil, 42                         ; return code = 42
    syscall

file_end:
