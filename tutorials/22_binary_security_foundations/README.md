# Module 22: Binary Security Foundations — Shellcoding & Anti-Debugging

## 🎯 Objectives
- Understand binary vulnerability research and security primitives from the instruction level:
  - What is **Shellcode**? Position-Independent Code (PIC) executing without symbol tables or fixed memory addresses.
  - The "Null Byte" (`\x00`) challenge: Why raw byte `0x00` terminates C strings (`strcpy`) and how to craft null-free assembly.
  - Linux `sys_execve` (syscall 59) argument structure.
- Understand Anti-Debugging Techniques:
  - Detecting attached debuggers via `sys_ptrace` (`PTRACE_TRACEME = 0`).
  - High-precision CPU cycle counting with `RDTSC` (Read Time-Stamp Counter) to detect breakpoint pauses.
- Write a clean, self-contained shellcode verification testbed.

---

## 1. What Makes Assembly "Shellcode"?

Standard compiled binaries have:
- Fixed memory sections (`.data`, `.rodata`).
- Absolute relocation addresses determined at link time.

In exploit development (e.g. stack buffer overflow), injected machine code must be **Position-Independent Code (PIC)**:
1. Cannot reference global symbols or `.data` sections with hardcoded addresses.
2. Must find its own data relative to `RIP` or push strings directly onto the stack at runtime.
3. Must avoid null bytes (`\x00`) if payload travels through string functions.

### Spawning `/bin/sh` via `sys_execve` (Syscall 59):
- `RAX` = 59 (`sys_execve`)
- `RDI` = Pointer to string `"/bin//sh"` (8 bytes)
- `RSI` = Pointer to `argv` array (`[pointer to "/bin//sh", NULL]`)
- `RDX` = Pointer to `envp` array (`NULL`)

---

## 2. Anti-Debugging with `ptrace`

In Linux, a process can only have **one** debugger attached at a time.
A program can query if it is being debugged by calling:
```nasm
mov rax, 101        ; sys_ptrace
xor rdi, rdi        ; PTRACE_TRACEME (0)
xor rsi, rsi
xor rdx, rdx
xor r10, r10
syscall
cmp rax, 0
jl debugger_detected
```

---

## 3. Hands-on Code Files in this Module
- [`shellcode_demo.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/22_binary_security_foundations/shellcode_demo.asm) - Self-contained position-independent shellcode harness and anti-debugging test.
