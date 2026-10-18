# Module 15: SIMD & AVX2 Vectorization

## 🎯 Objectives
- Understand Single Instruction, Multiple Data (SIMD) hardware execution.
- Learn the register hierarchy:
  - 128-bit: `XMM0` - `XMM15` (SSE)
  - 256-bit: `YMM0` - `YMM15` (AVX / AVX2)
  - 512-bit: `ZMM0` - `ZMM31` (AVX-512)
- Master packed data types:
  - 8 packed 32-bit single-precision floats (`float[8]`)
  - 4 packed 64-bit double-precision floats (`double[4]`)
  - 8 packed 32-bit integers (`int32_t[8]`)
  - 32 packed 8-bit bytes (`uint8_t[32]`)
- Build vectorized vector addition and dot products executing up to $8\times$ faster than scalar loops.

---

## 1. Scalar vs Vectorized Execution

In standard scalar code:
```nasm
; Adding 8 numbers takes 8 loops and 8 ADD instructions
add eax, [rdi]
add eax, [rdi + 4]
; ...
```

In AVX2 vectorized code:
```nasm
; Loads 8 32-bit integers (256 bits) in ONE instruction
vmovdqu ymm0, [rdi]
; Adds all 8 pairs in parallel in a SINGLE CPU clock cycle!
vpaddd  ymm2, ymm0, ymm1
; Store 8 results back to RAM
vmovdqu [rsi], ymm2
```

---

## 2. Aligned vs Unaligned Vector Access
- `vmovdqa`: Aligned load/store (Address MUST be a multiple of 32 bytes, otherwise segfaults!). Faster on older architectures.
- `vmovdqu`: Unaligned load/store (Safe for arbitrary memory addresses). Modern CPUs execute unaligned accesses with virtually zero penalty when within a cache line.

---

## 3. Hands-on Code Files in this Module
- [`avx2_vector_add.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/15_simd_avx_vectorization/avx2_vector_add.asm) - Vectorized 8-element parallel integer addition.
