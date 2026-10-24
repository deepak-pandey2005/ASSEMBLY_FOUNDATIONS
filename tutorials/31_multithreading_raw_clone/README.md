# Module 31: Native Multithreading with Raw `sys_clone` (No Pthreads)

## 🎯 Objectives
- Understand what a "thread" actually is in the Linux kernel:
  - In Linux, processes and threads are both represented internally by the same kernel structure: `task_struct`.
  - A thread is simply a task that **shares** its virtual memory space, file descriptor table, and signal handlers with its parent process!
- Master the **`sys_clone`** (syscall 56) system call in pure x86-64 assembly.
- Learn the foundational clone flags:
  - `CLONE_VM` (`0x00000100`): Share virtual memory space (same page tables).
  - `CLONE_FS` (`0x00000200`): Share file system information (cwd, root).
  - `CLONE_FILES` (`0x00000400`): Share open file descriptors.
  - `CLONE_SIGHAND` (`0x00000800`): Share signal handlers.
  - `CLONE_THREAD` (`0x00010000`): Place child thread in the same thread group (TGID).
- Understand user-space thread stack allocation:
  - Unlike `fork()`, which duplicates the caller's stack, a new thread **MUST** be provided its own separate stack memory!
  - Allocating user-space thread stacks via `mmap` with 16-byte ABI alignment.
- Coordinate shared memory computation between the main thread and background worker threads using atomic instructions.

---

## 1. How `clone()` Differs from `fork()`

| Characteristic | `sys_fork` (Syscall 57) | `sys_clone` (Syscall 56) with `CLONE_VM` |
|---|---|---|
| **Memory Address Space** | Isolated (Copy-on-Write) | **Shared** (Reads/writes affect both threads!) |
| **Process ID (PID)** | New PID assigned | New TID assigned, but shares same TGID (Process ID) |
| **Stack** | Cloned copy of parent stack | **Brand new user-allocated stack pointer** |
| **File Descriptors** | Cloned copy | **Shared** (Closing in one closes for all) |

---

## 2. Anatomy of `sys_clone` in x86-64

On x86-64 Linux:
- `RAX` = **`56`** (`sys_clone`)
- `RDI` = `flags` (e.g., `CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD`)
- `RSI` = `child_stack` (**Must point to the TOP of the newly allocated stack memory**, since x86 stacks grow downward!)
- `RDX` = `ptid` (pointer to write thread ID)
- `R10` = `ctid`
- `R8`  = `tls` (Thread-Local Storage pointer)

```text
Memory Layout of Newly Allocated Thread Stack:
[ Low Address ] ========================================> [ High Address (RSI) ]
                  <----- Stack grows downward (push) <-----
```

---

## 3. Hands-on Code Files in this Module
- [`raw_threads.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/31_multithreading_raw_clone/raw_threads.asm) - Allocates a 16KB stack via `mmap`, spawns a kernel thread via `sys_clone`, modifies shared state concurrently, and synchronizes cleanly.
