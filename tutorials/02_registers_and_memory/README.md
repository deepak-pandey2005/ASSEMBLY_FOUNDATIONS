# Module 02: Registers, Memory Layout, and Addressing Modes

## 🎯 Objectives
- Understand General Purpose Registers (GPRs) and their bit breakdown (8-bit, 16-bit, 32-bit, 64-bit).
- Master ELF Sections: `.text` (executable code), `.data` (initialized data), `.rodata` (constants), `.bss` (uninitialized memory).
- Master the Complex x86 Memory Addressing Equation:
  $$\text{Address} = \text{Base} + (\text{Index} \times \text{Scale}) + \text{Displacement}$$

---

## 1. The General Purpose Register Hierarchy

In x86-64, we have 16 general-purpose 64-bit registers: `rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi`, `rbp`, `rsp`, and `r8` through `r15`.

Each register can be addressed in portions for backwards compatibility:

```text
| 64-bit: RAX                                                           |
|                       | 32-bit: EAX                                   |
|                       |                       | 16-bit: AX            |
|                       |                       | 8-bit: AH | 8-bit: AL |
[63...................32|31...................16|15........8|7.........0]
```

> [!IMPORTANT]
> **Zero-Extension Gotcha**:
> Writing to a 32-bit register (like `mov eax, 5`) automatically clears/zeros out the upper 32 bits of `rax`!
> Writing to an 8-bit or 16-bit sub-register (`mov al, 5` or `mov ax, 5`) leaves the upper bits completely untouched.

---

## 2. Memory Sections Breakdown

```nasm
section .rodata
    ; Read-only data: string constants, lookup tables (segfaults if written to)
    prompt db "Enter value: ", 0

section .data
    ; Initialized read/write data: values take actual space inside the ELF file
    count   dd 42            ; dd = doubleword (4 bytes, 32-bit)
    scores  dq 100, 200, 300 ; dq = quadword (8 bytes each, 64-bit)

section .bss
    ; Uninitialized read/write data: takes NO disk space in the binary file.
    ; Memory is allocated and zeroed by the OS kernel at runtime.
    buffer  resb 1024        ; reserve 1024 bytes (resb)
    temp    resq 1           ; reserve 1 quadword (8 bytes)

section .text
    ; Machine instructions (marked RX - Read + Execute)
global _start
_start:
    ; ...
```

---

## 3. Addressing Modes Equation

In x86, you can calculate effective memory addresses on the fly inside brackets `[...]`:

$$\text{Effective Address} = \text{Base Reg} + (\text{Index Reg} \times \text{Scale}) \pm \text{Disp}$$

Where:
- **Base Reg**: Any 64-bit general register (`rax`, `rbx`, `rsi`, etc.)
- **Index Reg**: Any register except `rsp`
- **Scale**: Allowed factors: `1`, `2`, `4`, `8` (ideal for indexing byte, word, dword, qword arrays!)
- **Disp**: Immediate constant offset (positive or negative)

### Addressing Modes Examples:
```nasm
mov rax, [rbx]                  ; Register indirect: value at memory address in rbx
mov rax, [rbx + 16]             ; Base + displacement: struct member offset
mov rax, [rbx + rcx]            ; Base + index
mov rax, [rbx + rcx*4]          ; Base + index * scale (4-byte array indexing)
mov rax, [rbx + rcx*8 + 32]     ; Base + index * scale + disp (complex struct array)
lea rax, [rbx + rcx*8 + 32]     ; LEA computes the address itself WITHOUT dereferencing!
```

---

## 4. Hands-on Code Files in this Module
- [`addressing_modes.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/addressing_modes.asm) - Demonstrates every addressing mode with GDB watchpoints.
- [`data_sections.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/data_sections.asm) - Working with `.data`, `.bss`, and `.rodata`.
