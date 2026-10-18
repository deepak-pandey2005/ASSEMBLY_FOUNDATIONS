# Module 11: Network Programming — Raw Sockets & TCP/IP

## 🎯 Objectives
- Understand the Linux Socket API at the machine code level.
- Learn the Network Byte Order (**Big-Endian**) vs Host Byte Order (**Little-Endian**) translation using `bswap` and `rol/ror`.
- Understand TCP connection lifecycle:
  - `socket` (create endpoint) $\to$ `bind` (assign IP/port) $\to$ `listen` (queue) $\to$ `accept` (handshake) $\to$ `write`/`read` $\to$ `close`.
- Build a standalone HTTP/1.1 Web Server written entirely in 64-bit assembly without any external C runtime!

---

## 1. Network Byte Order (Big-Endian)

Internet standards require multi-byte numbers (like TCP port numbers and IPv4 addresses) to be transmitted in **Big-Endian** (most significant byte first).
Since x86 CPUs are Little-Endian, ports must be byte-swapped:

Port `8080` in hex is `0x1F90`:
- In Host x86 memory (Little-Endian): `0x90`, `0x1F`
- In Network packet (Big-Endian): `0x1F`, `0x90`

In assembly:
```nasm
mov ax, 8080
xchg al, ah        ; Swaps the two bytes into Network Byte Order!
```

---

## 2. Linux 64-bit Network Syscalls

Unlike 32-bit Linux, which routed network calls through `sys_socketcall` (syscall 102), **x86-64 Linux provides dedicated direct syscalls**:

| Function | Syscall Number (`RAX`) | Arguments (`RDI`, `RSI`, `RDX`, `R10`) |
|---|---|---|
| `socket` | **`41`** | `domain` (`AF_INET = 2`), `type` (`SOCK_STREAM = 1`), `protocol` (`0`) |
| `bind` | **`49`** | `sockfd`, `const struct sockaddr *addr`, `socklen_t addrlen` |
| `listen` | **`50`** | `sockfd`, `int backlog` (e.g. `10`) |
| `accept` | **`43`** | `sockfd`, `struct sockaddr *addr`, `socklen_t *addrlen` |
| `connect`| **`42`** | `sockfd`, `const struct sockaddr *addr`, `socklen_t addrlen` |

---

## 3. Hands-on Code Files in this Module
- [`tcp_webserver.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/11_socket_networking/tcp_webserver.asm) - Fully functional HTTP/1.1 micro-webserver on port 8080 with automated test client.
