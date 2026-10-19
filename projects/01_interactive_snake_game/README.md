# Project 01: Interactive Terminal Snake Game (Pure x86-64 Assembly)

A real-time, playable terminal Snake game written entirely in x86-64 assembly without any C runtime or curses library.

---

## 🎮 Features
- **Raw Terminal I/O**: Configures Linux `termios` via `sys_ioctl` (syscall 16) into non-canonical and non-echo mode with non-blocking key reads (`VMIN = 0`, `VTIME = 0`).
- **ANSI Terminal Graphics**: Renders grid borders, snake body, and food items dynamically using ANSI escape sequences.
- **Game Engine Mechanics**:
  - Linear 2D coordinate board ($20 \times 40$).
  - Circular buffer / array tracking snake body segments.
  - Directional control: `W` (Up), `S` (Down), `A` (Left), `D` (Right), and `Q` (Quit).
  - Food generation and score tracking.
  - Game over collision detection (wall boundaries and self-collision).
- **Smooth Game Loop**: Frame pacing via `sys_nanosleep` (syscall 35).

---

## 🛠️ Build and Run

```bash
# Build binary
make

# Play game!
./snake

# Clean build artifacts
make clean
```
