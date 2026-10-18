# GDB Assembly Debugging Cheat Sheet

## 1. Starting GDB with an Assembly Target

```bash
# Start GDB cleanly without welcome banner
gdb -q ./binary

# Start directly in TUI Assembly layout
gdb -tui ./binary
```

Inside GDB, if not already configured:
```gdb
set disassembly-flavor intel
layout asm
layout regs
```

---

## 2. Breakpoints & Execution Control

```gdb
# Set breakpoint at entry point
b *_start

# Set breakpoint at specific instruction address
b *0x401050

# Set breakpoint at function symbol
b my_function

# Run the program
r

# Continue execution until next breakpoint
c

# Step EXACTLY one assembly instruction (stepping INTO calls)
si

# Next assembly instruction (stepping OVER calls)
ni

# Step N instructions
si 5
```

---

## 3. Register Inspection

```gdb
# Show all registers
i r
info registers

# Show specific register in hex / decimal / binary
p/x $rax        # Hexadecimal
p/d $rax        # Signed decimal
p/u $rax        # Unsigned decimal
p/t $rax        # Binary representation

# Show CPU condition flags
i r rflags
p/x $eflags

# Change a register value on the fly
set $rax = 0x1337
set $rdi = 0
```

---

## 4. Memory Examination (`x` command)

Format: `x/[count][format][size] <address>`

- **Formats**:
  - `x`: Hexadecimal
  - `d`: Decimal
  - `u`: Unsigned decimal
  - `t`: Binary
  - `s`: Null-terminated ASCII string
  - `c`: Character
  - `i`: Disassembled machine instruction

- **Sizes**:
  - `b`: Byte (1 byte)
  - `h`: Halfword (2 bytes / 16-bit)
  - `w`: Word (4 bytes / 32-bit)
  - `g`: Giant / Quadword (8 bytes / 64-bit)

### Common Inspection Patterns:
```gdb
# Disassemble next 10 instructions from current execution point
x/10i $rip

# Examine 16 bytes in hex at memory pointed to by RSI
x/16xb $rsi

# Read a string at memory address
x/s $rdi

# Examine the top 4 64-bit words on the stack
x/4xg $rsp

# Examine local variables relative to base pointer
x/4xg $rbp-32
```

---

## 5. Reverse Execution (When Supported by GDB)
```gdb
record          # Begin recording execution history
reverse-stepi   # Step backward one instruction
reverse-continue# Run backward to previous breakpoint
```
