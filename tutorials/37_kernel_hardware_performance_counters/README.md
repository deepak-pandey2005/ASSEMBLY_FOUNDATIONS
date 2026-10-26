# Module 37: Linux Kernel Hardware Performance Counters (`sys_perf_event_open`)

## 🎯 Objectives
- Understand modern CPU Performance Monitoring Units (PMUs):
  - Hardware performance monitoring counters integrated inside modern x86-64 processors (Intel Core, AMD Zen).
  - Collect exact architectural events at zero microsecond software overhead:
    - **`PERF_COUNT_HW_INSTRUCTIONS`**: Total architectural instructions retired by the CPU execution units.
    - **`PERF_COUNT_HW_CPU_CYCLES`**: Total core clock cycles consumed while executing the code path.
    - **Instructions Per Cycle (IPC)**: Primary metric of microprocessor execution efficiency and pipeline throughput.
- Interface with the Linux kernel performance subsystem directly via system calls:
  - **`sys_perf_event_open`** (Syscall 298): Configures a hardware PMU event and binds it to a process, returning an event file descriptor.
  - **`sys_ioctl`** (Syscall 16):
    - `PERF_EVENT_IOC_ENABLE` (`0x2400`): Activates the PMU counter.
    - `PERF_EVENT_IOC_DISABLE` (`0x2401`): Freezes the PMU counter.
    - `PERF_EVENT_IOC_RESET` (`0x2402`): Resets the hardware accumulator to zero.
  - **`sys_read`** (Syscall 0): Reads the 64-bit hardware event counter value from the kernel descriptor.
  - **`sys_close`** (Syscall 3): Releases the PMU counter and frees the kernel event allocation.
- Master binary layout of Linux **`struct perf_event_attr`**:
  ```c
  struct perf_event_attr {
      __u32 type;                 /* PERF_TYPE_HARDWARE = 0 (offset 0) */
      __u32 size;                 /* sizeof(struct perf_event_attr) = 144 (offset 4) */
      __u64 config;               /* HW_INSTRUCTIONS / HW_CPU_CYCLES (offset 8) */
      __u64 sample_period;        /* 0 (offset 16) */
      __u64 sample_type;          /* 0 (offset 24) */
      __u64 read_format;          /* 0 (offset 32) */
      __u64 flags;                /* disabled(1) | exclude_kernel(0x20) | exclude_hv(0x40) (offset 40) */
      /* remaining fields zeroed */
  };
  ```
- Build an automated x86-64 benchmarking harness:
  - Counts instructions retired and CPU cycles during an unrolled assembly arithmetic loop.
  - Computes and displays Instructions-Per-Cycle (IPC) formatted as fixed-point `X.XX`.
  - Graceful fallback with `RDTSC` cycle telemetry when executed in virtualized or containerized environments with restricted PMU access.

---

## 1. Hardware PMU Architecture & Kernel Abstraction

```text
               +-------------------------------------+
               |         User Assembly Space         |
               |                                     |
               |  sys_perf_event_open (Syscall 298)  |
               +------------------+------------------+
                                  |
                                  v
               +-------------------------------------+
               |         Linux Kernel Subsystem      |
               |          (kernel/events/core.c)     |
               |                                     |
               |  Configures MSRs & Allocates PMU    |
               +------------------+------------------+
                                  |
                                  v
               +-------------------------------------+
               |   x86-64 Microarchitecture PMU      |
               |  (IA32_PERFCTR0 / MSR_PERF_CTL)     |
               |                                     |
               | [HW Cycles]    [Inst Retired]       |
               +-------------------------------------+
```

---

## 2. Hands-on Code Files in this Module
- [`perf_counters.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/37_kernel_hardware_performance_counters/perf_counters.asm) - Complete PMU hardware performance counter program in pure x86-64 assembly with zero external dependencies.
