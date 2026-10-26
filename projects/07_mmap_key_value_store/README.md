# Standalone Project 07: Memory-Mapped Persistent Key-Value Store (`mkvstore`)

A disk-persistent, zero-copy binary key-value database engine built entirely in pure x86-64 assembly with **zero C standard library (`libc`) dependencies**.

---

## 🎯 Architecture & Specifications

- **Zero-Copy Memory-Mapped Persistence**:
  - Uses Linux system calls `sys_open` (2), `sys_lseek` (8), `sys_ftruncate` (77), `sys_mmap` (9) with `MAP_SHARED`, and `sys_msync` (26).
  - Memory-mapped file updates are synchronized directly to disk blocks without user-space buffer copying.
- **Fixed-Width Binary Slot Database Schema**:
  - **Database Header (16 bytes)**:
    - Magic Signature: `0x564B4D53` (`"SMKV"` - Simple Memory Key-Value)
    - Slot Count: 64-bit integer
  - **Record Slot (64 bytes)**:
    - Status Flag (1 byte): `0x00` = Empty, `0x01` = Active
    - Key (31 bytes): Null-padded ASCII key string
    - Value (32 bytes): Null-padded ASCII value string
- **CLI Commands**:
  - `set <key> <value>`: Inserts or updates a key-value pair in the database file.
  - `get <key>`: Queries the memory-mapped index and prints the corresponding value.
  - `dump`: Iterates through all populated slots and displays keys and values.

---

## 🚀 Building & Running

```bash
make          # Build the standalone mkvstore binary
make test     # Run automated set, get, and dump verification
make clean    # Remove binary and test database file
```
