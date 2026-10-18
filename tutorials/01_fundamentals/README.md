# Module 01: Assembly & Machine Foundations

## 🎯 Objectives
- Understand how software translates to machine code.
- Master the CPU instruction cycle: **Fetch $\to$ Decode $\to$ Execute**.
- Understand memory hierarchy (Registers $\to$ L1/L2/L3 Cache $\to$ RAM).
- Understand byte ordering (**Little-Endian** vs **Big-Endian**).
- Assemble and link your first clean 64-bit Linux program.

---

## 1. What Really Happens When Code Runs?

Computers do not understand C, Python, or even Assembly. They understand **machine code**—streams of binary bytes (e.g., `48 c7 c0 3c 00 00 00 0f 05`).

Assembly language is a human-readable 1-to-1 representation of these machine instructions:
```text
C / High Level Code  -->  [Compiler: gcc -S]
           ↓
Assembly Code (.asm) -->  [Assembler: nasm / as]
           ↓
Object File (.o)     -->  [Linker: ld]
           ↓
ELF Executable       -->  [Kernel: execve] --> Memory & CPU Execution
```

---

## 2. Memory Organization & Endianness

x86 and x86-64 are **Little-Endian** architectures. The least significant byte (LSB) is stored at the lowest memory address.

For a 32-bit hex number `0x12345678`:
```text
Address:    [ 0x00 ]   [ 0x01 ]   [ 0x02 ]   [ 0x03 ]
Value:        0x78       0x56       0x34       0x12
              (LSB)                            (MSB)
```

In Big-Endian (common in network protocols):
```text
Address:    [ 0x00 ]   [ 0x01 ]   [ 0x02 ]   [ 0x03 ]
Value:        0x12       0x34       0x56       0x78
```

---

## 3. The Minimal 64-bit Assembly Program

Here is how an executable starts and cleanly exits on 64-bit Linux using the kernel `syscall` instruction:

```nasm
; file: minimal_exit.asm
section .text
global _start

_start:
    ; sys_exit(42)
    mov rax, 60         ; syscall number for sys_exit in 64-bit Linux
    mov rdi, 42         ; exit status code to return to the OS
    syscall             ; transfer execution to the kernel
```

### Compiling and Running:
```bash
nasm -f elf64 -g -F dwarf minimal_exit.asm -o minimal_exit.o
ld minimal_exit.o -o minimal_exit
./minimal_exit
echo $?                 # prints: 42
```

---

## 4. Hands-on Code Files in this Module
- [`hello_64.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/hello_64.asm) - Standard Linux x86_64 "Hello, World!" with deep comments explaining every line.
- [`minimal_exit.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/minimal_exit.asm) - The smallest functional ELF executable.
