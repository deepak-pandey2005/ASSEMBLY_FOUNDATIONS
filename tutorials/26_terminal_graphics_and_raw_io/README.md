# Module 26: Terminal Graphics & Raw Keyboard I/O (`termios` & `ioctl`)

## 🎯 Objectives
- Understand terminal architecture: Canonical (cooked) vs Non-Canonical (raw) mode.
- Manipulate terminal settings directly from assembly using `sys_ioctl` (syscall 16) with `TCGETS` and `TCSETS`.
- Master ANSI Escape Sequences:
  - Clear screen: `\033[2J`
  - Move cursor to $(row, col)$: `\033[<row>;<col>H`
  - Hide/Show cursor: `\033[?25l` / `\033[?25h`
  - Foreground & Background 24-bit RGB and 256-color palette styling.
- Render dynamic real-time animations directly in the Linux terminal without external curses libraries!

---

## 1. Cooked vs Raw Terminal Modes

By default, the Linux terminal runs in **Canonical Mode**:
- Input is buffered line-by-line until the user presses Enter.
- Characters are automatically echoed back to the screen.

For real-time applications (games, text editors like Vim, interactive dashboards), you must switch into **Raw / Non-Canonical Mode**:
1. Disable `ICANON` (Process characters immediately as keys are pressed).
2. Disable `ECHO` (Prevent automatic key echo).
3. Set `VMIN = 1`, `VTIME = 0` (Non-blocking or instant key read).

---

## 2. ANSI Escape Sequences Reference

| Escape Code | Action |
|---|---|
| `\033[2J` | Clear entire terminal screen |
| `\033[H` | Move cursor to top-left corner $(1, 1)$ |
| `\033[10;20H` | Move cursor to row 10, column 20 |
| `\033[31m` | Set text color to bright Red |
| `\033[32m` | Set text color to bright Green |
| `\033[34m` | Set text color to bright Blue |
| `\033[0m` | Reset all colors and styles to default |

---

## 3. Hands-on Code Files in this Module
- [`ansi_canvas.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/26_terminal_graphics_and_raw_io/ansi_canvas.asm) - Renders an animated colored box with status HUD directly in the terminal using pure ANSI escape sequences.
