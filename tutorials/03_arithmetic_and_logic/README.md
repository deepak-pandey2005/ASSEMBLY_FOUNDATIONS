# Module 03: Arithmetic, Logic, & the RFLAGS Register

## 🎯 Objectives
- Master basic integer math instructions: `ADD`, `ADC`, `SUB`, `SBB`, `NEG`, `INC`, `DEC`.
- Understand signed vs unsigned multiplication (`MUL` vs `IMUL`) and division (`DIV` vs `IDIV`).
- Learn bitwise operations: `AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR`, `SAR`, `ROL`, `ROR`.
- Understand the CPU status flags in **RFLAGS**:
  - **ZF (Zero Flag)**: Result is 0.
  - **CF (Carry Flag)**: Unsigned overflow/carry.
  - **OF (Overflow Flag)**: Signed overflow (e.g. adding two positive numbers produces negative).
  - **SF (Sign Flag)**: Most significant bit is 1 (negative in two's complement).
  - **PF (Parity Flag)**: Lowest byte has an even number of 1-bits.

---

## 1. Multiplication and Division Mechanics

Unlike addition, which works symmetrically, multiplication and division use specific dedicated register pairs:

### 1-Operand Multiplication (`mul` / `imul`):
- `mul rbx` computes: $\text{RDX:RAX} = \text{RAX} \times \text{RBX}$
- The upper 64 bits of the 128-bit result go into `rdx`, lower 64 bits into `rax`.

### Division (`div` / `idiv`):
- Before dividing 64-bit numbers by `rbx`, you must prepare the 128-bit dividend in `rdx:rax`.
- For unsigned: clear `rdx` (`xor rdx, rdx`).
- For signed: sign-extend `rax` into `rdx` using `cqo` (Convert Quadword to Octoword)!
- `idiv rbx` computes:
  - Quotient $\to$ `rax`
  - Remainder (Modulo) $\to$ `rdx`

---

## 2. Bitwise Logic & Tricks

- **Clearing a register to zero**:
  ```nasm
  xor eax, eax    ; Encodes to 2 bytes: 31 c0 (Faster and shorter than mov eax, 0 which is 5 bytes)
  ```
- **Checking if a register is zero without modifying it**:
  ```nasm
  test rax, rax   ; Performs AND, sets ZF and SF, discards result
  jz is_zero
  ```
- **Power of two multiplication and division**:
  ```nasm
  shl rax, 3      ; Multiply by 2^3 = 8
  shr rax, 2      ; Unsigned divide by 2^2 = 4 (shifts in zeros)
  sar rax, 2      ; Signed divide by 4 (preserves sign bit!)
  ```

---

## 3. Hands-on Code Files in this Module
- [`arithmetic.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/arithmetic.asm) - Add, sub, mul, div, remainder, and carry flags.
- [`bitwise.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/bitwise.asm) - Bit shifts, masking, bit extraction, and parity.
