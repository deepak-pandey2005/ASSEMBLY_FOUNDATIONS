# Module 08: Debugging Assembly with GDB

## 🎯 Objectives
- Configure GDB for low-level assembly debugging (Intel syntax, register tracking, TUI layout).
- Step through individual assembly instructions using `stepi` (`si`) and `nexti` (`ni`).
- Inspect and modify registers in real time (`info registers`, `p/x $rax`, `set $rax = 0x10`).
- Examine memory structures (`x/x`, `x/s`, `x/10i $rip`).
- Use hardware watchpoints to break when memory changes.

---

## 1. Essential GDB Configuration

Add the following to your `~/.gdbinit` or run it inside GDB:

```gdb
set disassembly-flavor intel
set pagination off
```

Or start the GDB Text User Interface (TUI) assembly layout:
```bash
gdb -tui -ex "layout asm" -ex "layout regs" ./program
```

---

## 2. GDB Assembly Command Cheat Sheet

| Command | Shorthand | Description |
|---|---|---|
| `break *_start` | `b *_start` | Set breakpoint at entry symbol or exact memory address |
| `run` | `r` | Start program execution |
| `stepi` | `si` | Step exactly ONE machine instruction (steps INTO calls) |
| `nexti` | `ni` | Step exactly ONE machine instruction (steps OVER calls) |
| `continue` | `c` | Continue running until next breakpoint |
| `info registers` | `i r` | Print all general-purpose registers in hex and decimal |
| `info registers rflags` | `i r eflags` | Print individual CPU status flags (ZF, CF, SF, OF, etc.) |
| `print /x $rax` | `p/x $rax` | Print specific register in hexadecimal |
| `print /t $rax` | `p/t $rax` | Print specific register in binary bits |
| `x/10i $rip` | `x/10i $rip` | Disassemble and examine the next 10 instructions at instruction pointer |
| `x/s $rsi` | `x/s $rsi` | Examine memory at RSI as an ASCII string |
| `x/8xb $rsp` | `x/8xb $rsp` | Examine 8 bytes in hex at the top of stack |
| `x/4xg $rbp-32` | `x/4xg $rbp-32` | Examine 4 quadwords (64-bit words) at `[rbp-32]` |
| `watch *0x601000` | `watch ...` | Break whenever value at address is modified |

---

## 3. Hands-on Code Files in this Module
- [`debug_target.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/08_debugging_with_gdb/debug_target.asm) - Specially crafted program with math and flags to step through with GDB.
- Run `make debug-target` to automatically launch GDB loaded with this binary!
