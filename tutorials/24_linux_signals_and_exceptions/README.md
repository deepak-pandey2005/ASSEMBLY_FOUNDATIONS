# Module 24: Linux Signals & Low-Level Exception Trapping

## 🎯 Objectives
- Understand how the Linux kernel delivers asynchronous software interrupts (**Signals**).
- Learn the difference between synchronous exceptions (e.g. `SIGFPE` divide-by-zero, `SIGSEGV` bad memory access) and asynchronous events (e.g. `SIGINT` Ctrl+C, `SIGTERM`).
- Master the `sys_rt_sigaction` (syscall 13) system call to register custom signal handlers in pure assembly.
- Learn the mandatory kernel stack frame restorer: `sys_rt_sigreturn` (syscall 15).

---

## 1. What Happens When a Signal Fires?

1. An event occurs (e.g., user presses Ctrl+C or a division by zero happens).
2. The kernel halts the process and saves all user-space registers (`RAX`..`R15`, `RIP`, `RFLAGS`) onto the user's stack in a `ucontext` structure.
3. The kernel rewrites the process's Instruction Pointer (`RIP`) to jump to your custom signal handler routine.
4. When your signal handler finishes, it **cannot** just execute `ret` to the caller, because it was invoked by the kernel!
5. Instead, your handler must invoke the **`sys_rt_sigreturn`** (syscall 15) system call, which instructs the kernel to restore the original CPU registers and resume normal program execution!

---

## 2. The `struct sigaction` Layout on Linux x86-64

```text
struct sigaction {
    void     (*sa_handler)(int);      // 8 bytes: pointer to your handler function
    unsigned long sa_flags;           // 8 bytes: flags (e.g. SA_RESTORER = 0x04000000)
    void     (*sa_restorer)(void);    // 8 bytes: pointer to rt_sigreturn trampoline
    sigset_t sa_mask;                 // 8 or 128 bytes signal mask
};
```

### The `sa_restorer` Trampoline:
```nasm
my_restorer:
    mov rax, 15         ; sys_rt_sigreturn
    syscall
```

---

## 3. Hands-on Code Files in this Module
- [`signal_handler.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/24_linux_signals_and_exceptions/signal_handler.asm) - Traps a deliberate division-by-zero (`SIGFPE`) or `SIGINT` without crashing, handles it cleanly, and exits.
