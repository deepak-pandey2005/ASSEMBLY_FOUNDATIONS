# Assembly Foundations: Complete Roadmap & Curriculum

Welcome to **Assembly Foundations**! This roadmap bridges high-level software engineering and bare-metal machine execution. It takes you across **38 progressive modules** and **10 standalone real-world projects** from basic arithmetic and CPU registers to operating system internals, raw socket networking, pixel rendering, data serialization, AVX2 vectorization, hardware atomics, FFI interop, binary security, hardware telemetry, signals, x87 FPU math, terminal UI, minimal ELF golfing, kernel high-resolution timers, high-concurrency event-driven `epoll` architecture, Linux Seccomp syscall sandboxing, raw `sys_clone` multithreading, hardware virtualization detection, custom heap allocation, persistent memory-mapped databases, hardware port I/O, Linux futex low-latency mutexes, streaming JSON parsing, kernel inotify file monitoring, pure assembly CHIP-8 CPU emulation, kernel hardware performance monitoring counters (`perf_event_open`), RFC 1035 UDP DNS resolution, and modern Linux `io_uring` asynchronous I/O.

---

## 🗺️ Complete 30-Module Curriculum Matrix

### Part I: Core Architecture & Assembly Language Fundamentals

| Module | Title | Primary Syntax | Key Concepts | Verified Programs |
|---|---|---|---|---|
| **01** | [Fundamentals & Architecture](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/README.md) | NASM 64-bit | CPU instruction cycle, Little-Endian byte order, ELF format | [`hello_64.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/hello_64.asm), [`minimal_exit.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/minimal_exit.asm) |
| **02** | [Registers & Memory Addressing](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/README.md) | Intel & AT&T | 8/16/32/64-bit subregisters, zero-extension gotcha, `.data` vs `.bss` vs `.rodata`, `Base + Index*Scale + Disp` | [`addressing_modes.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/addressing_modes.asm), [`data_sections.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/data_sections.asm) |
| **03** | [Arithmetic & Bitwise Logic](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/README.md) | NASM 64-bit | `ADC`, `SBB`, `IMUL`, `IDIV`, `SHL`, `SAR`, CPU RFLAGS (`ZF`, `CF`, `OF`, `SF`) | [`arithmetic.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/arithmetic.asm), [`bitwise.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/bitwise.asm) |
| **04** | [Control Flow & Branching](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/README.md) | NASM 64-bit | `CMP`, `TEST`, signed (`JG`/`JL`) vs unsigned (`JA`/`JB`) conditional jumps, `if-else` chains, `for`/`while` loops | [`branches.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/branches.asm), [`loop_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/loop_sum.asm) |
| **05** | [Call Stack & Functions (ABI)](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/README.md) | NASM 64-bit | System V AMD64 ABI, register arguments, stack frames, 16-byte alignment | [`function_call.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/function_call.asm), [`stack_frame.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/stack_frame.asm) |
| **06** | [Linux System Calls](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/README.md) | 64-bit vs 32-bit | `syscall` vs `int 0x80`, file descriptors, reading stdin, writing stdout/stderr, opening/closing files on disk | [`user_input.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/user_input.asm), [`cat_file.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/cat_file.asm) |
| **07** | [Strings & Memory Blocks](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/README.md) | NASM 64-bit | `MOVSB`, `STOSB`, `SCASB`, `REP` prefix, direction flag (`CLD`/`STD`), string reverse | [`strlen_reverse.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/strlen_reverse.asm), [`array_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/array_sum.asm) |
| **08** | [Debugging with GDB](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/08_debugging_with_gdb/README.md) | GDB TUI | Step instructions (`si`, `ni`), examine memory `x/gx`, register inspection | [`debug_target.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/08_debugging_with_gdb/debug_target.asm) |

---

### Part II: Systems Programming, Networking, Graphics & Protocols

| Module | Title | Primary Focus | Key Concepts | Verified Programs |
|---|---|---|---|---|
| **09** | [Virtual Memory & `mmap`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/09_memory_management_mmap/README.md) | OS Memory Subsystem | Page tables, 4KB pages, MMU, `sys_mmap` (9), `sys_munmap` (11), custom allocator | [`mmap_allocator.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/09_memory_management_mmap/mmap_allocator.asm) |
| **10** | [Processes & IPC](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/10_process_and_ipc/README.md) | OS Multitasking | `sys_fork` (57), copy-on-write, kernel pipe rings (`sys_pipe`), `sys_wait4` | [`fork_pipe_ipc.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/10_process_and_ipc/fork_pipe_ipc.asm) |
| **11** | [Raw Sockets & TCP/IP](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/11_socket_networking/README.md) | Systems Networking | Big-Endian byte swap (`htons`), socket lifecycle: `socket`(41) $\to$ `bind`(49) $\to$ `listen`(50) $\to$ `accept`(43) $\to$ `write`/`close`, pure assembly HTTP web server | [`tcp_webserver.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/11_socket_networking/tcp_webserver.asm) |
| **12** | [Framebuffer & Graphics](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/12_framebuffer_and_graphics/README.md) | Low-Level Graphics | Linear framebuffer coordinates `(Y * Width + X) * BPP`, 24-bit RGB pixel buffer, Netpbm PPM renderer | [`render_pattern.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/12_framebuffer_and_graphics/render_pattern.asm) |
| **13** | [Data Encoding & Protocols](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/13_file_transfer_protocols/README.md) | Protocol Serialization | Binary serialization across text protocols, 3-byte to 4-char 6-bit Base64 packing | [`base64_encoder.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/13_file_transfer_protocols/base64_encoder.asm) |
| **14** | [Bare-Metal OS & Bootloader](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/14_baremetal_os_bootloader/README.md) | Kernel / Bare-Metal | Real Mode (16-bit `CS:IP`), BIOS boot sequence, 512-byte MBR sector, `0xAA55` magic signature, BIOS Teletype `int 0x10` | [`bootloader.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/14_baremetal_os_bootloader/bootloader.asm) |

---

### Part III: High-Performance Computing, Security & Hardware Internals

| Module | Title | Primary Focus | Key Concepts | Verified Programs |
|---|---|---|---|---|
| **15** | [SIMD & AVX2 Vectorization](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/15_simd_avx_vectorization/README.md) | Vector Math | 256-bit `YMM` registers, packed integer addition (`vpaddd`), `vmovdqu`, `vzeroupper` | [`avx2_vector_add.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/15_simd_avx_vectorization/avx2_vector_add.asm) |
| **16** | [Concurrency & Hardware Atomics](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/16_concurrency_and_atomics/README.md) | Multi-Core Hardware | Cache lines, bus locking, `LOCK CMPXCHG` (CAS), `LOCK XADD`, hardware spinlocks | [`atomic_spinlock.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/16_concurrency_and_atomics/atomic_spinlock.asm) |
| **17** | [C & Python FFI Interoperability](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/README.md) | Cross-Language FFI | Dynamic shared objects (`.so`), calling assembly math kernels from C and Python (`ctypes`) | [`asm_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/asm_math.asm), [`test_c.c`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_c.c), [`test_py.py`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_py.py) |
| **18** | [Cryptography & Hashing](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/18_cryptography_and_hashing/README.md) | Crypto Primitives | DJB2 hash algorithm, bit shift-and-add (`hash * 33 ^ char`), 64-bit hex formatter | [`hash_algorithms.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/18_cryptography_and_hashing/hash_algorithms.asm) |
| **19** | [ELF Internals & Linkers](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/19_elf_internals_and_linking/README.md) | Binary Structure | `Elf64_Ehdr`, `0x7F 'E' 'L' 'F'`, program segments (`PT_LOAD`), self-inspection via `/proc/self/exe` | [`elf_inspector.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/19_elf_internals_and_linking/elf_inspector.asm) |
| **20** | [Cross-Architecture (ARM64 & RISC-V)](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/README.md) | Multi-Architecture | CISC vs RISC, fixed 32-bit instructions, register comparisons (`X0`..`X30`, `A0`..`A7`), `svc #0` vs `ecall` | [`arm64_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/arm64_sample.s), [`riscv_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/riscv_sample.s) |
| **21** | [Audio & Sound Synthesis](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/21_audio_and_sound_synthesis/README.md) | Digital Signal Proc | 44-byte RIFF/WAVE header, 8kHz 8-bit unsigned PCM synthesis, 440Hz concert pitch square wave | [`synth_audio.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/21_audio_and_sound_synthesis/synth_audio.asm) |
| **22** | [Binary Security & Anti-Debugging](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/22_binary_security_foundations/README.md) | Security Research | Position-Independent Code (PIC), stack string injection, anti-debugging via `sys_ptrace` (101) | [`shellcode_demo.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/22_binary_security_foundations/shellcode_demo.asm) |

