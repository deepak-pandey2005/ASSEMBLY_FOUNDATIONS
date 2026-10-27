# Standalone Project 12: Pure Assembly Brainfuck JIT Compiler (`asm_bfjit`)

A high-performance Just-In-Time (JIT) compiler written in pure x86-64 NASM assembly with **zero external libraries or C runtime (`libc`) dependencies**. It dynamically compiles Brainfuck source code directly into native x86-64 machine instructions in executable RAM, applies compiler peephole optimizations, and executes the emitted machine code at native processor speed.

---

## 🎯 Architecture & Compilation Pipeline

### 1. The JIT Execution Pipeline

```text
  +-------------------------+
  |  Brainfuck Source Code  |  ("++++++++[>++++...]")
  +-------------------------+
               |
               v
  +-------------------------+
  |    Optimization Pass    |  - Run-length coalescing for arithmetic (+ and -)
  |                         |  - Run-length coalescing for tape movement (> and <)
  |                         |  - Peephole idiom replacement: "[-]" -> mov byte [r12], 0
  +-------------------------+
               |
               v
  +-------------------------+
  |  Machine Code Generator |  - Two-pass relative jump resolution for [ and ]
  |                         |  - Inlines direct sys_write and sys_read for . and ,
  |                         |  - Writes raw opcodes into executable memory page
  +-------------------------+
               |
               v
  +-------------------------+
  |  mmap RWX Memory Page   |  Allocated via sys_mmap (PROT_READ|WRITE|EXEC)
  +-------------------------+
               |
               v
  +-------------------------+
  | Native CPU Execution    |  Function call `call rax` executes machine code
  +-------------------------+
```

---

## 2. Opcode Emission & Optimization Table

| Brainfuck Token | Compiler Strategy | Emitted Native x86-64 Instruction | Hex Opcode Sequence |
|---|---|---|---|
| Prologue | Entry sequence | `push r12; push r13; mov r12, rdi` | `41 54 41 55 49 89 fc` |
| `+` (run of $N$) | Coalesced Add | `add byte [r12], N` | `41 80 04 24 <N>` |
| `-` (run of $N$) | Coalesced Sub | `sub byte [r12], N` | `41 80 2c 24 <N>` |
| `>` (run of $N$) | Coalesced Tape Forward | `add r12, N` | `49 81 c4 <N:4>` |
| `<` (run of $N$) | Coalesced Tape Backward | `sub r12, N` | `49 81 ec <N:4>` |
| `[-]` | Zero Cell Peephole | `mov byte [r12], 0` | `41 c6 04 24 00` |
| `.` | Inline Output Syscall | `mov eax, 1; mov edi, 1; mov rsi, r12; mov edx, 1; syscall` | `b8 01 00 00 00 bf 01 00 00 00 4c 89 e6 ba 01 00 00 00 0f 05` |
| `,` | Inline Input Syscall | `xor eax, eax; xor edi, edi; mov rsi, r12; mov edx, 1; syscall` | `31 c0 31 ff 4c 89 e6 ba 01 00 00 00 0f 05` |
| `[` | Forward Conditional Jump | `cmp byte [r12], 0; jz <rel32>` | `41 80 3c 24 00 0f 84 <disp32>` |
| `]` | Backward Conditional Jump | `cmp byte [r12], 0; jnz <rel32>` | `41 80 3c 24 00 0f 85 <disp32>` |
| Epilogue | Exit sequence | `pop r13; pop r12; ret` | `41 5d 41 5c c3` |

---

## 3. High-Precision Hardware Telemetry via RDTSC

Every JIT invocation measures and outputs real-time hardware CPU cycle telemetry using the `rdtsc` / `lfence` machine instructions:
* **JIT Compilation Cost**: Exact processor cycles spent parsing, optimizing, and emitting machine code.
* **Native Execution Cost**: Exact processor cycles spent running the compiled native machine instructions.
* **Emitted Byte Count**: Exact size of the compiled native executable payload.

---

## 4. CLI Usage & Commands

```bash
# Compile and run a Brainfuck file
./asm_bfjit program.bf

# Compile and run inline Brainfuck code directly from CLI
./asm_bfjit -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++."

# Run without arguments to trigger built-in Hello World benchmark
./asm_bfjit

# Run automated test suite
make test
```
