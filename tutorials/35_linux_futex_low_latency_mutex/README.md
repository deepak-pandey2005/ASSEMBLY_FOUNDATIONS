# Module 35: Low-Latency Mutex with Linux Futex (`sys_futex`)

## 🎯 Objectives
- Understand why user-space spinlocks are inefficient for high-contention or long waits (wasting 100% CPU time in busy loops).
- Master the Linux kernel **`futex`** (Fast Userspace Mutex) architecture via **`sys_futex`** (Syscall 202):
  - In the **uncontended case**, locking and unlocking are performed entirely in user space using a single atomic instruction (`lock cmpxchg`), taking zero syscall overhead ($O(1)$ latency).
  - In the **contended case**, the kernel puts waiting threads to sleep and wakes them up only when the resource becomes available:
    - **`FUTEX_WAIT`** (`0`): Suspends calling thread inside the kernel until awakened if the memory value equals `val`.
    - **`FUTEX_WAKE`** (`1`): Wakes up to `val` waiting threads sleeping on the futex address.
    - **`FUTEX_PRIVATE_FLAG`** (`128`): Optimizes operations when threads belong to the same process virtual address space.
- Implement a complete, high-performance mutex abstraction in pure x86-64 assembly:
  - **`mutex_lock(int32_t *futex_word)`**
  - **`mutex_unlock(int32_t *futex_word)`**
- Coordinate concurrent threads spawned via `sys_clone` competing for a shared counter to prove zero race conditions and correct futex sleeping/waking behavior.

---

## 1. Fast Userspace Mutex (Futex) State Machine

A 32-bit integer represents the lock state:
- `0`: **Unlocked**
- `1`: **Locked, no waiters**
- `2`: **Locked, one or more threads sleeping in kernel queue**

```text
                  lock cmpxchg (0 -> 1)
   [ UNLOCKED: 0 ] ───────────────────> [ LOCKED: 1 ]
         ^                                    │
         │                                    │ Contention detected
         │                                    v
   mutex_unlock() <───────────────────── [ LOCKED WITH WAITERS: 2 ]
    wake kernel                            sys_futex(FUTEX_WAIT)
```

---

## 2. Hands-on Code Files in this Module
- [`futex_mutex.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/35_linux_futex_low_latency_mutex/futex_mutex.asm) - Complete, pure assembly 3-state futex implementation, multithreaded stress test, and verification.