---

### Part IV: Hardware Telemetry, OS Signals, Math & Systems Mastery

| Module | Title | Primary Focus | Key Concepts | Verified Programs |
|---|---|---|---|---|
| **23** | [CPU Telemetry & Benchmarking](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/23_cpu_telemetry_and_benchmarking/README.md) | Hardware Telemetry | `CPUID` vendor string extraction (`GenuineIntel`/`AuthenticAMD`), `RDTSC`/`RDTSCP` cycle latency benchmarking | [`cpu_telemetry.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/23_cpu_telemetry_and_benchmarking/cpu_telemetry.asm) |
| **24** | [Linux Signals & Exceptions](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/24_linux_signals_and_exceptions/README.md) | OS Interrupts | Asynchronous signals, `sys_rt_sigaction` (13), signal context, `sys_rt_sigreturn` (15) trampoline | [`signal_handler.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/24_linux_signals_and_exceptions/signal_handler.asm) |
| **25** | [x87 FPU Floating-Point Math](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/25_x87_fpu_floating_point/README.md) | FPU Stack | 80-bit IEEE-754 precision, `ST(0)` stack, `fsqrt`, `fldpi`, `fsin`, fixed-point ASCII formatting | [`fpu_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/25_x87_fpu_floating_point/fpu_math.asm) |
| **26** | [Terminal Graphics & Raw I/O](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/26_terminal_graphics_and_raw_io/README.md) | Direct TTY Control | Canonical vs raw terminal mode, ANSI escape sequences (colors, cursor positioning, screen clears) | [`ansi_canvas.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/26_terminal_graphics_and_raw_io/ansi_canvas.asm) |
| **27** | [Minimalist ELF Golfing](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/27_minimal_elf_golfing/README.md) | Binary Optimization | Handcrafted 127-byte executable, raw `nasm -f bin`, ELF header + Program header overlap, zero compiler bloat | [`tiny_golf.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/27_minimal_elf_golfing/tiny_golf.asm) |
| **28** | [Kernel Timers & Nanosleep](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/28_kernel_timers_and_nanosleep/README.md) | OS Scheduling | Scheduler yielding vs busy spinning, `struct timespec` (sec & nsec), `sys_nanosleep` (35) | [`precise_sleep.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/28_kernel_timers_and_nanosleep/precise_sleep.asm) |
| **29** | [High-Concurrency `epoll` I/O](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/29_epoll_asynchronous_io/README.md) | Event-Driven Async I/O | $O(1)$ event notifications, `sys_epoll_create1` (291), `sys_epoll_ctl` (233), `sys_epoll_wait` (232), non-blocking TCP | [`epoll_server.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/29_epoll_asynchronous_io/epoll_server.asm) |
| **30** | [Linux Seccomp Sandboxing](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/30_linux_seccomp_bpf_sandbox/README.md) | Kernel Security | Process privilege restriction, `sys_prctl` (157), `PR_SET_NO_NEW_PRIVS`, `PR_SET_SECCOMP`, Strict Seccomp mode | [`seccomp_sandbox.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/30_linux_seccomp_bpf_sandbox/seccomp_sandbox.asm) |
| **31** | [Native Multithreading with Raw `sys_clone`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/31_multithreading_raw_clone/README.md) | OS Concurrency | Kernel threads, `sys_clone` (56), `CLONE_VM`, top-of-stack alignment via `mmap`, atomic coordination | [`raw_threads.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/31_multithreading_raw_clone/raw_threads.asm) |
| **32** | [Hardware Virtualization & Hypervisor Detection](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/32_hardware_virtualization_detection/README.md) | CPU Internals | Hypervisor present bit (`CPUID.1:ECX[31]`), signature extraction (`0x40000000`), Intel VT-x (`VMX`) & AMD-V (`SVM`) | [`vm_detect.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/32_hardware_virtualization_detection/vm_detect.asm) |
| **33** | [Custom Heap Allocator with `sys_brk`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/33_heap_allocator_sys_brk/README.md) | Memory Internals | Process program break (`sys_brk` 12), chunk metadata headers (size, free flag, next), `asm_malloc`, `asm_free`, block reuse | [`heap_allocator.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/33_heap_allocator_sys_brk/heap_allocator.asm) |
| **34** | [Hardware Port I/O & CMOS RTC](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/34_hardware_port_io_cmos_rtc/README.md) | Hardware I/O Ports | Dedicated 16-bit PMIO port space, `IN`/`OUT`, `sys_ioperm` (173), CMOS ports `0x70`/`0x71`, BCD hardware decoding | [`cmos_rtc.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/34_hardware_port_io_cmos_rtc/cmos_rtc.asm) |
| **35** | [Linux Futex Low-Latency Mutex](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/35_linux_futex_low_latency_mutex/README.md) | OS Synchronization | `sys_futex` (202), `FUTEX_WAIT`, `FUTEX_WAKE`, atomic fast-path (0 syscalls), kernel wait queue sleep | [`futex_mutex.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/35_linux_futex_low_latency_mutex/futex_mutex.asm) |
| **36** | [Linux Kernel Inotify File-System Watcher](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/36_inotify_file_system_watcher/README.md) | OS Event Subsystem | `sys_inotify_init1` (294), `sys_inotify_add_watch` (254), `IN_CREATE`, binary `struct inotify_event` parsing | [`inotify_watcher.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/36_inotify_file_system_watcher/inotify_watcher.asm) |
| **37** | [Linux Kernel Hardware Performance Counters](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/37_kernel_hardware_performance_counters/README.md) | Hardware PMU Subsystem | `sys_perf_event_open` (298), hardware CPU cycles, instructions retired, Instructions-Per-Cycle (IPC), `sys_ioctl` control | [`perf_counters.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/37_kernel_hardware_performance_counters/perf_counters.asm) |
| **38** | [Modern Linux `io_uring` Asynchronous I/O](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/38_linux_io_uring_async_io/README.md) | High-Performance Async I/O | `sys_io_uring_setup` (425), `sys_io_uring_enter` (426), memory-mapped SQ/CQ rings, `IORING_OP_NOP`, async `IORING_OP_WRITE` | [`io_uring_demo.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/38_linux_io_uring_async_io/io_uring_demo.asm) |

