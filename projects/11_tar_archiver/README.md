# Standalone Project 11: Pure x86-64 Assembly POSIX tar Archiver & Extractor (`asm_tar`)

A standalone archive utility CLI written entirely in pure x86-64 NASM assembly with **zero external libraries or C runtime (`libc`) dependencies**. It implements the POSIX `ustar` (Unix Standard TAR) archive specification, allowing you to bundle files into uncompressed `.tar` archives, list archive records, and extract files with full GNU `tar` interoperability.

---

## 🎯 Architecture & Specifications

### 1. POSIX `ustar` 512-Byte Header Block
Each file inside the `.tar` archive begins with a 512-byte header block structured as follows:

| Offset | Field | Length | Description |
|---|---|---|---|
| `0` | `name` | 100 bytes | Null-terminated file path |
| `100` | `mode` | 8 bytes | File permission mode in octal ASCII (e.g., `0000644\0`) |
| `108` | `uid` | 8 bytes | User ID in octal ASCII (`0001000\0`) |
| `116` | `gid` | 8 bytes | Group ID in octal ASCII (`0001000\0`) |
| `124` | `size` | 12 bytes | File size in octal ASCII (`00000000123\0`) |
| `136` | `mtime` | 12 bytes | Last modification timestamp in octal ASCII |
| `148` | `chksum` | 8 bytes | Header checksum (sum of all 512 bytes with spaces placeholder) |
| `156` | `typeflag` | 1 byte | File type flag (`'0'` = regular file) |
| `157` | `linkname` | 100 bytes | Target name of link (zeroed) |
| `257` | `magic` | 6 bytes | POSIX magic signature (`"ustar\0"`) |
| `263` | `version` | 2 bytes | POSIX version (`"00"`) |
| `265` | `uname` | 32 bytes | Owner user name (`"user\0"`) |
| `297` | `gname` | 32 bytes | Owner group name (`"user\0"`) |

### 2. Header Checksum Algorithm
- The checksum field (offset 148, 8 bytes) is filled with 8 ASCII space characters (`0x20`).
- The 512 header bytes are summed as unsigned characters into an unsigned accumulator.
- The resulting integer is formatted as a 6-digit octal ASCII string followed by a null byte and a space (e.g., `"012345\0 "`).

### 3. Payload Alignment & EOF Padding
- File contents immediately follow the header block.
- If the file size is not a multiple of 512 bytes, null padding bytes are appended to align the stream to the next 512-byte boundary:
  $$\text{padding} = (512 - (\text{size} \pmod{512})) \pmod{512}$$
- The archive is terminated with two consecutive 512-byte zero blocks (1,024 null bytes) marking the end of the archive (EOF).

---

## 🚀 Building & Testing

```bash
# Build the standalone binary
make

# Create an archive with sample files
./asm_tar create my_bundle.tar file1.txt file2.txt

# List archive contents
./asm_tar list my_bundle.tar

# Verify with standard Linux GNU tar
tar -tvf my_bundle.tar

# Extract archive contents
./asm_tar extract my_bundle.tar

# Run automated end-to-end test suite
make test

# Clean build artifacts
make clean
```
