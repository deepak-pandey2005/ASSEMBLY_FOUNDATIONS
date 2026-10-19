# Module 25: x87 FPU & Extended Precision Floating-Point Math

## 🎯 Objectives
- Understand the legacy and ultra-high-precision x87 Floating-Point Unit (FPU).
- Master the 8-register FPU stack architecture (`ST(0)` top of stack, `ST(1)`, ..., `ST(7)`).
- Learn the IEEE 754 80-bit Extended Precision format (1 sign bit, 15-bit exponent, 64-bit explicit significand).
- Master hardware transcendental instructions:
  - `FLDPI`: Push $\pi$ (3.1415926535...) directly onto the stack.
  - `FSIN` / `FCOS` / `FSINCOS`: Direct hardware sine and cosine in a single instruction!
  - `FSQRT`: Square root.
  - `FADD` / `FMUL` / `FDIV`.
- Convert floating-point values into integers and printable ASCII text.

---

## 1. How the x87 FPU Stack Works

Unlike General Purpose Registers, x87 operates as a hardware LIFO (Last-In-First-Out) stack:

```text
Instruction     Stack State
---------------------------------------
[Empty]         Top of Stack is empty
fldpi           ST(0) = 3.1415926... (pi)
fld1            ST(0) = 1.0, ST(1) = pi
faddp           ST(0) = 1.0 + pi = 4.1415926...
```

- `fld <src>`: Push float from memory onto FPU stack (`ST(0)`).
- `fstp <dest>`: Store `ST(0)` into memory and pop it from stack.
- `fistp <dest>`: Round `ST(0)` to integer, store into memory, and pop.

---

## 2. Calculating Trigonometry in Hardware

In x86 assembly, computing $\sin(\pi / 2) = 1.0$ takes only 4 instructions:
```nasm
fldpi               ; ST(0) = pi
fld dword [two]     ; ST(0) = 2.0, ST(1) = pi
fdivp               ; ST(0) = pi / 2.0
fsin                ; ST(0) = sin(pi / 2) = 1.0!
```

---

## 3. Hands-on Code Files in this Module
- [`fpu_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/25_x87_fpu_floating_point/fpu_math.asm) - Computes $\pi$, square root $\sqrt{2}$, and trigonometric sine, converts to fixed-point integer, and prints.
