# Module 06: Linux System Calls (x86_64 vs x86-32)

## 🎯 Objectives
- Understand how user-space programs request services from the Linux Kernel.
- Compare the modern 64-bit `syscall` interface with the legacy 32-bit `int 0x80` interrupt interface.
- Implement File I/O:
  - Reading from standard input (`stdin` = 0).
  - Writing to standard output (`stdout` = 1) and error (`stderr` = 2).
  - Opening, reading, and closing disk files (`sys_open`, `sys_read`, `sys_close`).

---

## 1. 64-bit vs 32-bit Linux Syscall Comparison

| Attribute | 64-bit Linux (`syscall`) | 32-bit Linux (`int 0x80`) |
|---|---|---|
| **Instruction** | `syscall` | `int 0x80` |
| **Syscall Register** | `RAX` | `EAX` |
| **Argument 1** | `RDI` | `EBX` |
| **Argument 2** | `RSI` | `ECX` |
| **Argument 3** | `RDX` | `EDX` |
| **Argument 4** | `R10` *(Notice not RCX!)* | `ESI` |
| **Argument 5** | `R8` | `EDI` |
| **Argument 6** | `R9` | `EBP` |
| **Return Value** | `RAX` | `EAX` |
| **`sys_read` #** | **0** | **3** |
| **`sys_write` #** | **1** | **4** |
| **`sys_open` #** | **2** | **5** |
| **`sys_close` #**| **3** | **6** |
| **`sys_exit` #** | **60** | **1** |

> [!WARNING]
> In 64-bit mode, the `syscall` instruction clobbers `RCX` (used to store return address) and `R11` (used to store RFLAGS). Do not rely on `rcx` or `r11` staying untouched across a syscall!

---

## 2. Common File Open Flags in Linux
In `<fcntl.h>`:
- `O_RDONLY` = 0
- `O_WRONLY` = 1
- `O_RDWR`   = 2
- `O_CREAT`  = 64 (0100 octal)

---

## 3. Hands-on Code Files in this Module
- [`user_input.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/user_input.asm) - Reads input from keyboard (`sys_read`) and echos it back.
- [`cat_file.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/cat_file.asm) - Opens a text file on disk, reads contents into a buffer, and outputs to stdout.
