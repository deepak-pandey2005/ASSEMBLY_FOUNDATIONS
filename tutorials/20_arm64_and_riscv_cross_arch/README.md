# Module 20: Cross-Architecture — x86-64 vs ARM64 (AArch64) & RISC-V

## 🎯 Objectives
- Understand the deep architectural differences between:
  - **CISC (Complex Instruction Set Computer)**: x86-64.
  - **RISC (Reduced Instruction Set Computer)**: ARM64 (AArch64) and RISC-V (RV64GC).
- Compare instruction encoding:
  - x86-64: Variable length (1 to 15 bytes per instruction).
  - ARM64: Strictly 32-bit (4 bytes) fixed instruction words.
  - RISC-V: Fixed 32-bit (with optional 16-bit compressed C extension).
- Learn register sets and calling conventions across architectures.
- Run multi-architecture cross-comparison side-by-side.

---

## 1. Register & Syscall Cross-Architecture Rosetta Stone

| Feature | x86-64 (AMD64) | ARM64 (AArch64) | RISC-V (RV64) |
|---|---|---|---|
| **Philosophy** | CISC | RISC (Load/Store) | Pure RISC |
| **Instruction Size** | Variable (1 - 15 bytes) | Fixed 4 bytes (32 bits) | 4 bytes (or 2-byte compressed) |
| **GPR Count** | 16 Registers (`rax`..`r15`) | 31 Registers (`x0`..`x30`) | 32 Registers (`x0`..`x31`) |
| **Zero Register** | None (use `xor reg, reg`) | `XZR` / `WZR` (hardware zero) | `x0` / `zero` (hardwired to 0) |
| **Syscall Instruction** | `syscall` | `svc #0` | `ecall` |
| **Syscall # Register**| `rax` | `x8` | `a7` |
| **1st Syscall Arg** | `rdi` | `x0` | `a0` |
| **2nd Syscall Arg** | `rsi` | `x1` | `a1` |
| **3rd Syscall Arg** | `rdx` | `x2` | `a2` |
| **Return Register** | `rax` | `x0` | `a0` |
| **Link Register** | Stack (`call`/`ret`) | `x30` / `LR` (`bl`/`ret`) | `x1` / `ra` (`jalr`) |

---

## 2. "Hello World" in All 3 Architectures Side-by-Side

### x86-64:
```nasm
mov rax, 1          ; sys_write
mov rdi, 1          ; stdout
mov rsi, msg
mov rdx, len
syscall
```

### ARM64 (AArch64):
```gas
mov x8, 64          ; sys_write (syscall 64 in ARM64 Linux)
mov x0, 1           ; stdout
ldr x1, =msg        ; pointer
mov x2, len         ; length
svc #0              ; Supervisor Call
```

### RISC-V (RV64):
```gas
li a7, 64           ; sys_write (syscall 64 in RISC-V Linux)
li a0, 1            ; stdout
la a1, msg          ; pointer
li a2, len          ; length
ecall               ; Environment Call
```

---

## 3. Hands-on Code Files in this Module
- [`cross_arch_comparison.md`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/cross_arch_comparison.md) - Deep dive guide with full assembly snippets and instruction encodings.
- [`arm64_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/arm64_sample.s) - GNU Assembler ARM64 sample.
- [`riscv_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/riscv_sample.s) - GNU Assembler RISC-V sample.
