# Module 40: Anonymous Memory Execution (`sys_memfd_create` & `sys_execveat`)

## 🎯 Objectives
- Master the modern Linux in-memory binary execution mechanism:
  - Execute native x86-64 executable binaries straight out of RAM without creating any file on disk.
  - Understand why traditional binary drop techniques (writing to `/tmp`, setting `chmod +x`, calling `execve`) leave disk forensics, cause disk I/O latency, and fail on filesystems mounted with `noexec`.
- Master Linux System Calls for Anonymous In-Memory Files:
  - `sys_memfd_create` (syscall 319): Creates an anonymous, memory-resident file descriptor backed by RAM (shmfs/tmpfs), invisible to directory listings.
  - `sys_fcntl` (syscall 72) with `F_ADD_SEALS`: Seals the anonymous memory file against subsequent modification (`F_SEAL_WRITE`, `F_SEAL_SHRINK`, `F_SEAL_GROW`), locking the binary in memory as immutable.
  - `sys_execveat` (syscall 322): Executes an executable binary specified by an open file descriptor (`dirfd`) instead of a filesystem pathname, using the `AT_EMPTY_PATH` (0x1000) flag.
  - `sys_fork` (syscall 57) & `sys_wait4` (syscall 61): Manages parent/child process isolation, lifecycle, and status code verification.
- Understand Handcrafted 64-bit ELF Executable Structure:
  - Dissect the 64-byte `Elf64_Ehdr` (ELF header) and 56-byte `Elf64_Phdr` (`PT_LOAD` segment header).
  - Construct a valid 242-byte minimalist 64-bit ELF binary embedded directly in the `.rodata` section.
  - Zero external C runtime (`libc`) dependencies: 100% pure Linux x86-64 assembly syscalls.

---

## 1. Architectural Flow: Zero Disk Footprint Execution

```text
       +---------------------------------------------------------------+
       |                      RAM / Kernel Space                       |
       +---------------------------------------------------------------+
                                      |
   1. sys_memfd_create("anon_elf")    |  Allocates memory-backed anonymous fd
   ---------------------------------> [ memfd: 3 ]
                                      |
   2. sys_write(memfd, elf_payload)   |  Copies 242-byte handcrafted ELF into RAM
   ---------------------------------> [ [ELF Header] [PT_LOAD] [Code/Data] ]
                                      |
   3. sys_fcntl(memfd, F_ADD_SEALS)   |  Locks memory against shrinkage / write
   ---------------------------------> [ IMMUTABLE RAM BINARY ]
                                      |
   4. sys_fork()                      |  Spawns child process
   ---------------------------------> [ Child Process ]
                                             |
   5. sys_execveat(memfd, "", argv, envp, AT_EMPTY_PATH)
   ------------------------------------------+
                                             |
                                             v
                           Kernel ELF Loader parses RAM FD
                           Maps PT_LOAD into child address space
                           Jumps to e_entry (0x400078)
                                             |
                                             v
                           "[In-Memory Child] Executed anonymously..."
                           Child exits with code 42!
```

---

## 2. Linux System Call Reference

| System Call | Syscall Number (`rax`) | Arguments | Description |
|:---|:---:|:---|:---|
| `sys_memfd_create` | `319` | `rdi`: name pointer, `rsi`: flags (`MFD_ALLOW_SEALING`) | Allocates an anonymous in-memory file descriptor. |
| `sys_write` | `1` | `rdi`: fd, `rsi`: buf, `rdx`: count | Writes binary bytes into the in-memory descriptor. |
| `sys_fcntl` | `72` | `rdi`: fd, `rsi`: `F_ADD_SEALS` (1033), `rdx`: seals | Locks descriptor as immutable. |
| `sys_fork` | `57` | None | Spawns child process to run payload. |
| `sys_execveat` | `322` | `rdi`: fd, `rsi`: `""`, `rdx`: argv, `r10`: envp, `r8`: `0x1000` | Executes binary directly from open descriptor. |
| `sys_wait4` | `61` | `rdi`: pid, `rsi`: &wstatus, `rdx`: 0, `r10`: NULL | Parent waits and retrieves child exit code (42). |
| `sys_close` | `3` | `rdi`: fd | Closes file descriptor, reclaiming anonymous RAM. |

---

## 3. Hands-on Code Files in this Module
- [`memfd_exec.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/40_anonymous_memfd_execution/memfd_exec.asm) - Complete x86-64 assembly implementation of anonymous memory execution with embedded handcrafted ELF payload, file sealing, process lifecycle management, and status verification.
