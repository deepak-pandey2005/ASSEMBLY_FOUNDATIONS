# Complete x86 and x86-64 Instruction Reference

This reference is categorized by function with hardware operation descriptions, flag impacts, and examples in both Intel (NASM) and AT&T (GAS) syntaxes.

---

## 1. Data Movement Instructions

### `MOV` (Move)
- **Syntax**: `mov dest, src` (Intel) / `mov src, dest` (AT&T)
- **Operation**: Copies data from `src` to `dest`.
- **Flags**: None affected.
- **Constraints**: Both operands cannot be memory locations simultaneously (`mov [a], [b]` is illegal in x86).
- **Example**:
  ```nasm
  mov rax, 10           ; immediate to register
  mov [rdi], rax        ; register to memory
  mov rax, [rsi + 8]    ; memory to register
  ```

### `MOVSX` / `MOVSXD` (Move with Sign-Extension)
- **Operation**: Copies smaller signed integer to larger register, copying sign bit across high bits.
- **Example**:
  ```nasm
  movsx rax, byte [val] ; sign-extends 8-bit to 64-bit
  movsxd rax, ebx       ; sign-extends 32-bit to 64-bit
  ```

### `MOVZX` (Move with Zero-Extension)
- **Operation**: Copies smaller unsigned integer to larger register, zeroing high bits.
- **Example**:
  ```nasm
  movzx rax, byte [val] ; loads 8-bit byte into 64-bit rax, upper 56 bits = 0
  ```

### `LEA` (Load Effective Address)
- **Operation**: Calculates address using memory addressing hardware *without* accessing RAM.
- **Flags**: None.
- **Example**:
  ```nasm
  lea rax, [rbx + rcx*4 + 16] ; rax = rbx + (rcx*4) + 16
  ```

### `PUSH` & `POP`
- **Operation**:
  - `push src`: `RSP = RSP - 8`, `[RSP] = src`
  - `pop dest`: `dest = [RSP]`, `RSP = RSP + 8`

### `BSWAP` (Byte Swap)
- **Operation**: Reverses byte order (Little-Endian $\leftrightarrow$ Big-Endian).
- **Example**:
  ```nasm
  bswap eax             ; if eax was 0x12345678, now 0x78563412
  ```

---

## 2. Integer Arithmetic

### `ADD` / `SUB`
- **Operation**: `dest = dest + src` / `dest = dest - src`
- **Flags**: Updates `CF`, `OF`, `SF`, `ZF`, `AF`, `PF`.

### `ADC` / `SBB` (Add/Subtract with Carry/Borrow)
- **Operation**: `dest = dest + src + CF` / `dest = dest - src - CF`
- **Use Case**: Multi-precision integer arithmetic (e.g. 128-bit, 256-bit).

### `INC` / `DEC`
- **Operation**: `dest = dest + 1` / `dest = dest - 1`
- **Flags**: Updates `OF`, `SF`, `ZF`, `AF`, `PF` (**Does NOT modify CF!**).

### `MUL` (Unsigned Multiply) & `IMUL` (Signed Multiply)
- **1-operand**: `mul rbx` $\to$ `RDX:RAX = RAX * RBX`
- **2-operand (signed only)**: `imul rax, rbx` $\to$ `rax = rax * rbx`
- **3-operand (signed only)**: `imul rax, rbx, 5` $\to$ `rax = rbx * 5`

### `DIV` (Unsigned) & `IDIV` (Signed)
- **Operation**: Divides `RDX:RAX` by operand.
- **Quotient**: `RAX`
- **Remainder**: `RDX`
- **Preparation**: Unsigned requires clearing `RDX` (`xor rdx, rdx`). Signed requires `cqo` (Convert Quadword to Octoword) to sign-extend `RAX` into `RDX:RAX`.

---

## 3. Logical and Bitwise Instructions

### `AND`, `OR`, `XOR`
- Clears `OF` and `CF`, sets `SF`, `ZF`, and `PF`.
- `xor reg, reg` is the canonical idiom for zeroing a register.

### `TEST`
- **Operation**: Computes `dest AND src`, updates `SF`, `ZF`, `PF`, discards the result.
- Frequently used before conditional jumps:
  ```nasm
  test rax, rax
  jz is_zero
  ```

### `CMP`
- **Operation**: Computes `dest - src`, updates flags, discards the result.

### `SHL` / `SHR` (Shift Logical Left / Right)
- Shifts bits, fills vacated spots with zeroes. Shift count can be immediate or in register `CL`.

### `SAR` (Shift Arithmetic Right)
- Shifts bits right, but **preserves** the sign bit (MSB). Used for signed integer division by powers of 2.

---

## 4. Control Flow and Branching

### Unconditional Jump: `JMP target`
- Sets `RIP = target`.

### Conditional Jumps (Signed):
- `JE` / `JZ`: Jump if equal / zero (`ZF = 1`)
- `JNE` / `JNZ`: Jump if not equal (`ZF = 0`)
- `JG` / `JNLE`: Jump if greater (`ZF = 0 and SF = OF`)
- `JGE` / `JNL`: Jump if greater or equal (`SF = OF`)
- `JL` / `JNGE`: Jump if less (`SF != OF`)
- `JLE` / `JNG`: Jump if less or equal (`ZF = 1 or SF != OF`)

### Conditional Jumps (Unsigned):
- `JA` / `JNBE`: Jump if above (`CF = 0 and ZF = 0`)
- `JAE` / `JNB`: Jump if above or equal (`CF = 0`)
- `JB` / `JNAE`: Jump if below (`CF = 1`)
- `JBE` / `JNA`: Jump if below or equal (`CF = 1 or ZF = 1`)

---

## 5. String / Block Operations

| Instruction | Direction | Size | Source | Destination |
|---|---|---|---|---|
| `MOVSB` / `MOVSW` / `MOVSD` / `MOVSQ` | `DF=0` (+), `DF=1` (-) | 1, 2, 4, 8 bytes | `[RSI]` | `[RDI]` |
| `STOSB` / `STOSQ` | `DF=0` (+), `DF=1` (-) | Store `AL`/`RAX` | `RAX` | `[RDI]` |
| `LODSB` / `LODSQ` | `DF=0` (+), `DF=1` (-) | Load into `AL`/`RAX` | `[RSI]` | `RAX` |
| `SCASB` / `SCASQ` | `DF=0` (+), `DF=1` (-) | Compare with `AL`/`RAX` | `[RDI]` | `RAX` |

- `CLD`: Clears Direction Flag (`DF = 0`, pointers increment).
- `STD`: Sets Direction Flag (`DF = 1`, pointers decrement).
- `REP`: Repeat while `RCX != 0`, decrementing `RCX` each cycle.
