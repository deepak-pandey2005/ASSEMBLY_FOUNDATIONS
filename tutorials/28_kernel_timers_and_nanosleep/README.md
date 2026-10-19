# Module 28: Kernel Timers & High-Resolution Sleep (`sys_nanosleep`)

## 🎯 Objectives
- Understand how operating system kernels manage time and sleep queues.
- Master the `sys_nanosleep` (syscall 35) Linux kernel interface.
- Understand the `struct timespec` data layout:
  - Seconds (`tv_sec`, 64-bit).
  - Nanoseconds (`tv_nsec`, 64-bit, $1\text{ second} = 10^9\text{ nanoseconds}$).
- Learn how the CPU yields execution back to the OS scheduler instead of spinning in a hot `while` loop (which wastes 100% of a CPU core).

---

## 1. Busy Waiting vs Kernel Sleep

### Bad: Busy Waiting (Burns 100% CPU)
```nasm
.spin:
    dec rcx
    jnz .spin           ; Keeps CPU core pinned at maximum frequency and wattage!
```

### Good: Cooperative Kernel Sleep (`sys_nanosleep`)
```nasm
; Relinquishes CPU time slice immediately to the OS scheduler:
mov rax, 35             ; sys_nanosleep
lea rdi, [req_time]     ; pointer to struct timespec
xor rsi, rsi            ; rem = NULL
syscall
```

---

## 2. Anatomy of `struct timespec` in 64-bit Linux

```text
struct timespec {
    time_t tv_sec;      // 8 bytes: seconds
    long   tv_nsec;     // 8 bytes: nanoseconds (0 .. 999,999,999)
};
```

For a 50-millisecond delay:
- `tv_sec  = 0`
- `tv_nsec = 50,000,000` ($5 \times 10^7\text{ ns}$)

---

## 3. Hands-on Code Files in this Module
- [`precise_sleep.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/28_kernel_timers_and_nanosleep/precise_sleep.asm) - Suspends execution for a precise 100 milliseconds and verifies timer return.
