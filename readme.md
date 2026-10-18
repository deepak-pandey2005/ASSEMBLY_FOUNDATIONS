# Assembly Foundations 🏛️⚡

> A comprehensive, hands-on, step-by-step tutorial curriculum and low-level systems library covering x86 and x86-64 assembly, Linux OS internals, raw TCP networking, pixel graphics, data encoding, bare-metal OS bootloaders, AVX2 SIMD vectorization, hardware atomics, C/Python FFI interop, cryptography, ELF internals, audio synthesis, and binary security.

---

## 🚀 Quick Start

Build and test all 22 modules immediately with a single command:

```bash
# Clone and enter the workspace
cd ASSEMBLY_FOUNDATIONS

# Build all 22 tutorial programs and advanced systems
make all

# Run the automated verification test suite across all 22 modules
make test

# Test the pure assembly HTTP web server
make test-network
```

Inspect any binary in GDB with Intel disassembly layout:
```bash
make debug
```

---

## 🗺️ Step-by-Step Curriculum

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
├── ROADMAP.md                             # 22-Module Curriculum overview & learning progression
├── readme.md                              # Main documentation hub
├── docs/reference/                        # Architecture & syscall encyclopedias
├── cheatsheets/                           # GDB & Syntax quick-reference guides
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
│   └── 22_binary_security_foundations/    # Shellcoding, PIC stack strings, ptrace anti-debugging
├── gas/                                   # Legacy GNU Assembler snippets
└── X86_ASSEMBLY/                          # Legacy 32-bit x86 experimental snippets
```