---

## 🏛️ Standalone Real-World Projects Matrix

| Project | Name & Directory | Domain | Key Architecture & Sycalls |
|---|---|---|---|
| **01** | [Interactive Snake Game](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/01_interactive_snake_game/README.md) | Terminal Game Engine | Raw terminal non-canonical I/O, ANSI escape sequences, `termios`, `sys_nanosleep` |
| **02** | [HTTP Server Daemon](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/02_http_server_daemon/README.md) | Network Systems | Raw TCP sockets (`AF_INET`, `SOCK_STREAM`), `sys_bind`, `sys_listen`, `sys_accept`, HTTP/1.1 response streaming |
| **03** | [WAV Audio Generator](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/03_wav_audio_generator/README.md) | Digital Signal Processing | 44-byte RIFF/WAV header generation, dual-frequency sine wave synth, 16-bit PCM |
| **04** | [Raytracer PPM](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/04_raytracer_ppm/README.md) | Computer Graphics | 3D ray-sphere intersection, 80-bit x87 FPU vector math, Lambertian diffuse shading, PPM image output |
| **05** | [Base64 File Converter](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/05_base64_file_converter/README.md) | Systems Tooling | RFC 4648 bit-packing engine, 3-byte to 4-char encoding, file streaming I/O |
| **06** | [SHA-256 Hasher](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/06_sha256_hasher/README.md) | Cryptography | NIST FIPS 180-4 standard cryptographic hash algorithm, 64-round compression, big-endian message schedule |
| **07** | [Memory-Mapped Key-Value Store](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/07_mmap_key_value_store/README.md) | Database Internals | Zero-copy binary key-value engine, `sys_mmap` (`MAP_SHARED`), `sys_msync`, binary record indexing |
| **08** | [Streaming JSON Parser](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/08_json_parser/README.md) | Data Serialization | RFC 8259 streaming tokenizer/lexer, scalar/string parser, zero-copy key lookup |
| **09** | [CHIP-8 Virtual Machine](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/09_chip8_emulator/README.md) | Virtualization & Emulation | Full 4KB RAM, 16 registers, font sprites, 64x32 display rendering, opcode decoder & runner |
| **10** | [RFC 1035 DNS Resolver](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/10_dns_client/README.md) | Internet Protocols | Raw UDP sockets (`SOCK_DGRAM`), binary DNS header/QNAME encoding, compression pointer parsing, IPv4 address resolution |

---

## 🛠️ Automated Testing & Build

```bash
make all          # Compiles and links all 38 tutorial programs and 10 standalone projects
make test         # Runs automated unit tests for all modules and projects
make test-epoll   # Tests the asynchronous epoll event-driven server
make test-network # Boots pure assembly HTTP server and curls it via localhost
make clean        # Cleans binaries, objects, and generated sound/image artifacts
```






