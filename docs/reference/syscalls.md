# Linux System Calls Reference (x86_64 vs x86-32)

## 1. Fast Reference Tables

### Modern 64-bit Linux (`syscall`)

| %rax | System Call | %rdi (arg1) | %rsi (arg2) | %rdx (arg3) | %r10 (arg4) | %r8 (arg5) | %r9 (arg6) |
|---|---|---|---|---|---|---|---|
| `0` | `sys_read` | `unsigned int fd` | `char *buf` | `size_t count` | - | - | - |
| `1` | `sys_write` | `unsigned int fd` | `const char *buf` | `size_t count` | - | - | - |
| `2` | `sys_open` | `const char *filename` | `int flags` | `umode_t mode` | - | - | - |
| `3` | `sys_close` | `unsigned int fd` | - | - | - | - | - |
| `9` | `sys_mmap` | `unsigned long addr` | `unsigned long len` | `unsigned long prot` | `unsigned long flags` | `unsigned long fd` | `unsigned long off` |
| `10` | `sys_mprotect` | `unsigned long start` | `size_t len` | `unsigned long prot` | - | - | - |
| `11` | `sys_munmap` | `unsigned long addr` | `size_t len` | - | - | - | - |
| `12` | `sys_brk` | `unsigned long brk` | - | - | - | - | - |
| `57` | `sys_fork` | - | - | - | - | - | - |
| `59` | `sys_execve` | `const char *filename` | `const char *const *argv` | `const char *const *envp` | - | - | - |
| `60` | `sys_exit` | `int error_code` | - | - | - | - | - |

---

### Legacy 32-bit Linux (`int 0x80`)

| %eax | System Call | %ebx (arg1) | %ecx (arg2) | %edx (arg3) | %esi (arg4) | %edi (arg5) | %ebp (arg6) |
|---|---|---|---|---|---|---|---|
| `1` | `sys_exit` | `int error_code` | - | - | - | - | - |
| `2` | `sys_fork` | - | - | - | - | - | - |
| `3` | `sys_read` | `unsigned int fd` | `char *buf` | `size_t count` | - | - | - |
| `4` | `sys_write` | `unsigned int fd` | `const char *buf` | `size_t count` | - | - | - |
| `5` | `sys_open` | `const char *filename` | `int flags` | `umode_t mode` | - | - | - |
| `6` | `sys_close` | `unsigned int fd` | - | - | - | - | - |
| `11` | `sys_execve` | `const char *filename` | `char **argv` | `char **envp` | - | - | - |

---

## 2. Common File Open Flags (`flags` argument)
- `0x0000` (`00` octal) : `O_RDONLY` (Read Only)
- `0x0001` (`01` octal) : `O_WRONLY` (Write Only)
- `0x0002` (`02` octal) : `O_RDWR` (Read & Write)
- `0x0040` (`0100` octal): `O_CREAT` (Create file if it doesn't exist)
- `0x0200` (`01000` octal): `O_TRUNC` (Truncate file length to 0)
- `0x0400` (`02000` octal): `O_APPEND` (Append writes to end of file)

---

## 3. Syscall Return Values & Error Handling
On Linux:
- Non-negative value ($0 \dots 2^{63}-1$): Success (e.g. number of bytes written/read, or file descriptor).
- Negative value between $-4095$ and $-1$: Error occurred.
  - The absolute value corresponds to the kernel `errno` (e.g., `-EACCES`, `-ENOENT`, `-EBADF`).
  - Check in assembly:
    ```nasm
    cmp rax, 0
    jl .handle_error
    ```
