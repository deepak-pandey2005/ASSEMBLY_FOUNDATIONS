# Project 05: Stream-Buffered Base64 CLI File Converter (Pure x86-64 Assembly)

A command-line file encoding utility written entirely in x86-64 assembly that streams arbitrary binary files from disk and produces encoded text files with automated MIME 76-column line-wrapping.

---

## 📦 Features
- **Streaming Buffer Architecture**:
  - Processes files of any size without loading the entire file into memory at once ($4\text{ KB}$ input block buffering).
- **Exact Base64 Bit Packing**:
  - Re-aligns 24-bit triplet boundaries into 4 6-bit sextets.
  - Correct tail padding (`=` or `==`).
- **MIME Standard Line Wrapping**:
  - Automatically inserts newlines (`\r\n` or `\n`) every 76 characters per RFC 2045.
- **Zero Runtime Dependencies**:
  - Direct Linux kernel system calls: `sys_open` (2), `sys_read` (0), `sys_write` (1), `sys_close` (3).

---

## 🛠️ Build and Run

```bash
# Build binary
make

# Run test conversion
make test

# Convert your own file:
./b64encode input.dat output.b64

# Clean artifacts
make clean
```
