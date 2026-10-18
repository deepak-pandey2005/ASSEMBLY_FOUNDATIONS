# Module 18: Cryptography & Hashing from Scratch

## 🎯 Objectives
- Understand cryptographic hashing and bit-mixing fundamentals at the hardware instruction level.
- Learn standard non-cryptographic and cryptographic hash mechanics:
  - DJB2 Hash (Daniel J. Bernstein's 33-multiplier algorithm).
  - FNV-1a (Fowler–Noll–Vo prime multiplication and XOR folding).
  - Modern CPU hardware crypto acceleration: Intel `AES-NI` (`aesenc`, `aesdec`, `aeskeygenassist`).
- Implement the canonical DJB2 string hashing algorithm and 32-bit FNV-1a in pure 64-bit assembly.

---

## 1. DJB2 Mathematical Algorithm

DJB2 is one of the most efficient string hash functions ever discovered for hash tables and compiler symbol lookup tables:
$$\text{hash}_{0} = 5381$$
$$\text{hash}_{i} = (\text{hash}_{i-1} \times 33) \oplus c$$

In assembly, multiplying by 33 is optimized into a shift and add:
$$\text{hash} \times 33 = (\text{hash} \ll 5) + \text{hash}$$

```nasm
mov rbx, rax
shl rbx, 5          ; rbx = hash * 32
add rax, rbx        ; rax = hash * 33
xor al, cl          ; hash = (hash * 33) ^ char
```

---

## 2. Hands-on Code Files in this Module
- [`hash_algorithms.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/18_cryptography_and_hashing/hash_algorithms.asm) - DJB2 and FNV-1a hashing algorithms with hex printer.
