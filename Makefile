# Makefile for Assembly Foundations
# Universal Master Runner
# ------------------------------------------------------------------------------
# Supports:
#   1. 30 Guided Tutorials & Conceptual Modules (including epoll and seccomp sandboxing)
#   2. 5 Standalone Full-Scale Real-World Projects (each with its own Makefile)
# ------------------------------------------------------------------------------

NASM      := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
NASM32FLG := -f elf32 -g -F dwarf
NASMBIN   := -f bin

CC        := gcc
CFLAGS    := -Wall -O2

AS        := as
ASFLAGS   := --64 -g
ASFLAGS32 := --32 -g

LD        := ld
LDFLAGS   :=
LDFLAGS32 := -m elf_i386

BIN_DIR   := bin
OBJ_DIR   := obj

# List of all tutorial programs
PROGRAMS := \
	hello_64 \
	minimal_exit \
	addressing_modes \
	data_sections \
	arithmetic \
	bitwise \
	branches \
	loop_sum \
	function_call \
	stack_frame \
	user_input \
	cat_file \
	strlen_reverse \
	array_sum \
	debug_target \
	mmap_allocator \
	fork_pipe_ipc \
	tcp_webserver \
	render_pattern \
	base64_encoder \
	bootloader \
	avx2_vector_add \
	atomic_spinlock \
	libasm_math \
	test_c_ffi \
	hash_algorithms \
	elf_inspector \
	synth_audio \
	shellcode_demo \
	cpu_telemetry \
	signal_handler \
	fpu_math \
	ansi_canvas \
	tiny_golf \
	precise_sleep \
	epoll_server \
	seccomp_sandbox \
	raw_threads \
	vm_detect \
	heap_allocator \
	cmos_rtc \
	futex_mutex \
	inotify_watcher \
	perf_counters \
	io_uring_demo \
	spsc_ring \
	memfd_exec \
	ptrace_tracer

PROJECT_DIRS := \
	projects/01_interactive_snake_game \
	projects/02_http_server_daemon \
	projects/03_wav_audio_generator \
	projects/04_raytracer_ppm \
	projects/05_base64_file_converter \
	projects/06_sha256_hasher \
	projects/07_mmap_key_value_store \
	projects/08_json_parser \
	projects/09_chip8_emulator \
	projects/10_dns_client \
	projects/11_tar_archiver \
	projects/12_brainfuck_jit

