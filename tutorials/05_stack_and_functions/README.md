# Module 05: The Call Stack & Functions (System V AMD64 ABI)

## 🎯 Objectives
- Understand the hardware call stack: Stack Pointer (`rsp`) grows **downward** in memory.
- Master `PUSH`, `POP`, `CALL`, and `RET`.
- Understand the standard **System V AMD64 Calling Convention** used on Linux:
  - Register argument order.
  - Return value register.
  - Caller-saved vs Callee-saved registers.
  - The 16-byte stack alignment rule.
- Implement stack frames with Base Pointer (`rbp`) and local variables.

---

## 1. How the Hardware Stack Operates

The stack grows downward (from high memory addresses to low memory addresses):

```text
High Memory
  |   [ caller's frame ]
  |   [ return address ]  <-- PUSHED automatically by CALL instruction
  |   [ old RBP        ]  <-- PUSH RBP (Prolog)
  |   [ local var 1    ]  <-- [RBP - 8]
  v   [ local var 2    ]  <-- [RBP - 16] == RSP
Low Memory
```

- `push rax`: Decrements `rsp` by 8, then stores `rax` at `[rsp]`.
- `pop rax`: Reads value from `[rsp]`, then increments `rsp` by 8.
- `call func`: Pushes the return address (next RIP) onto the stack, then jumps to `func`.
- `ret`: Pops the return address off the stack into RIP and resumes execution!

---

## 2. System V AMD64 ABI (Linux 64-bit Calling Convention)

When calling functions in 64-bit Linux (both your own functions and C standard library functions like `printf` or `malloc`), arguments **must** be passed in this exact order:

| Argument # | Register | Description |
|---|---|---|
| **Arg 1** | `rdi` | First integer / pointer argument |
| **Arg 2** | `rsi` | Second argument |
| **Arg 3** | `rdx` | Third argument |
| **Arg 4** | `rcx` | Fourth argument |
| **Arg 5** | `r8` | Fifth argument |
| **Arg 6** | `r9` | Sixth argument |
| **7+** | Stack | Pushed onto stack in reverse order |
| **Return** | `rax` | 64-bit return value (or `rax:rdx` for 128-bit) |

### Preserved vs Scratch Registers
- **Callee-Saved (Must be preserved)**: `rbx`, `rsp`, `rbp`, `r12`, `r13`, `r14`, `r15`. If your function modifies these, you MUST push them at the start and pop them before returning!
- **Caller-Saved (Scratch registers)**: `rax`, `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, `r10`, `r11`. A function may overwrite these at any time.

> [!IMPORTANT]
> **The 16-Byte Stack Alignment Rule**:
> The System V ABI requires that the stack pointer `rsp` MUST be aligned to a multiple of 16 bytes immediately before any `call` instruction. If misaligned, functions calling standard library routines or SIMD instructions may crash!

---

## 3. Hands-on Code Files in this Module
- [`function_call.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/function_call.asm) - Calling functions with ABI parameters and return values.
- [`stack_frame.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/stack_frame.asm) - Standard function prolog, local variables, and epilog.
