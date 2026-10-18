# Module 09: OS Components — Virtual Memory & `mmap`

## 🎯 Objectives
- Understand how modern Operating Systems isolate memory: **Virtual Memory**, **Paging**, and **Page Tables** ($4\text{ KB}$ pages).
- Understand why user-space applications cannot touch physical RAM directly:
  - User-space Virtual Addresses $\to$ MMU (Memory Management Unit) Translation $\to$ Physical DRAM.
  - Page Fault exceptions (`SIGSEGV` when unmapped).
- Master the `sys_mmap` (syscall 9) and `sys_munmap` (syscall 11) Linux kernel interfaces.
- Build an assembly memory allocator (how `malloc` and `free` work under the hood without libc).

---

## 1. How the OS Manages Virtual Memory

Every 64-bit Linux process lives in its own 48-bit or 57-bit virtual address space.
Physical memory is partitioned into 4096-byte ($4\text{ KB}$) chunks called **Page Frames**.

```text
Process Virtual Address
  [ Page Number (VPN) ]  -->  [ Page Table (CR3 Register) ]  --> [ Physical Page Frame (PPN) ]
  [ Offset (0..4095)  ]  ----------------------------------------> [ Offset in DRAM ]
```

When you call `malloc(size)` in C:
1. Small chunks come from a pre-allocated heap managed via `brk` (syscall 12).
2. Large chunks (typically $\ge 128\text{ KB}$) request fresh page mappings directly from the kernel using `mmap` (syscall 9).

---

## 2. Anatomy of `sys_mmap` in x86-64

Syscall number: **`9`** (`rax = 9`)

```text
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
```

| Register | Parameter | Recommended Value for Anonymous Memory |
|---|---|---|
| **RAX** | Syscall Number | `9` (`sys_mmap`) |
| **RDI** | `addr` | `0` (Let the kernel choose the virtual address) |
| **RSI** | `length` | Byte count (e.g., `4096` = 1 page) |
| **RDX** | `prot` | Memory protection flags: `PROT_READ(1) \| PROT_WRITE(2) = 3` |
| **R10** | `flags` | `MAP_PRIVATE(2) \| MAP_ANONYMOUS(32) = 34` (`0x22`) |
| **R8** | `fd` | `-1` (No backing file for anonymous RAM) |
| **R9** | `offset` | `0` |

### Return Value (`rax`):
- **Success**: The virtual pointer to the newly allocated memory pages.
- **Error**: Negative value (e.g. `-12` for `ENOMEM`).

---

## 3. Hands-on Code Files in this Module
- [`mmap_allocator.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/09_memory_management_mmap/mmap_allocator.asm) - Complete zero-dependency dynamic memory allocator and page deallocator.
