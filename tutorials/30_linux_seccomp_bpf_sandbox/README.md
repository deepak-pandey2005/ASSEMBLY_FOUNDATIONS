# Module 30: Linux Seccomp & BPF Syscall Sandboxing

## 🎯 Objectives
- Understand modern Linux process sandboxing and kernel isolation:
  - Why standard user-space privilege boundaries are not enough to prevent exploitation.
  - How browsers (Chromium), container runtimes (Docker, runc), and system daemons (systemd) lock down untrusted processes using **Seccomp** (Secure Computing Mode).
- Master classic **Seccomp Mode 1** (`SECCOMP_SET_MODE_STRICT`):
  - Only allows 4 syscalls: `read` (0), `write` (1), `exit` (60), `sigreturn` (15).
  - Any attempt to invoke other syscalls (like `open`, `fork`, `execve`, `socket`) triggers instant kernel termination with `SIGKILL`!
- Understand **Seccomp-BPF** (`SECCOMP_SET_MODE_FILTER`):
  - In-kernel virtual machine bytecode running the classic **Berkeley Packet Filter (cBPF)**.
  - Inspects `struct seccomp_data` (syscall number, architecture, instruction pointer, and 6 64-bit arguments).
  - Return actions: `SECCOMP_RET_ALLOW`, `SECCOMP_RET_KILL_PROCESS`, `SECCOMP_RET_TRAP`, `SECCOMP_RET_ERRNO`.
- Master `sys_prctl` (syscall 157) with `PR_SET_NO_NEW_PRIVS` (mandatory before loading unprivileged seccomp filters).
- Build a locked-down sandbox in pure x86-64 assembly that executes safe operations and gets terminated if it attempts unauthorized filesystem access!

---

## 1. What is Seccomp?

When a process is compromised (e.g. via buffer overflow or RCE), the attacker's shellcode tries to invoke system calls like `execve("/bin/sh")` or `connect()` to establish a reverse shell.

With **Seccomp**, a process voluntarily gives up the ability to call dangerous syscalls:
```text
User Application
       ↓
  [ prctl(PR_SET_NO_NEW_PRIVS) ]  --> Guarantees child processes cannot gain privileges (e.g. setuid)
       ↓
  [ seccomp(SECCOMP_SET_MODE_STRICT) ] or BPF Filter
       ↓
Process Sandboxed:
  ├─ sys_write() ---> ALLOWED (Kernel executes write)
  ├─ sys_read()  ---> ALLOWED (Kernel executes read)
  └─ sys_open()  ---> BLOCKED! (Kernel instantly issues SIGKILL or SIGSYS)
```

---

## 2. Seccomp Strict Mode vs Filter Mode

### 1. Strict Mode (`SECCOMP_SET_MODE_STRICT = 0`)
- Syscall: `prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT)` or `seccomp(SECCOMP_SET_MODE_STRICT, 0, NULL)`
- Permitted syscalls:
  - `sys_read` (0)
  - `sys_write` (1)
  - `sys_exit` (60)
  - `sys_rt_sigreturn` (15)
- All other 300+ Linux system calls are forbidden!

### 2. Filter Mode (`SECCOMP_SET_MODE_FILTER = 1`)
- Loads an array of `struct sock_filter` (8 bytes each: `code`, `jt`, `jf`, `k`).
- The kernel runs this BPF program on every single system call invocation at runtime.

---

## 3. Hands-on Code Files in this Module
- [`seccomp_sandbox.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/30_linux_seccomp_bpf_sandbox/seccomp_sandbox.asm) - Demonstrates locking the process down into strict seccomp mode, verifying allowed writes, and testing unauthorized syscall blocking.
