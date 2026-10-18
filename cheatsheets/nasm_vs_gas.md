# NASM vs GAS (Intel vs AT&T) Syntax Rosetta Stone

| Concept | NASM / Intel Syntax | GAS / AT&T Syntax |
|---|---|---|
| **Operand Order** | `OPCODE destination, source` | `OPCODE source, destination` |
| **Immediate Values** | `mov eax, 10` | `movl $10, %eax` |
| **Register Prefix** | None (`rax`, `ebx`) | `%` prefix (`%rax`, `%ebx`) |
| **Hex Constants** | `0x10` or `10h` | `0x10` or `$0x10` |
| **Memory Dereference** | `[rax]` | `(%rax)` |
| **Offset / Displacement** | `[rax + 8]` | `8(%rax)` |
| **Scaled Indexed Addressing** | `[rbx + rcx*4 + 16]` | `16(%rbx, %rcx, 4)` |
| **Scale Factors** | `*1`, `*2`, `*4`, `*8` | `1`, `2`, `4`, `8` |
| **Operand Size Suffixes** | Explicit keywords (`byte`, `word`, `dword`, `qword`) | Instruction mnemonic suffix (`b`, `w`, `l`, `q`) |
| **String Literal** | `msg: db "Hello", 10` | `msg: .ascii "Hello\n"` |
| **Section Declaration** | `section .text` | `.section .text` |
| **Global Export** | `global _start` | `.globl _start` |
| **Syscall Instruction** | `syscall` | `syscall` |
| **Legacy 32-bit Syscall** | `int 80h` or `int 0x80` | `int $0x80` |

---

## Direct Code Translation Examples

### 1. Simple Data Transfer
```nasm
; NASM (Intel)
mov eax, 42
mov [buffer], eax
mov rbx, [rsi + 16]
```
```gas
/* GAS (AT&T) */
movl $42, %eax
movl %eax, buffer
movq 16(%rsi), %rbx
```

### 2. Scaled Array Access
```nasm
; NASM (Intel)
mov rax, [rbx + rcx*8 + 32]
```
```gas
/* GAS (AT&T) */
movq 32(%rbx, %rcx, 8), %rax
```

### 3. Subtraction & Comparison
Notice that in AT&T syntax, the order inversion affects `sub` and `cmp`:
```nasm
; NASM (Intel)
cmp rax, 10      ; Computes (rax - 10)
jge .is_ge       ; Jumps if rax >= 10
```
```gas
/* GAS (AT&T) */
cmpq $10, %rax   ; Computes (%rax - $10)
jge .is_ge       ; Jumps if %rax >= 10
```
