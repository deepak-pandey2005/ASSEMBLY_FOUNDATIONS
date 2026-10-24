# Module 33: Custom Heap Memory Allocator with `sys_brk`

## 🎯 Objectives
- Understand how dynamic memory management actually works under the hood in C libraries like `glibc` (`malloc`, `free`).
- Learn the role of the process **program break** (`brk`) in the Linux virtual memory layout:
  - The heap begins immediately following the uninitialized data segment (`.bss`).
  - The program break points to the current boundary of the process data segment.
- Master the **`sys_brk`** (Syscall 12) system call in x86-64 assembly:
  - `sys_brk(0)`: Returns the current address of the program break.
  - `sys_brk(new_addr)`: Requests the kernel to expand or contract the heap boundary.
- Implement a linked-list heap allocator with:
  - **Block Metadata Header**:
    - `size`: 64-bit integer representing chunk payload size.
    - `is_free`: 64-bit boolean (1 = available for reuse, 0 = currently in use).
    - `next`: 64-bit pointer to the next allocated memory chunk block header.
  - **`asm_malloc(size)`**:
    - Scans the free-list for a reusable block (first-fit strategy).
    - If no suitable free block exists, calls `sys_brk` to expand the heap from the kernel.
    - Returns a pointer directly to the usable payload memory (`header + 24`).
  - **`asm_free(ptr)`**:
    - Marks the header of `ptr - 24` as free (`is_free = 1`) so subsequent allocations reuse existing virtual memory without kernel syscall overhead.

---

## 1. Heap Memory Layout and Block Headers

```text
Low Address -----------------------------------------------------> High Address
[ Header: size | is_free | next ] [ Payload (User Data) ] [ Header ... ] ... [ Program Break ]
^                                 ^                                            ^
Block Start                       Pointer returned to caller                   Current sys_brk
```

Each memory chunk has a 24-byte header:
- `+0`: `size` (8 bytes) — Size of the user payload (excluding header).
- `+8`: `is_free` (8 bytes) — 1 if freed, 0 if allocated.
- `+16`: `next` (8 bytes) — Pointer to next block header, or NULL (0).

---

## 2. Hands-on Code Files in this Module
- [`heap_allocator.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/33_heap_allocator_sys_brk/heap_allocator.asm) - Fully operational dynamic heap memory manager implementing `asm_malloc`, `asm_free`, memory re-use, and heap introspection.