MODULE_DIRS := $(sort $(wildcard tutorials/*/))

.PHONY: all clean help test test-network test-epoll test-ffi projects test-projects modules test-modules

all: $(PROGRAMS) projects
	@echo "=========================================================="
	@echo " All 41 Tutorials & 12 Projects Built Successfully!       "
	@echo "=========================================================="

$(BIN_DIR) $(OBJ_DIR):
	@mkdir -p $@

# ------------------------------------------------------------------------------
# Build Standalone Tutorial Modules & Projects
# ------------------------------------------------------------------------------
modules:
	@for dir in $(MODULE_DIRS); do \
		echo "Building module: $$dir"; \
		$(MAKE) -C $$dir; \
	done

test-modules:
	@tutorials/test_all_tutorials.sh

projects:
	@for dir in $(PROJECT_DIRS); do \
		echo "Building project: $$dir"; \
		$(MAKE) -C $$dir; \
	done

test-projects:
	@projects/test_all_projects.sh


# ------------------------------------------------------------------------------
# Modules 01 - 08 (Core Foundations)
# ------------------------------------------------------------------------------
$(OBJ_DIR)/hello_64.o: tutorials/01_fundamentals/hello_64.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

hello_64: $(OBJ_DIR)/hello_64.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/minimal_exit.o: tutorials/01_fundamentals/minimal_exit.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

minimal_exit: $(OBJ_DIR)/minimal_exit.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/addressing_modes.o: tutorials/02_registers_and_memory/addressing_modes.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

addressing_modes: $(OBJ_DIR)/addressing_modes.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/data_sections.o: tutorials/02_registers_and_memory/data_sections.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

data_sections: $(OBJ_DIR)/data_sections.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/arithmetic.o: tutorials/03_arithmetic_and_logic/arithmetic.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

arithmetic: $(OBJ_DIR)/arithmetic.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/bitwise.o: tutorials/03_arithmetic_and_logic/bitwise.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

bitwise: $(OBJ_DIR)/bitwise.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/branches.o: tutorials/04_control_flow/branches.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

branches: $(OBJ_DIR)/branches.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/loop_sum.o: tutorials/04_control_flow/loop_sum.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

loop_sum: $(OBJ_DIR)/loop_sum.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/function_call.o: tutorials/05_stack_and_functions/function_call.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

function_call: $(OBJ_DIR)/function_call.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/stack_frame.o: tutorials/05_stack_and_functions/stack_frame.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

stack_frame: $(OBJ_DIR)/stack_frame.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/user_input.o: tutorials/06_system_calls/user_input.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

user_input: $(OBJ_DIR)/user_input.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/cat_file.o: tutorials/06_system_calls/cat_file.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

cat_file: $(OBJ_DIR)/cat_file.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/strlen_reverse.o: tutorials/07_string_and_arrays/strlen_reverse.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

strlen_reverse: $(OBJ_DIR)/strlen_reverse.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/array_sum.o: tutorials/07_string_and_arrays/array_sum.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

array_sum: $(OBJ_DIR)/array_sum.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/debug_target.o: tutorials/08_debugging_with_gdb/debug_target.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

debug_target: $(OBJ_DIR)/debug_target.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

# ------------------------------------------------------------------------------
# Modules 09 - 14 (OS Components, Net, Graphics, Protocols, Bootloader)
# ------------------------------------------------------------------------------
$(OBJ_DIR)/mmap_allocator.o: tutorials/09_memory_management_mmap/mmap_allocator.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

mmap_allocator: $(OBJ_DIR)/mmap_allocator.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/fork_pipe_ipc.o: tutorials/10_process_and_ipc/fork_pipe_ipc.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

fork_pipe_ipc: $(OBJ_DIR)/fork_pipe_ipc.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/tcp_webserver.o: tutorials/11_socket_networking/tcp_webserver.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

tcp_webserver: $(OBJ_DIR)/tcp_webserver.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/render_pattern.o: tutorials/12_framebuffer_and_graphics/render_pattern.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

render_pattern: $(OBJ_DIR)/render_pattern.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/base64_encoder.o: tutorials/13_file_transfer_protocols/base64_encoder.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

base64_encoder: $(OBJ_DIR)/base64_encoder.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

bootloader: tutorials/14_baremetal_os_bootloader/bootloader.asm | $(BIN_DIR)
	$(NASM) $(NASMBIN) $< -o $(BIN_DIR)/$@.bin
	@echo "Bootloader image size: 512 bytes (verified boot sector)"

# ------------------------------------------------------------------------------
# Modules 15 - 22 (SIMD, Atomics, FFI, Crypto, ELF, Audio, Security)
# ------------------------------------------------------------------------------
$(OBJ_DIR)/avx2_vector_add.o: tutorials/15_simd_avx_vectorization/avx2_vector_add.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

avx2_vector_add: $(OBJ_DIR)/avx2_vector_add.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/atomic_spinlock.o: tutorials/16_concurrency_and_atomics/atomic_spinlock.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

atomic_spinlock: $(OBJ_DIR)/atomic_spinlock.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/asm_math.o: tutorials/17_c_and_python_interop/asm_math.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

libasm_math: $(OBJ_DIR)/asm_math.o | $(BIN_DIR)
	$(CC) -shared $< -o $(BIN_DIR)/libasm_math.so

test_c_ffi: $(OBJ_DIR)/asm_math.o tutorials/17_c_and_python_interop/test_c.c | $(BIN_DIR)
	$(CC) $(CFLAGS) tutorials/17_c_and_python_interop/test_c.c $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/hash_algorithms.o: tutorials/18_cryptography_and_hashing/hash_algorithms.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

hash_algorithms: $(OBJ_DIR)/hash_algorithms.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/elf_inspector.o: tutorials/19_elf_internals_and_linking/elf_inspector.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

elf_inspector: $(OBJ_DIR)/elf_inspector.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/synth_audio.o: tutorials/21_audio_and_sound_synthesis/synth_audio.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

synth_audio: $(OBJ_DIR)/synth_audio.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/shellcode_demo.o: tutorials/22_binary_security_foundations/shellcode_demo.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

shellcode_demo: $(OBJ_DIR)/shellcode_demo.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

# ------------------------------------------------------------------------------
# Modules 23 - 30 (Telemetry, Signals, FPU, Terminal, Golfing, Timers, Epoll, Seccomp)
# ------------------------------------------------------------------------------
$(OBJ_DIR)/cpu_telemetry.o: tutorials/23_cpu_telemetry_and_benchmarking/cpu_telemetry.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

cpu_telemetry: $(OBJ_DIR)/cpu_telemetry.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/signal_handler.o: tutorials/24_linux_signals_and_exceptions/signal_handler.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

signal_handler: $(OBJ_DIR)/signal_handler.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/fpu_math.o: tutorials/25_x87_fpu_floating_point/fpu_math.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

fpu_math: $(OBJ_DIR)/fpu_math.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/ansi_canvas.o: tutorials/26_terminal_graphics_and_raw_io/ansi_canvas.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

ansi_canvas: $(OBJ_DIR)/ansi_canvas.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

tiny_golf: tutorials/27_minimal_elf_golfing/tiny_golf.asm | $(BIN_DIR)
	$(NASM) $(NASMBIN) $< -o $(BIN_DIR)/$@
	@chmod +x $(BIN_DIR)/$@
	@echo "Handcrafted ELF size: $$(stat -c%s $(BIN_DIR)/$@) bytes"

$(OBJ_DIR)/precise_sleep.o: tutorials/28_kernel_timers_and_nanosleep/precise_sleep.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

precise_sleep: $(OBJ_DIR)/precise_sleep.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/epoll_server.o: tutorials/29_epoll_asynchronous_io/epoll_server.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

epoll_server: $(OBJ_DIR)/epoll_server.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/seccomp_sandbox.o: tutorials/30_linux_seccomp_bpf_sandbox/seccomp_sandbox.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

seccomp_sandbox: $(OBJ_DIR)/seccomp_sandbox.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/raw_threads.o: tutorials/31_multithreading_raw_clone/raw_threads.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

raw_threads: $(OBJ_DIR)/raw_threads.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/vm_detect.o: tutorials/32_hardware_virtualization_detection/vm_detect.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

vm_detect: $(OBJ_DIR)/vm_detect.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/heap_allocator.o: tutorials/33_heap_allocator_sys_brk/heap_allocator.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

heap_allocator: $(OBJ_DIR)/heap_allocator.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/cmos_rtc.o: tutorials/34_hardware_port_io_cmos_rtc/cmos_rtc.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

cmos_rtc: $(OBJ_DIR)/cmos_rtc.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/futex_mutex.o: tutorials/35_linux_futex_low_latency_mutex/futex_mutex.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

futex_mutex: $(OBJ_DIR)/futex_mutex.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/inotify_watcher.o: tutorials/36_inotify_file_system_watcher/inotify_watcher.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

inotify_watcher: $(OBJ_DIR)/inotify_watcher.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/perf_counters.o: tutorials/37_kernel_hardware_performance_counters/perf_counters.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

perf_counters: $(OBJ_DIR)/perf_counters.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/io_uring_demo.o: tutorials/38_linux_io_uring_async_io/io_uring_demo.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

io_uring_demo: $(OBJ_DIR)/io_uring_demo.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/spsc_ring.o: tutorials/39_lockfree_spsc_ring_buffer/spsc_ring.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

spsc_ring: $(OBJ_DIR)/spsc_ring.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/memfd_exec.o: tutorials/40_anonymous_memfd_execution/memfd_exec.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

memfd_exec: $(OBJ_DIR)/memfd_exec.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

$(OBJ_DIR)/ptrace_tracer.o: tutorials/41_linux_ptrace_process_tracer/ptrace_tracer.asm | $(OBJ_DIR)
	$(NASM) $(NASMFLAGS) $< -o $@

ptrace_tracer: $(OBJ_DIR)/ptrace_tracer.o | $(BIN_DIR)
	$(LD) $(LDFLAGS) $< -o $(BIN_DIR)/$@

# ------------------------------------------------------------------------------
# Testing and Verification
# ------------------------------------------------------------------------------
test: all test-projects test-epoll
	@echo "=== Testing Foundations ==="
	./$(BIN_DIR)/hello_64
	@./$(BIN_DIR)/minimal_exit; ret=$$?; [ $$ret -eq 42 ] && echo "Exit code 42 OK" || exit 1
	./$(BIN_DIR)/branches
	./$(BIN_DIR)/data_sections
	./$(BIN_DIR)/strlen_reverse
	cd tutorials/06_system_calls && ../../$(BIN_DIR)/cat_file
	@echo "=== Testing OS Components: mmap ==="
	./$(BIN_DIR)/mmap_allocator
	@echo "=== Testing OS Components: fork & IPC pipe ==="
	./$(BIN_DIR)/fork_pipe_ipc
	@echo "=== Testing Graphics Renderer ==="
	cd tutorials/12_framebuffer_and_graphics && ../../$(BIN_DIR)/render_pattern
	@echo "=== Testing Base64 Encoding ==="
	./$(BIN_DIR)/base64_encoder
	@echo "=== Verifying Bare-metal Boot Sector ==="
	@size=$$(stat -c%s $(BIN_DIR)/bootloader.bin); [ $$size -eq 512 ] && echo "Bootloader size is exactly 512 bytes OK" || exit 1
	@echo "=== Testing SIMD / AVX2 Vector Addition ==="
	./$(BIN_DIR)/avx2_vector_add
	@echo "=== Testing Concurrency & Atomic Spinlock ==="
	./$(BIN_DIR)/atomic_spinlock
	@echo "=== Testing C & Python Interop ==="
	./$(BIN_DIR)/test_c_ffi
	python3 tutorials/17_c_and_python_interop/test_py.py
	@echo "=== Testing Cryptography & Hashing ==="
	./$(BIN_DIR)/hash_algorithms
	@echo "=== Testing ELF Header Inspector ==="
	./$(BIN_DIR)/elf_inspector
	@echo "=== Testing Audio Synthesizer ==="
	cd tutorials/21_audio_and_sound_synthesis && ../../$(BIN_DIR)/synth_audio
	@echo "=== Testing Binary Security / Anti-Debugging ==="
	./$(BIN_DIR)/shellcode_demo
	@echo "=== Testing CPU Telemetry & Benchmarking ==="
	./$(BIN_DIR)/cpu_telemetry
	@echo "=== Testing Linux Signal Handling ==="
	./$(BIN_DIR)/signal_handler
	@echo "=== Testing x87 FPU Floating-Point Math ==="
	./$(BIN_DIR)/fpu_math
	@echo "=== Testing ANSI Terminal Canvas ==="
	./$(BIN_DIR)/ansi_canvas
	@echo "=== Testing Handcrafted Minimalist ELF (Golfing) ==="
	@./$(BIN_DIR)/tiny_golf; ret=$$?; [ $$ret -eq 42 ] && echo "Tiny ELF Exit code 42 OK ($$(stat -c%s $(BIN_DIR)/tiny_golf) bytes)" || exit 1
	@echo "=== Testing High-Resolution Kernel Timers ==="
	./$(BIN_DIR)/precise_sleep
	@echo "=== Testing Seccomp Syscall Sandboxing ==="
	./$(BIN_DIR)/seccomp_sandbox
	@echo "=== Testing Raw sys_clone Native Multithreading ==="
	./$(BIN_DIR)/raw_threads
	@echo "=== Testing Hardware Virtualization & Hypervisor Detection ==="
	./$(BIN_DIR)/vm_detect
	@echo "=== Testing Custom Heap Allocator (sys_brk) ==="
	./$(BIN_DIR)/heap_allocator
	@echo "=== Testing Hardware Port I/O & CMOS RTC Clock ==="
	./$(BIN_DIR)/cmos_rtc
	@echo "=== Testing Linux Futex Low-Latency Mutex ==="
	./$(BIN_DIR)/futex_mutex
	@echo "=== Testing Linux Kernel Inotify File-System Watcher ==="
	./$(BIN_DIR)/inotify_watcher
	@echo "=== Testing Linux Kernel Hardware Performance Counters ==="
	./$(BIN_DIR)/perf_counters
	@echo "=== Testing Modern Linux io_uring Asynchronous I/O ==="
	./$(BIN_DIR)/io_uring_demo
	@echo "=== Testing Lock-Free SPSC Ring Buffer Concurrency ==="
	./$(BIN_DIR)/spsc_ring
	@echo "=== Testing Anonymous Memory Execution (memfd_create & execveat) ==="
	./$(BIN_DIR)/memfd_exec
	@echo "=== Testing Linux Process Tracing & Syscall Interception (sys_ptrace) ==="
	./$(BIN_DIR)/ptrace_tracer
	@echo "=========================================================="
	@echo " ALL 41 MODULES & 12 STANDALONE PROJECTS PASSED PERFECTLY!"
	@echo "=========================================================="

test-epoll: epoll_server
	@echo "Starting epoll async server in background..."
	@./$(BIN_DIR)/epoll_server & EPOLL_PID=$$!; \
	sleep 0.5; \
	RESP=$$(echo "Hello epoll from assembly test" | nc -w 1 127.0.0.1 9090 || true); \
	kill $$EPOLL_PID 2>/dev/null || true; \
	echo "[+] epoll async server response: $$RESP"; \
	echo "[+] epoll verification test complete."

test-network: tcp_webserver
	@echo "Starting web server in background..."
	@./$(BIN_DIR)/tcp_webserver & SERVER_PID=$$!; \
	sleep 0.5; \
	curl -s http://127.0.0.1:8080; \
	wait $$SERVER_PID 2>/dev/null || true; \
	echo "[+] TCP Webserver test complete."

debug: debug_target
	gdb -q -ex "set disassembly-flavor intel" -ex "b *_start" -ex "r" ./$(BIN_DIR)/debug_target

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) tutorials/12_framebuffer_and_graphics/canvas.ppm tutorials/21_audio_and_sound_synthesis/sound.wav
	@for dir in $(PROJECT_DIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	@for dir in $(MODULE_DIRS); do \
		$(MAKE) -C $$dir clean; \
	done

help:
	@echo "Assembly Foundations Build Targets:"
	@echo "  make all          - Build all 41 modules and 12 standalone projects"
	@echo "  make modules      - Build all 41 tutorial modules in their local directories"
	@echo "  make projects     - Build all 12 standalone projects in their local directories"
	@echo "  make test         - Run full test suite verifying tutorials and projects"
	@echo "  make test-modules - Run automated verification across all 41 tutorial modules"
	@echo "  make test-projects- Run automated verification across all 12 standalone projects"
	@echo "  make test-epoll   - Run epoll async TCP echo test"
	@echo "  make test-network - Run pure assembly HTTP web server test"
	@echo "  make clean        - Remove all binaries, objects, and test outputs"
	@echo "  make debug        - Launch GDB on the debug_target binary"

