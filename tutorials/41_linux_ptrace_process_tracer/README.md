# Module 41: Linux Process Tracing & Syscall Interception (`sys_ptrace`)

## 🎯 Objectives
- Master the internal architecture of Linux debuggers, profilers, and tracers (`gdb`, `strace`, `ltrace`, `rr`):
  - Understand how the kernel gives one process (tracer) complete inspection and execution control over another process (tracee).
  - Understand the process control state machine: process stop, register inspection, hardware single-stepping, syscall traps, and signal injection.
- Master `sys_ptrace` (syscall 101) Requests & Control Semantics:
  - `PTRACE_TRACEME` (0): Child authorizes its parent to trace and intercept its execution.
  - `PTRACE_GETREGS` (12): Copies all 27 general-purpose 64-bit hardware registers (`struct user_regs_struct`, 216 bytes) into tracer memory.
  - `PTRACE_SINGLESTEP` (9): Executes exactly one CPU machine instruction in the child, raising a hardware debug trap (`SIGTRAP`) upon completion.
  - `PTRACE_SYSCALL` (24): Resumes child execution until the next system call boundary (entry or exit), recording the syscall number in `orig_rax`.
  - `PTRACE_CONT` (7): Resumes child process execution to completion.
- Dissect the 64-bit `struct user_regs_struct` Architecture:
  - 216 bytes across 27 64-bit registers:
    - Instruction pointer: `rip` (offset 128)
    - Stack pointer: `rsp` (offset 152)
    - Syscall accumulator & return value: `rax` (offset 80)
    - Original syscall number at entry: `orig_rax` (offset 120)
    - Syscall ABI arguments: `rdi` (112), `rsi` (104), `rdx` (96), `r10` (56), `r8` (72), `r9` (64)
- Pure x86-64 assembly, zero external C runtime (`libc`) dependencies: 100% Linux system calls.

---

## 1. Process Tracing Lifecycle & State Machine

```text
       TRACER (Parent Debugger)                     TRACEE (Child Worker)
   +------------------------------+             +--------------------------+
   |   sys_fork() spawns child    | ----------> | sys_ptrace(PTRACE_TRACEME)|
   |                              |             | sys_kill(self, SIGSTOP)  |
   |   sys_wait4() intercepts     | <---------- | Child transitions to     |
   |   stopped child              |             | TASK_STOPPED state       |
   +------------------------------+             +--------------------------+
                  |
                  v
   +------------------------------+
   | sys_ptrace(PTRACE_GETREGS)   |  Reads 216-byte user_regs_struct:
   |                              |  -> RIP: 0x4013AB
   |                              |  -> RSP: 0x7FFF40675010
   +------------------------------+
                  |
                  v
   +------------------------------+
   | sys_ptrace(PTRACE_SINGLESTEP)| ----------> Executes exactly 1 instruction
   | sys_wait4() catches SIGTRAP  | <---------- Child stops immediately after
   | sys_ptrace(PTRACE_GETREGS)   |             Advanced RIP: 0x4013B5!
   +------------------------------+
                  |
                  v
   +------------------------------+
   | sys_ptrace(PTRACE_SYSCALL)   | ----------> Resumes until syscall entry
   | sys_wait4() catches trap     | <---------- Stops at sys_write
   | user_regs.orig_rax == 1      |             Syscall Number: 1 (SYS_WRITE)
   +------------------------------+
                  |
                  v
   +------------------------------+
   | sys_ptrace(PTRACE_CONT)      | ----------> Resumes child to termination
   | sys_wait4() reaps exit code  | <---------- Exits with status 42!
   +------------------------------+
```

---

## 2. Linux x86-64 `user_regs_struct` Register Memory Map

| Byte Offset | Register Field | Description |
|---|---|---|
| `0` | `r15` | Callee-saved general-purpose register |
| `8` | `r14` | Callee-saved general-purpose register |
| `16` | `r13` | Callee-saved general-purpose register |
| `24` | `r12` | Callee-saved general-purpose register |
| `32` | `rbp` | Base pointer register |
| `40` | `rbx` | Callee-saved general-purpose register |
| `48` | `r11` | Scratch / RFLAGS saved by syscall |
| `56` | `r10` | 4th syscall argument register |
| `64` | `r9` | 6th syscall argument register |
| `72` | `r8` | 5th syscall argument register |
| `80` | `rax` | Syscall return value / accumulator |
| `88` | `rcx` | User RIP saved by syscall instruction |
| `96` | `rdx` | 3rd syscall argument register |
| `104` | `rsi` | 2nd syscall argument register |
| `112` | `rdi` | 1st syscall argument register |
| `120` | `orig_rax` | **System call number** requested at entry |
| `128` | `rip` | **Instruction pointer** (next machine instruction) |
| `136` | `cs` | Code segment selector |
| `144` | `eflags` | Processor status flags (RFLAGS) |
| `152` | `rsp` | **Stack pointer** |
| `160` | `ss` | Stack segment selector |
| `168` - `208` | `fs_base`, `gs_base`, etc. | Segment bases and segment selectors |

---

## 3. Hands-on Code Files in this Module
- [`ptrace_tracer.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/41_linux_ptrace_process_tracer/ptrace_tracer.asm) - Pure x86-64 assembly implementation of process tracing, register inspection, hardware single-stepping, and system call interception with zero external dependencies.
