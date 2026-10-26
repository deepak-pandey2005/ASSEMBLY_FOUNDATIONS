# Standalone Project 10: Pure x86-64 Assembly RFC 1035 DNS Resolver (`dns_client`)

A standalone, zero-dependency Domain Name System (DNS) client CLI written entirely in pure x86-64 NASM assembly. It crafts binary RFC 1035 query packets, communicates with public DNS resolvers (Google DNS `8.8.8.8:53`) over raw Linux UDP sockets, and decodes binary DNS response packets to extract resolved IPv4 addresses.

---

## 🎯 Architecture & Specifications

### 1. Zero-Dependency Networking
- Pure Linux system calls without `libc` or `libresolv`:
  - **`sys_socket`** (Syscall 41): Creates an `AF_INET` (2), `SOCK_DGRAM` (1), `IPPROTO_UDP` (17) socket descriptor.
  - **`sys_setsockopt`** (Syscall 54): Configures a 2-second receive timeout (`SO_RCVTIMEO` 20) using `struct timeval { 2, 0 }`.
  - **`sys_sendto`** (Syscall 44): Dispatches the binary query packet to `8.8.8.8:53`.
  - **`sys_recvfrom`** (Syscall 45): Receives the binary response packet from the upstream nameserver.
  - **`sys_close`** (Syscall 3): Closes the network socket descriptor.

### 2. RFC 1035 Packet Construction
- **12-Byte DNS Header**:
  - `ID`: `0x1337` (Transaction Identifier)
  - `Flags`: `0x0100` (Standard Query with Recursion Desired `RD=1`)
  - `QDCOUNT`: `0x0001` (1 Question)
  - `ANCOUNT`, `NSCOUNT`, `ARCOUNT`: `0x0000`
- **Question Section (QNAME)**:
  - Encodes human-readable domain names (e.g., `google.com`) into length-prefixed DNS label format (`\x06google\x03com\x00`).
  - Appends `QTYPE=0x0001` (Type A, Host Address) and `QCLASS=0x0001` (Class IN, Internet).

### 3. Binary Response Parser
- Validates the 12-byte header (Transaction ID match, `QR=1` response flag, `RCODE=0` no error).
- Extracts `ANCOUNT` (number of answer resource records).
- Skips the echo Question section.
- Traverses Answer Resource Records:
  - Handles RFC 1035 DNS compression pointers (`0xC0xx` 2-byte offsets).
  - Decodes record `TYPE` (Type A = 1), `CLASS` (IN = 1), `TTL` (32-bit big-endian time-to-live), and `RDLENGTH` (4 bytes for IPv4).
  - Formats the 4 raw IPv4 bytes into dotted-decimal notation (e.g. `142.250.190.46`).
- Automatic offline fallback: If UDP port 53 is blocked by a firewall or container network sandbox, automatically exercises and verifies the parser against an RFC 1035 packet test vector.

---

## 🚀 Building & Running

```bash
# Build the standalone binary
make

# Run DNS resolution on default target (google.com)
make run

# Resolve custom domains
./dns_client github.com
./dns_client wikipedia.org

# Clean build artifacts
make clean
```
