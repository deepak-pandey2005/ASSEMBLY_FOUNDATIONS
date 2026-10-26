# Assembly Foundations 🏛️⚡

> A comprehensive, hands-on, step-by-step tutorial curriculum, low-level systems reference library, and full-scale real-world project suite covering x86 and x86-64 assembly, Linux OS internals, raw TCP networking, pixel graphics, data encoding, bare-metal OS bootloaders, AVX2 SIMD vectorization, hardware atomics, C/Python FFI interop, cryptography, ELF internals, audio synthesis, binary security, CPU telemetry, signal handling, x87 FPU math, ANSI terminal control, ELF golfing, kernel high-resolution timers, high-concurrency event-driven `epoll` architecture, and Linux Seccomp syscall sandboxing.

---

## 🚀 Quick Start

Build and test all 36 guided modules and 8 standalone projects with a single command:

```bash
# Clone and enter the workspace
cd ASSEMBLY_FOUNDATIONS

# Build all 36 tutorial programs and 8 standalone projects
make all

# Run the automated verification test suite across everything
make test

# Test the high-concurrency epoll async server
make test-epoll

# Test the pure assembly HTTP web server daemon
make test-network
```

Inspect any binary in GDB with Intel disassembly layout:
```bash
make debug
```

---

## 🏗️ Standalone Assembly Projects

These are complete, full-scale applications written entirely in x86-64 assembly with **zero external C runtime** dependencies. Each project has its own dedicated directory, documentation, and independent `Makefile`:

| Project | Name & Directory | Key Features | Standalone Build |
|---|---|---|---|
| **01** | [**Interactive Terminal Snake Game**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/01_interactive_snake_game/README.md) | Non-canonical unbuffered raw terminal I/O via `sys_ioctl`, ANSI color engine, circular snake segment tracking, real-time keyboard handling (`W`/`A`/`S`/`D`), food collision, wall collisions | `cd projects/01_interactive_snake_game && make && ./snake` |
| **02** | [**HTTP/1.1 Server Daemon**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/02_http_server_daemon/README.md) | Multi-route web server (`/`, `/api/status`, 404), `SO_REUSEADDR` socket options, HTTP request header parsing, JSON and HTML response streaming | `cd projects/02_http_server_daemon && make test` |
| **03** | [**Polyphonic WAV Synthesizer**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/03_wav_audio_generator/README.md) | 44-byte dynamic RIFF/WAVE header generator, 44.1kHz 16-bit stereo PCM audio engine, dual-tone harmonic chord synthesis with ADSR exponential amplitude decay envelope | `cd projects/03_wav_audio_generator && make run` |
| **04** | [**3D Sphere Raytracer**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/04_raytracer_ppm/README.md) | Mathematical primary ray generation, vector dot products, quadratic ray-sphere intersection solver, Lambertian diffuse surface lighting with directional light source, Netpbm PPM renderer | `cd projects/04_raytracer_ppm && make run` |
| **05** | [**Streaming Base64 CLI Converter**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/05_base64_file_converter/README.md) | Streaming 4KB block disk buffer I/O, 24-bit to 4x6-bit Base64 bit alignment, automated MIME 76-column line-wrapping, tail padding (`=`/`==`) | `cd projects/05_base64_file_converter && make test` |
| **06** | [**SHA-256 Cryptographic Hasher CLI**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/06_sha256_hasher/README.md) | FIPS 180-4 standard, 64-round constants, message schedule expansion ($W_0 \dots W_{63}$), compression loop, NIST test vector verified | `cd projects/06_sha256_hasher && make test` |
| **07** | [**Memory-Mapped Persistent KV Store**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/07_mmap_key_value_store/README.md) | Disk-persistent binary table engine via `sys_open`, `sys_ftruncate`, `sys_mmap` (`MAP_SHARED`), and `sys_msync`; `set`, `get`, and `dump` | `cd projects/07_mmap_key_value_store && make test` |
| **08** | [**Streaming JSON Lexer & Parser**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/projects/08_json_parser/README.md) | RFC 8259-compliant zero-copy tokenization, string/integer/boolean literal parsing, object key search & AST field extraction | `cd projects/08_json_parser && make test` |

---

## 🗺️ Step-by-Step Curriculum (30 Modules)

### Part I: Core Architecture & Assembly Language Fundamentals

