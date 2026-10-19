# Project 02: Multi-Client HTTP Server Daemon (Pure x86-64 Assembly)

A standalone, concurrent HTTP/1.1 Web Server Daemon written entirely in x86-64 assembly without libc, linking, or runtime overhead.

---

## 🌐 Architecture & Features
- **TCP Socket Lifecycle**:
  - `sys_socket` (41) $\to$ `sys_setsockopt` (`SO_REUSEADDR`) $\to$ `sys_bind` (49) $\to$ `sys_listen` (50) $\to$ `sys_accept` (43).
- **Concurrency via Multiprocessing**:
  - When a client connects, the master daemon invokes `sys_fork` (57).
  - The child process handles HTTP request parsing, routing, and response transmission, then exits cleanly.
  - The parent daemon continues listening for new connections without blocking!
- **HTTP Routing**:
  - `/` or `/index.html` $\to$ Returns styled 200 OK HTML dashboard.
  - `/api/status` $\to$ Returns JSON payload `{"status":"online","arch":"x86_64"}`.
  - Any unknown URL $\to$ Returns clean 404 Not Found response.
- **Signal Handling & Process Reaper**:
  - Reaps zombie child processes using `sys_wait4` with `WNOHANG`.

---

## 🛠️ Build and Run

```bash
# Build the server daemon
make

# Run the server on port 8080
make run

# In another terminal:
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/api/status
curl http://127.0.0.1:8080/unknown

# Clean binaries
make clean
```
