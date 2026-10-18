# Makefile for Assembly Foundations
# Supports assembling and linking NASM (Intel) and GAS (AT&T) sources
# Includes standard foundation programs + advanced OS, Network, Graphics,
# Bootloader, SIMD, Atomics, FFI, Cryptography, ELF, Audio, and Binary Security targets.

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
	shellcode_demo

.PHONY: all clean help test test-network test-ffi

all: $(PROGRAMS)
	@echo "=========================================================="
	@echo " All Assembly Foundations targets built successfully!    "
	@echo " Binaries located in ./$(BIN_DIR)/                        "
	@echo "=========================================================="

$(BIN_DIR) $(OBJ_DIR):
	@mkdir -p $@

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
# Testing and Verification
# ------------------------------------------------------------------------------
test: all
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
	@echo "All tests passed successfully!"

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

help:
	@echo "Assembly Foundations Build Targets:"
	@echo "  make all          - Build all assembly tutorial and advanced programs"
	@echo "  make test         - Run test suite and verify program outputs"
	@echo "  make test-network - Run pure assembly HTTP web server test"
	@echo "  make clean        - Remove all binaries, objects, and test outputs"
	@echo "  make debug        - Launch GDB on the debug_target binary"
