# Module 16: Concurrency, Atomics & Hardware Synchronization

## 🎯 Objectives
- Understand modern multi-core cache hierarchy (L1/L2 private caches, L3 shared cache, MESI protocol).
- Master hardware atomic operations and the `LOCK` prefix:
  - `LOCK XADD`: Atomic exchange and add (fetch-and-add).
  - `LOCK CMPXCHG`: Compare-And-Swap (CAS), the foundational primitive for all lock-free algorithms.
- Build a hardware spinlock mutex and an atomic counter.
- Understand CPU memory fencing instructions: `MFENCE`, `LFENCE`, `SFENCE`.

---

## 1. Why `add [counter], 1` is NOT Thread-Safe

At the CPU bus level, `add [counter], 1` consists of three distinct micro-operations:
1. **Read**: Load value from memory into internal CPU register.
2. **Modify**: Increment the value.
3. **Write**: Store the updated value back to RAM.

If two CPU cores execute this simultaneously, their reads overlap, causing a lost update!

The **`LOCK` prefix** asserts a bus lock or cache-line lock, forcing the Read-Modify-Write operation to occur atomically across all cores:
```nasm
lock inc dword [counter]
```

---

## 2. Compare-And-Swap (CAS) Mechanics (`CMPXCHG`)

`cmpxchg dest, src`:
- Compares `dest` with accumulator (`RAX` / `EAX`).
- If `dest == RAX`: Sets `ZF = 1` and writes `src` into `dest` (Swap succeeded!).
- If `dest != RAX`: Sets `ZF = 0` and loads `dest` into `RAX` (Swap failed!).

### Building a Spinlock in Assembly:
```nasm
spinlock_acquire:
    mov eax, 0          ; Expected: lock is free (0)
    mov ecx, 1          ; New value: lock is acquired (1)
    lock cmpxchg [lock_var], ecx
    jnz spinlock_acquire; If ZF=0, someone else holds the lock; spin!
    ret

spinlock_release:
    mov dword [lock_var], 0
    ret
```

---

## 3. Hands-on Code Files in this Module
- [`atomic_spinlock.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/16_concurrency_and_atomics/atomic_spinlock.asm) - Atomic spinlock acquire/release and lock-free CAS counter.
