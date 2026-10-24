# Module 29: High-Concurrency Asynchronous Networking with `epoll`

## 🎯 Objectives
- Understand the **C10K problem** and why traditional blocking I/O (and even `select` / `poll`) fail under high load:
  - $O(N)$ scanning vs $O(1)$ kernel event readiness.
- Master the Linux `epoll` subsystem and its three primary syscalls:
  - **`sys_epoll_create1`** (syscall 291): Creates an in-kernel event poll instance (red-black tree + ready list).
  - **`sys_epoll_ctl`** (syscall 233): Registers, modifies, or deletes monitored file descriptors.
  - **`sys_epoll_wait`** (syscall 232): Suspends thread until one or more monitored descriptors become ready for I/O.
- Learn **Non-Blocking I/O** via `sys_fcntl` (syscall 72) with `O_NONBLOCK` (`0x800`).
- Understand **Edge-Triggered (`EPOLLET`) vs Level-Triggered** notification models.
- Build an asynchronous event-driven TCP server in pure x86-64 assembly that services multiple clients concurrently on a single CPU thread without spawning threads or processes!

---

## 1. The Evolution of I/O Multiplexing

| Model | Mechanism | Complexity | Drawback |
|---|---|---|---|
| **Blocking Multi-Process/Thread** | 1 process/thread per connection | $O(1)$ per thread | Enormous memory & context-switch overhead |
| **`select` / `poll`** | Passes array of FDs to kernel on every call | $O(N)$ linear scan | Re-evaluates entire FD array even if only 1 is active |
| **Linux `epoll`** | Kernel maintains an internal Red-Black tree & ready list | **$O(1)$ event-driven** | Kernel only wakes up thread with ready FDs! |

---

## 2. Anatomy of `struct epoll_event` on x86-64

On 64-bit Linux, `struct epoll_event` is packed into **12 bytes** (or 16 bytes with alignment):

```text
struct epoll_event {
    uint32_t     events;   // 4 bytes: EPOLLIN (0x01), EPOLLOUT (0x04), EPOLLET (0x80000000)
    epoll_data_t data;     // 8 bytes: union (normally holds user FD or pointer)
} __attribute__((packed));
```

### Essential Syscall Numbers:
- `epoll_create1`: **`291`**
- `epoll_ctl`: **`233`** (Operations: `EPOLL_CTL_ADD = 1`, `EPOLL_CTL_DEL = 2`, `EPOLL_CTL_MOD = 3`)
- `epoll_wait`: **`232`**

---

## 3. The Asynchronous Event Loop Pattern

```text
[ sys_epoll_create1 ]
        ↓
[ sys_epoll_ctl(ADD, listen_fd, EPOLLIN) ]
        ↓
┌───► [ sys_epoll_wait(...) ] ◄─── Suspends until kernel notifies ready FDs!
│           ↓
│     For each ready event in array:
│       ├─ If FD == listen_fd:
│       │    └─ sys_accept() new client FD
│       │    └─ Set client FD to O_NONBLOCK
│       │    └─ sys_epoll_ctl(ADD, client_fd, EPOLLIN)
│       │
│       └─ If FD == client_fd:
│            └─ sys_read() request
│            └─ sys_write() response
│            └─ If client disconnected: sys_close() & sys_epoll_ctl(DEL)
└─── Repeat Loop
```

---

## 4. Hands-on Code Files in this Module
- [`epoll_server.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/29_epoll_asynchronous_io/epoll_server.asm) - Complete event-driven asynchronous TCP echo server handling concurrent connections on a single thread.
