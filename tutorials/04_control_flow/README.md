# Module 04: Control Flow, Branches, and Loops

## 🎯 Objectives
- Understand conditional execution in hardware (the `CMP` and `TEST` instructions).
- Master conditional jump instructions (`JE`, `JNE`, `JG`, `JL`, `JA`, `JB`, `JLE`, `JGE`).
- Learn the difference between signed comparisons (`G`reater / `L`ess) and unsigned comparisons (`A`bove / `B`elow).
- Implement high-level language constructs:
  - `if / else`
  - `while` loops
  - `for` loops
  - `switch / jump tables`

---

## 1. How Comparisons Actually Work

In assembly, the CPU does not have a "boolean" return value for an `if` statement. Instead:
1. `cmp a, b` computes `a - b` and updates the CPU flags (ZF, CF, SF, OF) while discarding the subtraction result.
2. The conditional jump instruction then checks the CPU flags and branches if the condition is met.

### Jump Table: Signed vs Unsigned

| Condition | Meaning | Signed or Unsigned? | Flags Checked |
|---|---|---|---|
| `je` / `jz` | Jump if Equal / Zero | Both | `ZF = 1` |
| `jne` / `jnz` | Jump if Not Equal / Not Zero | Both | `ZF = 0` |
| `jg` / `jnle` | Jump if Greater | **Signed** | `ZF = 0` and `SF = OF` |
| `jge` / `jnl` | Jump if Greater or Equal | **Signed** | `SF = OF` |
| `jl` / `jnge` | Jump if Less | **Signed** | `SF != OF` |
| `jle` / `jng` | Jump if Less or Equal | **Signed** | `ZF = 1` or `SF != OF` |
| `ja` / `jnbe` | Jump if Above | **Unsigned** | `CF = 0` and `ZF = 0` |
| `jae` / `jnb` | Jump if Above or Equal | **Unsigned** | `CF = 0` |
| `jb` / `jnae` | Jump if Below (Carry set) | **Unsigned** | `CF = 1` |
| `jbe` / `jna` | Jump if Below or Equal | **Unsigned** | `CF = 1` or `ZF = 1` |

---

## 2. Implementing a High-Level `for` Loop

In C:
```c
int sum = 0;
for (int i = 1; i <= 10; i++) {
    sum += i;
}
```

In NASM 64-bit Assembly:
```nasm
    xor eax, eax        ; sum = 0
    mov ecx, 1          ; i = 1

.loop_start:
    cmp ecx, 10         ; compare i with 10
    jg .loop_done       ; if i > 10, exit loop

    add eax, ecx        ; sum += i
    inc ecx             ; i++
    jmp .loop_start     ; repeat

.loop_done:
    ; eax now holds sum = 55
```

---

## 3. Hands-on Code Files in this Module
- [`branches.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/branches.asm) - `if / else-if / else` structure.
- [`loop_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/loop_sum.asm) - Counting loops, array summation, and conditional exits.