| Module | Topic | Core Takeaways | Code Examples |
|---|---|---|---|
| **01** | [**Fundamentals & Architecture**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/README.md) | CPU instruction cycle, Little-Endian byte order, ELF binaries, first 64-bit exit | [`hello_64.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/hello_64.asm), [`minimal_exit.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/01_fundamentals/minimal_exit.asm) |
| **02** | [**Registers & Memory Addressing**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/README.md) | 8/16/32/64-bit subregisters, zero-extension gotcha, `.data` vs `.bss` vs `.rodata`, Base+Index*Scale+Disp addressing | [`addressing_modes.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/addressing_modes.asm), [`data_sections.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/02_registers_and_memory/data_sections.asm) |
| **03** | [**Arithmetic & Bitwise Logic**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/README.md) | Addition with carry (`ADC`), signed vs unsigned multiply/divide (`IMUL`/`IDIV`), RFLAGS register (`ZF`, `CF`, `OF`, `SF`) | [`arithmetic.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/arithmetic.asm), [`bitwise.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/03_arithmetic_and_logic/bitwise.asm) |
| **04** | [**Control Flow & Branching**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/README.md) | `CMP`, `TEST`, signed (`JG`/`JL`) vs unsigned (`JA`/`JB`) conditional jumps, `if-else` chains, `for`/`while` loops | [`branches.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/branches.asm), [`loop_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/04_control_flow/loop_sum.asm) |
| **05** | [**Call Stack & Functions (ABI)**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/README.md) | System V AMD64 ABI, register argument passing order, callee-saved registers, stack frames (`RBP`/`RSP`), 16-byte alignment | [`function_call.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/function_call.asm), [`stack_frame.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/05_stack_and_functions/stack_frame.asm) |
| **06** | [**Linux System Calls**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/README.md) | 64-bit `syscall` vs 32-bit `int 0x80`, file descriptors, reading stdin, writing stdout/stderr, opening/closing files on disk | [`user_input.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/user_input.asm), [`cat_file.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/06_system_calls/cat_file.asm) |
| **07** | [**Strings & Memory Blocks**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/README.md) | Hardware string operations (`MOVSB`, `STOSB`, `SCASB`), `REP` prefix, direction flag (`CLD`/`STD`), in-place string reversal | [`strlen_reverse.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/strlen_reverse.asm), [`array_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/array_sum.asm) |
| **08** | [**Debugging with GDB**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/08_debugging_with_gdb/README.md) | GDB TUI assembly layout, single-stepping instructions (`si`/`ni`), inspecting CPU registers and flags, examining memory (`x/gx`) | [`debug_target.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/08_debugging_with_gdb/debug_target.asm) |

---

### Part II: Systems Programming, Networking, Graphics & Protocols

| Module | Topic | Core Takeaways | Code Examples |
|---|---|---|---|
| **09** | [**Virtual Memory & `mmap`**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/09_memory_management_mmap/README.md) | 4KB virtual pages, MMU translation, page protection, raw anonymous `sys_mmap` (9) and `sys_munmap` (11) custom allocator | [`mmap_allocator.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/09_memory_management_mmap/mmap_allocator.asm) |
| **10** | [**Processes & IPC**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/10_process_and_ipc/README.md) | Multitasking, process cloning (`sys_fork` 57), Copy-on-Write, kernel pipe buffer ring (`sys_pipe` 22), parent-child synchronization (`sys_wait4` 61) | [`fork_pipe_ipc.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/10_process_and_ipc/fork_pipe_ipc.asm) |
| **11** | [**Raw Sockets & TCP/IP Networking**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/11_socket_networking/README.md) | Network Big-Endian byte swap (`htons`), socket lifecycle: `socket`(41) $\to$ `bind`(49) $\to$ `listen`(50) $\to$ `accept`(43) $\to$ `write`/`close`, HTTP/1.1 response streaming | [`tcp_webserver.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/11_socket_networking/tcp_webserver.asm) |
| **12** | [**Framebuffer & Graphics**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/12_framebuffer_and_graphics/README.md) | Linear VRAM buffer mapping, pixel address math $(Y \times \text{Width} + X) \times \text{BPP}$, raw 24-bit RGB rasterizer, Netpbm PPM graphics generator | [`render_pattern.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/12_framebuffer_and_graphics/render_pattern.asm) |
| **13** | [**Data Encoding & Protocols**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/13_file_transfer_protocols/README.md) | Binary-to-ASCII serialization for network transmission, 24-bit to 4x6-bit Base64 encoding with padding handling | [`base64_encoder.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/13_file_transfer_protocols/base64_encoder.asm) |
| **14** | [**Bare-Metal OS & Bootloader**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/14_baremetal_os_bootloader/README.md) | x86 power-on sequence, 16-bit Real Mode (`CS:IP`), BIOS boot sector at `0x7C00`, `0xAA55` magic signature, BIOS Teletype `int 0x10`, hardware halt | [`bootloader.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/14_baremetal_os_bootloader/bootloader.asm) |

---

### Part III: High-Performance Computing, Security & Hardware Internals

| Module | Topic | Core Takeaways | Code Examples |
|---|---|---|---|
| **15** | [**SIMD & AVX2 Vectorization**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/15_simd_avx_vectorization/README.md) | Vector Math, 256-bit `YMM` registers, packed integer addition (`vpaddd`), `vmovdqu`, `vzeroupper` | [`avx2_vector_add.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/15_simd_avx_vectorization/avx2_vector_add.asm) |
| **16** | [**Concurrency & Hardware Atomics**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/16_concurrency_and_atomics/README.md) | Multi-Core Hardware, cache lines, bus locking, `LOCK CMPXCHG` (CAS), `LOCK XADD`, hardware spinlocks | [`atomic_spinlock.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/16_concurrency_and_atomics/atomic_spinlock.asm) |
| **17** | [**C & Python FFI Interoperability**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/README.md) | Cross-Language FFI, dynamic shared objects (`.so`), calling assembly math kernels from C and Python (`ctypes`) | [`asm_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/asm_math.asm), [`test_c.c`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_c.c), [`test_py.py`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_py.py) |
| **18** | [**Cryptography & Hashing**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/18_cryptography_and_hashing/README.md) | Crypto Primitives, DJB2 hash algorithm, bit shift-and-add (`hash * 33 ^ char`), 64-bit hex formatter | [`hash_algorithms.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/18_cryptography_and_hashing/hash_algorithms.asm) |
| **19** | [**ELF Internals & Linkers**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/19_elf_internals_and_linking/README.md) | Binary Structure, `Elf64_Ehdr`, `0x7F 'E' 'L' 'F'`, program segments (`PT_LOAD`), self-inspection via `/proc/self/exe` | [`elf_inspector.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/19_elf_internals_and_linking/elf_inspector.asm) |
| **20** | [**Cross-Architecture (ARM64 & RISC-V)**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/README.md) | Multi-Architecture, CISC vs RISC, fixed 32-bit instructions, register comparisons (`X0`..`X30`, `A0`..`A7`), `svc #0` vs `ecall` | [`arm64_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/arm64_sample.s), [`riscv_sample.s`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/20_arm64_and_riscv_cross_arch/riscv_sample.s) |
| **21** | [**Audio & Sound Synthesis**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/21_audio_and_sound_synthesis/README.md) | Digital Signal Proc, 44-byte RIFF/WAVE header, 8kHz 8-bit unsigned PCM synthesis, 440Hz concert pitch square wave | [`synth_audio.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/21_audio_and_sound_synthesis/synth_audio.asm) |
| **22** | [**Binary Security & Anti-Debugging**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/22_binary_security_foundations/README.md) | Security Research, Position-Independent Code (PIC), stack string injection, anti-debugging via `sys_ptrace` (101) | [`shellcode_demo.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/22_binary_security_foundations/shellcode_demo.asm) |

---

### Part IV: Hardware Telemetry, OS Signals, Math & Systems Mastery

| Module | Topic | Core Takeaways | Code Examples |
|---|---|---|---|
| **23** | [**CPU Telemetry & Benchmarking**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/23_cpu_telemetry_and_benchmarking/README.md) | Hardware Telemetry, `CPUID` vendor string extraction (`GenuineIntel`/`AuthenticAMD`), `RDTSC`/`RDTSCP` cycle latency benchmarking | [`cpu_telemetry.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/23_cpu_telemetry_and_benchmarking/cpu_telemetry.asm) |
| **24** | [**Linux Signals & Exceptions**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/24_linux_signals_and_exceptions/README.md) | OS Interrupts, asynchronous signals, `sys_rt_sigaction` (13), signal context, `sys_rt_sigreturn` (15) trampoline | [`signal_handler.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/24_linux_signals_and_exceptions/signal_handler.asm) |
| **25** | [**x87 FPU Floating-Point Math**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/25_x87_fpu_floating_point/README.md) | FPU Stack, 80-bit IEEE-754 precision, `ST(0)` stack, `fsqrt`, `fldpi`, `fsin`, fixed-point ASCII formatting | [`fpu_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/25_x87_fpu_floating_point/fpu_math.asm) |
| **26** | [**Terminal Graphics & Raw I/O**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/26_terminal_graphics_and_raw_io/README.md) | Direct TTY Control, canonical vs raw terminal mode, ANSI escape sequences (colors, cursor positioning, screen clears) | [`ansi_canvas.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/26_terminal_graphics_and_raw_io/ansi_canvas.asm) |
| **27** | [**Minimalist ELF Golfing**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/27_minimal_elf_golfing/README.md) | Binary Optimization, handcrafted 127-byte executable, raw `nasm -f bin`, ELF header + Program header overlap, zero compiler bloat | [`tiny_golf.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/27_minimal_elf_golfing/tiny_golf.asm) |
| **28** | [**Kernel Timers & Nanosleep**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/28_kernel_timers_and_nanosleep/README.md) | OS Scheduling, scheduler yielding vs busy spinning, `struct timespec` (sec & nsec), `sys_nanosleep` (35) | [`precise_sleep.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/28_kernel_timers_and_nanosleep/precise_sleep.asm) |
| **29** | [**High-Concurrency `epoll` I/O**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/29_epoll_asynchronous_io/README.md) | Event-Driven Async I/O, $O(1)$ event notifications, `sys_epoll_create1` (291), `sys_epoll_ctl` (233), `sys_epoll_wait` (232), non-blocking TCP | [`epoll_server.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/29_epoll_asynchronous_io/epoll_server.asm) |
| **30** | [**Linux Seccomp Sandboxing**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/30_linux_seccomp_bpf_sandbox/README.md) | Kernel Security, process privilege restriction, `sys_prctl` (157), `PR_SET_NO_NEW_PRIVS`, `PR_SET_SECCOMP`, Strict Seccomp mode | [`seccomp_sandbox.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/30_linux_seccomp_bpf_sandbox/seccomp_sandbox.asm) |

---

## 📖 Reference Library & Cheat Sheets

- 📑 [**Complete Instruction Reference**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/docs/reference/instructions.md): Data movement, arithmetic, logic, jumps, and block string instructions.
- ⚡ [**x86-64 Architecture & Register Reference**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/docs/reference/registers.md): Subregister bit slices, scratch vs callee-saved registers, RFLAGS bits.
- 🐧 [**Linux Syscall Reference (64-bit vs 32-bit)**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/docs/reference/syscalls.md): Syscall numbers, register arguments, error code conventions.
- 🐞 [**GDB Assembly Cheat Sheet**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/cheatsheets/gdb_assembly.md): Instruction stepping, watchpoints, register modification, memory examination.
- 🔄 [**NASM vs GAS Rosetta Stone**](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/cheatsheets/nasm_vs_gas.md): Intel vs AT&T syntax cross-reference.

---

## 📂 Repository Structure

```text
ASSEMBLY_FOUNDATIONS/
├── Makefile                               # Universal build, test, and debug runner
├── ROADMAP.md                             # 30-Module Curriculum overview & learning progression
├── readme.md                              # Main documentation hub
├── docs/reference/                        # Architecture & syscall encyclopedias
├── cheatsheets/                           # GDB & Syntax quick-reference guides
├── projects/                              # Full-Scale Standalone Assembly Projects
│   ├── 01_interactive_snake_game/         # Terminal Snake game with raw IO & ANSI graphics
│   ├── 02_http_server_daemon/             # Multi-client HTTP daemon with routing & JSON
│   ├── 03_wav_audio_generator/            # 16-bit stereo polyphonic WAV audio synthesizer
│   ├── 04_raytracer_ppm/                  # 3D sphere raytracer with diffuse light shading
│   ├── 05_base64_file_converter/          # Stream-buffered binary-to-Base64 CLI converter
│   ├── 06_sha256_hasher/                  # NIST FIPS 180-4 SHA-256 cryptographic hasher CLI
│   ├── 07_mmap_key_value_store/           # Zero-copy disk-persistent memory-mapped binary KV database
│   └── 08_json_parser/                    # Streaming RFC 8259-compliant JSON tokenizer & AST parser
├── tutorials/
│   ├── 01_fundamentals/                   # CPU execution cycle, minimal exit, hello world
│   ├── 02_registers_and_memory/           # Addressing modes, .data, .bss, .rodata
│   ├── 03_arithmetic_and_logic/           # ADC/SBB, IMUL/IDIV, bitwise, RFLAGS
│   ├── 04_control_flow/                   # Branches, jumps, loops
│   ├── 05_stack_and_functions/            # Stack frames, ABI calling conventions
│   ├── 06_system_calls/                   # stdin/stdout, file I/O (open/read/close)
│   ├── 07_string_and_arrays/              # REP MOVSB/STOSB, strlen, in-place reverse
│   ├── 08_debugging_with_gdb/             # Step-by-step target for GDB
│   ├── 09_memory_management_mmap/         # Virtual memory, pages, raw mmap/munmap allocator
│   ├── 10_process_and_ipc/                # fork(), multitasking, kernel pipe ring buffer
│   ├── 11_socket_networking/              # TCP socket lifecycle, standalone HTTP web server
│   ├── 12_framebuffer_and_graphics/       # VRAM pixel math, 24-bit RGB fractal image generator
│   ├── 13_file_transfer_protocols/        # Binary serialization & Base64 stream encoder
│   ├── 14_baremetal_os_bootloader/        # 16-bit Real Mode MBR boot sector (loads at 0x7C00)
│   ├── 15_simd_avx_vectorization/         # AVX2 256-bit SIMD vector addition
│   ├── 16_concurrency_and_atomics/        # LOCK CMPXCHG hardware spinlocks & atomic math
│   ├── 17_c_and_python_interop/           # Shared object (.so) linking with C and Python ctypes
│   ├── 18_cryptography_and_hashing/       # DJB2 & FNV hash functions, hex serialization
│   ├── 19_elf_internals_and_linking/      # ELF-64 header parsing and /proc/self/exe introspection
│   ├── 20_arm64_and_riscv_cross_arch/     # CISC vs RISC (x86-64 vs ARM64 vs RISC-V)
│   ├── 21_audio_and_sound_synthesis/      # Raw PCM audio generator & 44-byte WAV header builder
│   ├── 22_binary_security_foundations/    # Shellcoding, PIC stack strings, ptrace anti-debugging
│   ├── 23_cpu_telemetry_and_benchmarking/ # CPUID vendor interrogation & RDTSC cycle latency timer
│   ├── 24_linux_signals_and_exceptions/   # Asynchronous signal handling (rt_sigaction & restorer)
│   ├── 25_x87_fpu_floating_point/         # 80-bit x87 FPU stack, trigonometry (sin/cos), fsqrt
│   ├── 26_terminal_graphics_and_raw_io/   # Direct ANSI escape sequence terminal canvas & colors
│   ├── 27_minimal_elf_golfing/            # Handcrafted 127-byte legal Linux ELF executable
│   ├── 28_kernel_timers_and_nanosleep/    # High-resolution cooperative sleep via sys_nanosleep
│   ├── 29_epoll_asynchronous_io/          # Event-driven TCP echo server with O(1) epoll
│   ├── 30_linux_seccomp_bpf_sandbox/      # Linux Seccomp & PR_SET_NO_NEW_PRIVS syscall lockdown
│   ├── 31_multithreading_raw_clone/       # Native threads via sys_clone, user stacks & atomics
│   ├── 32_hardware_virtualization_detection/ # CPUID hypervisor bit, vendor signature & VT-x/SVM
│   ├── 33_heap_allocator_sys_brk/         # Custom malloc/free heap allocator via sys_brk
│   ├── 34_hardware_port_io_cmos_rtc/      # Hardware port I/O (IN/OUT), sys_ioperm & CMOS clock
│   ├── 35_linux_futex_low_latency_mutex/  # Fast userspace mutex (sys_futex), atomic fast-path
│   └── 36_inotify_file_system_watcher/    # Linux inotify file monitoring & binary struct parsing
├── gas/                                   # Legacy GNU Assembler snippets
└── X86_ASSEMBLY/                          # Legacy 32-bit x86 experimental snippets
```