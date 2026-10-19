# Module 23: CPU Telemetry & Performance Microbenchmarking (`CPUID` & `RDTSC`)

## 🎯 Objectives
- Understand hardware interrogation via the `CPUID` instruction.
- Query CPU manufacturer identity: `"GenuineIntel"`, `"AuthenticAMD"`.
- Check processor feature flags (AVX2, SSE4.2, AES-NI) directly from register bits.
- Master cycle-accurate instruction benchmarking using `RDTSC` (Read Time-Stamp Counter) and `RDTSCP`.
- Prevent CPU out-of-order instruction pipeline speculation using serializing instructions (`CPUID` or `LFENCE`).

---

## 1. How the `CPUID` Instruction Works

The `CPUID` instruction queries the processor about its capabilities.
It takes a query function number in register `EAX` (and sometimes a sub-leaf in `ECX`), executes, and returns information across `EAX`, `EBX`, `ECX`, and `EDX`.

### Standard Leaf 0: Vendor String Query
- Input: `EAX = 0`
- Output:
  - `EAX`: Maximum supported basic `CPUID` leaf number.
  - `EBX`: Bytes 0-3 of vendor string (e.g. `'G' 'e' 'n' 'u'` for Intel).
  - `EDX`: Bytes 4-7 of vendor string (e.g. `'i' 'n' 'e' 'I'`).
  - `ECX`: Bytes 8-11 of vendor string (e.g. `'n' 't' 'e' 'l'`).

> [!NOTE]
> Notice the peculiar order of register output for the vendor string: **`EBX`**, then **`EDX`**, then **`ECX`**!

### Standard Leaf 1: Feature Bits
- Input: `EAX = 1`
- Output:
  - `EDX Bit 25`: SSE support
  - `EDX Bit 26`: SSE2 support
  - `ECX Bit 28`: AVX support
  - `ECX Bit 25`: AES-NI crypto acceleration support

---

## 2. Cycle-Accurate Benchmarking with `RDTSC`

Modern x86 CPUs maintain an internal 64-bit hardware counter called the **Time-Stamp Counter (TSC)** that increments every clock cycle.

`rdtsc` loads:
- Upper 32 bits into `EDX`
- Lower 32 bits into `EAX`

To combine them into a single 64-bit register `RAX`:
```nasm
rdtsc
shl rdx, 32
or  rax, rdx      ; RAX = 64-bit CPU cycle count
```

### Out-of-Order Execution & Pipeline Serialization
Modern superscalar CPUs execute instructions speculatively out of order!
If you simply place `rdtsc` before and after code, the CPU might execute the code *before* the first `rdtsc` finishes or delay the second `rdtsc`.

To force strict hardware serialization:
```nasm
xor eax, eax
cpuid             ; Serializes instruction pipeline
rdtsc             ; Read start timestamp
... code to benchmark ...
rdtscp            ; Reads timestamp AND guarantees all previous instructions retired
shl rdx, 32
or  rax, rdx      ; Read end timestamp
```

---

## 3. Hands-on Code Files in this Module
- [`cpu_telemetry.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/23_cpu_telemetry_and_benchmarking/cpu_telemetry.asm) - Extracts CPU vendor string, prints it, and measures the cycle latency of 1,000,000 NOPs.
