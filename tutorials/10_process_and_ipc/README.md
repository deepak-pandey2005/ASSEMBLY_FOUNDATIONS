# Module 10: OS Components — Process Creation & Inter-Process Communication (IPC)

## 🎯 Objectives
- Understand how modern OS Kernels multitask:
  - Process address spaces & Task Structures (`task_struct` in Linux).
  - The `fork()` mechanism: Copy-On-Write (COW) memory duplication.
- Master `sys_fork` (syscall 57) and `sys_wait4` (syscall 61).
- Implement Inter-Process Communication (IPC) via unidirectional Kernel Pipes (`sys_pipe`, syscall 22).

---

## 1. How `fork()` Clones a Process

When `sys_fork` executes:
1. The kernel creates an exact duplicate of the calling process's file descriptors, registers, and memory mappings.
2. In the **parent** process, `fork` returns the PID of the new child process ($> 0$).
3. In the **child** process, `fork` returns **`0`**.
4. Both processes continue execution from the very next instruction!

```text
[ Parent Process ] ---- sys_fork() ----+
                                       |
    (RAX = child_pid)                  | (RAX = 0)
            ↓                          ↓
   [ Parent Continues ]        [ Child Executes ]
```

---

## 2. Unix Kernel Pipes for IPC

A pipe is a kernel-buffered ring buffer with two file descriptors:
- `pipefd[0]`: Read end
- `pipefd[1]`: Write end

When a parent forks, the child inherits both file descriptors.
By having the child write into `pipefd[1]` and the parent read from `pipefd[0]`, data transfers safely across isolated address spaces without shared memory race conditions.

---

## 3. Hands-on Code Files in this Module
- [`fork_pipe_ipc.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/10_process_and_ipc/fork_pipe_ipc.asm) - Spawns child process, creates kernel pipe, sends message through pipe, and parent waits for child exit.
