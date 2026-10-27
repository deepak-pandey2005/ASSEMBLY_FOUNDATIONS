# Module 39: Lock-Free SPSC Ring Buffer Concurrency (Zero Mutexes)

## 🎯 Objectives
- Understand modern lock-free, zero-mutex inter-thread queue architecture:
  - Single-Producer Single-Consumer (SPSC) circular queue: the foundational pattern used in high-frequency trading (HFT) engines, audio DSP pipelines, and network packet drivers (DPDK, `io_uring`).
  - Achieves millions of messages per second with **zero mutexes**, **zero kernel locks**, and **zero syscalls** during message transfer.
- Master microarchitectural cache-line alignment & False Sharing prevention:
  - Modern x86-64 processors cache memory in 64-byte blocks (cache lines).
  - If the Producer's write pointer (`tail`) and the Consumer's write pointer (`head`) share the same 64-byte cache line, every modification triggers inter-core cache invalidations (False Sharing), degrading throughput by up to 10×.
  - Solving false sharing in assembly via `align 64` and cache-line padding:
    ```nasm
    align 64
    producer_tail:  resq 1
    pad1:           resb 56     ; Isolates tail on its own 64-byte cache line

    align 64
    consumer_head:  resq 1
    pad2:           resb 56     ; Isolates head on its own 64-byte cache line
    ```
- Understand x86-64 Total Store Order (TSO) Memory Consistency:
  - On x86-64, writes to memory are never reordered with older writes, and reads are never reordered with older reads.
  - Storing the ring element *before* updating `producer_tail` guarantees the Consumer will never observe the updated tail pointer before the payload data is visible in cache!
- Implement the `pause` instruction in spin-wait loops:
  - Informs the CPU execution pipeline that a spin-wait loop is executing.
  - Prevents pipeline memory order violations upon exiting the loop and reduces processor power consumption.
- Benchmark and verify 1,000,000 streamed elements across raw `sys_clone` kernel threads with mathematical checksum verification ($\sum_{i=1}^{N} i = \frac{N(N+1)}{2}$).

---

## 1. Architectural Queue Layout & Cache Line Isolation

```text
  +---------------------------------------------------------------+
  |                 Cache Line 0 (64 Bytes)                       |
  |  producer_tail (8 bytes) | Padding (56 bytes)                 |
  +---------------------------------------------------------------+
                                 |
                                 |  (No False Sharing!)
                                 v
  +---------------------------------------------------------------+
  |                 Cache Line 1 (64 Bytes)                       |
  |  consumer_head (8 bytes) | Padding (56 bytes)                 |
  +---------------------------------------------------------------+

               RING BUFFER ARRAY (1,024 Slots x 8 Bytes)
  +--------+--------+--------+--------+--------+--------+--------+
  | Slot 0 | Slot 1 | Slot 2 |  ...   | Slot i |  ...   |Slot 1023|
  +--------+--------+--------+--------+--------+--------+--------+
      ^                                   ^
      |                                   |
    head (Consumer reads)               tail (Producer writes)
```

---

## 2. Hands-on Code Files in this Module
- [`spsc_ring.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/39_lockfree_spsc_ring_buffer/spsc_ring.asm) - Pure x86-64 assembly implementation of a lock-free SPSC circular queue with `sys_clone` multithreading and zero external dependencies.
