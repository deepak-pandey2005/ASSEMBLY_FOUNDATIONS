# x86-64 Architecture & Register Reference

## 1. General-Purpose Registers (GPRs)

x86-64 expands the 8 32-bit registers to 16 64-bit registers, and adds flexible 8-bit, 16-bit, and 32-bit sub-register views.

| 64-bit Reg | 32-bit Reg | 16-bit Reg | 8-bit Low | 8-bit High | Conventional Purpose | ABI Status |
|---|---|---|---|---|---|---|
| `rax` | `eax` | `ax` | `al` | `ah` | Accumulator, Syscall #, Return value | Scratch / Caller-saved |
| `rbx` | `ebx` | `bx` | `bl` | `bh` | Base register | **Callee-saved** |
| `rcx` | `ecx` | `cx` | `cl` | `ch` | Counter for loops/shifts, Arg 4 | Scratch / Caller-saved |
| `rdx` | `edx` | `dx` | `dl` | `dh` | Data register (div/mul), Arg 3 | Scratch / Caller-saved |
| `rsi` | `esi` | `si` | `sil`| - | Source pointer for strings, Arg 2 | Scratch / Caller-saved |
| `rdi` | `edi` | `di` | `dil`| - | Destination pointer, Arg 1 | Scratch / Caller-saved |
| `rbp` | `ebp` | `bp` | `bpl`| - | Stack base frame pointer | **Callee-saved** |
| `rsp` | `esp` | `sp` | `spl`| - | Stack pointer | **Callee-saved** |
| `r8` | `r8d` | `r8w` | `r8b`| - | Arg 5 | Scratch / Caller-saved |
| `r9` | `r9d` | `r9w` | `r9b`| - | Arg 6 | Scratch / Caller-saved |
| `r10`| `r10d`| `r10w`| `r10b`| - | Syscall 4th argument | Scratch / Caller-saved |
| `r11`| `r11d`| `r11w`| `r11b`| - | Scratch (clobbered by `syscall`) | Scratch / Caller-saved |
| `r12`| `r12d`| `r12w`| `r12b`| - | General purpose | **Callee-saved** |
| `r13`| `r13d`| `r13w`| `r13b`| - | General purpose | **Callee-saved** |
| `r14`| `r14d`| `r14w`| `r14b`| - | General purpose | **Callee-saved** |
| `r15`| `r15d`| `r15w`| `r15b`| - | General purpose | **Callee-saved** |

---

## 2. Special Registers

- **`RIP` (Instruction Pointer)**:
  Holds the virtual address of the next instruction to execute. In x86-64, you can do RIP-relative addressing:
  ```nasm
  lea rax, [rel my_var]  ; Position-Independent Code (PIC)
  ```
- **`RFLAGS` (Flags Register)**:
  - Bit 0: **CF** (Carry Flag)
  - Bit 2: **PF** (Parity Flag)
  - Bit 4: **AF** (Auxiliary Carry Flag)
  - Bit 6: **ZF** (Zero Flag)
  - Bit 7: **SF** (Sign Flag)
  - Bit 10: **DF** (Direction Flag - 0=forward, 1=backward)
  - Bit 11: **OF** (Overflow Flag)

---

## 3. Data Suffixes and Sizes

| Size | Intel Keyword (NASM) | AT&T Suffix (GAS) | C Type | Bits |
|---|---|---|---|---|
| 1 Byte | `byte` | `b` | `char`, `uint8_t` | 8 |
| 2 Bytes | `word` | `w` | `short`, `int16_t` | 16 |
| 4 Bytes | `dword` (doubleword) | `l` (long) | `int`, `int32_t` | 32 |
| 8 Bytes | `qword` (quadword) | `q` (quad) | `long`, `int64_t`, pointers | 64 |
| 16 Bytes| `oword` / `xmmword` | `o` | `__int128`, SSE `__m128` | 128 |
