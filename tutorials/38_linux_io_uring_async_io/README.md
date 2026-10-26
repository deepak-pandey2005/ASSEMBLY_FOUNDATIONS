# Module 38: Modern Linux `io_uring` Asynchronous I/O Subsystem

## 🎯 Objectives
- Understand modern high-performance Linux asynchronous I/O with **`io_uring`**:
  - The revolutionary Linux kernel asynchronous I/O interface designed by Jens Axboe to replace POSIX AIO and `epoll`.
  - Solves the fundamental performance limitations of traditional synchronous syscalls: eliminates kernel context switch overhead by sharing lock-free ring buffers between user space and kernel space.
- Master the `io_uring` system call interface in pure x86-64 assembly:
  - **`sys_io_uring_setup`** (Syscall 425):
    - Initializes an `io_uring` instance with specified entry capacity.
    - Populates `struct io_uring_params` and returns a ring file descriptor.
  - **`sys_mmap`** (Syscall 9):
    - Maps the **Submission Queue (SQ) Ring** (`offset = IORING_OFF_SQ_RING = 0x0`).
    - Maps the **Submission Queue Entries (SQEs)** buffer (`offset = IORING_OFF_SQES = 0x10000000`).
    - Maps the **Completion Queue (CQ) Ring** (`offset = IORING_OFF_CQ_RING = 0x8000000`).
  - **`sys_io_uring_enter`** (Syscall 426):
    - Submits pending SQEs to the kernel and optionally waits for completions (`IORING_ENTER_GETEVENTS = 1`).
- Understand lock-free ring buffer coordination:
  - **Submission Queue (SQ)**:
    - User space writes to the submission queue entry array `sqes[index]` and advances `*sq_tail`.
    - Kernel consumes SQEs starting from `*sq_head`.
  - **Completion Queue (CQ)**:
    - Kernel writes completed operations to `cqes[index]` and advances `*cq_tail`.
    - User space reaps results and advances `*cq_head`.
- Asynchronous Operations Demonstrated:
  - **`IORING_OP_NOP`** (Opcode 0): Zero-overhead operation validating the full submission/completion lifecycle.
  - **`IORING_OP_WRITE`** (Opcode 23): True asynchronous non-blocking write to file descriptors without user-space threads.

---

## 1. Architectural Ring Layout & Memory Mapping

```text
               USER SPACE                              KERNEL SPACE
    +------------------------------+
    | Submission Queue Ring (SQ)   | <-------- Shared memory via sys_mmap
    |  * Head (Kernel updates)     |           (IORING_OFF_SQ_RING: 0x0)
    |  * Tail (User updates)       |
    +------------------------------+
    | Submission Queue Entries     | <-------- Array of 64-byte SQE structures
    |  [SQE 0] [SQE 1] ... [SQE N] |           (IORING_OFF_SQES: 0x10000000)
    +------------------------------+
                   |
     sys_io_uring_enter(fd, ...) ------------> Kernel Execution Engine
                   |                           (Dispatches async I/O)
                   v
    +------------------------------+
    | Completion Queue Ring (CQ)   | <-------- Shared memory via sys_mmap
    |  * Head (User updates)       |           (IORING_OFF_CQ_RING: 0x8000000)
    |  * Tail (Kernel updates)     |
    |  [CQE 0] [CQE 1] ... [CQE M] |
    +------------------------------+
```

---

## 2. Hands-on Code Files in this Module
- [`io_uring_demo.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/38_linux_io_uring_async_io/io_uring_demo.asm) - Pure x86-64 assembly implementation of `io_uring` ring mapping, submission, and completion handling with zero external dependencies.
