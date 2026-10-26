# Standalone Project 09: Pure x86-64 Assembly CHIP-8 Virtual Machine & Emulator (`chip8`)

A complete, cycle-accurate implementation of the iconic **CHIP-8 Virtual Machine & CPU interpreter** written entirely in pure Linux x86-64 assembly with **zero external libraries or C runtime (`libc`) dependencies**.

---

## 🎯 Architecture & Specifications

The CHIP-8 virtual machine is a classic interpreted bytecode computer architecture created by Joseph Weisbecker in the 1970s.

### Virtual Hardware Specification
- **Memory**: 4096 bytes (4KB) of virtual RAM:
  - `0x000`–`0x1FF`: Reserved for interpreter font sprites (hex characters `0` through `F`).
  - `0x200`–`0xFFF`: Program and data memory space (ROMs load at address `0x200`).
- **Registers**:
  - 16 general-purpose 8-bit data registers: `V0`, `V1`, ..., `VF` (with `VF` acting as carry/borrow/collision flag).
  - 16-bit Index Register `I` for memory addressing.
  - 16-bit Program Counter `PC` (starts at `0x200`).
  - 8-bit Stack Pointer `SP` pointing to a 16-level 16-bit call stack.
- **Timers**:
  - 8-bit Delay Timer (`DT`) and Sound Timer (`ST`) decremented at 60Hz.
- **Display System**:
  - 64 $\times$ 32 monochrome pixel framebuffer bitfield.
  - Terminal rendering engine using ANSI escape sequences (`\033[H`, full-block `█` pixels).
- **Core Instruction Decoder**:
  - Decodes 2-byte big-endian opcodes:
    - `00E0`: Clear display screen.
    - `00EE`: Return from subroutine (`ret`).
    - `1nnn`: Jump to address `nnn`.
    - `2nnn`: Call subroutine at `nnn`.
    - `3xkk`: Skip next instruction if `Vx == kk`.
    - `4xkk`: Skip next instruction if `Vx != kk`.
    - `5xy0`: Skip next instruction if `Vx == Vy`.
    - `6xkk`: Set `Vx = kk`.
    - `7xkk`: Set `Vx = Vx + kk`.
    - `8xy0`–`8xy7`, `8xyE`: Arithmetic, logic (`OR`, `AND`, `XOR`, `ADD`, `SUB`, `SHR`, `SHL`).
    - `Annn`: Set `I = nnn`.
    - `Cxkk`: Random byte masked with `kk`.
    - `Dxyn`: Draw $n$-byte sprite at coordinates `(Vx, Vy)` with collision detection in `VF`.
    - `Fx1E`, `Fx29`, `Fx33`, `Fx55`, `Fx65`: Memory dump/load and BCD decimal conversion.

---

## 🚀 Building & Testing

```bash
make          # Build the standalone chip8 binary
make test     # Load and execute built-in demonstration test ROM (renders IBM logo sprite)
make clean    # Remove build artifacts
```
