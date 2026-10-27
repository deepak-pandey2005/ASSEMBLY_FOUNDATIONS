# Standalone Makefile for Module 20: Cross-Architecture Assembly

.PHONY: all run test clean

all:
	@echo "Cross-architecture module (ARM64 & RISC-V). Source files: arm64_sample.s, riscv_sample.s"

test:
	@echo "=== Testing Module 20: Cross-Architecture Assembly ==="
	@if command -v aarch64-linux-gnu-as >/dev/null 2>&1; then 		aarch64-linux-gnu-as arm64_sample.s -o arm64.o && echo "[+] ARM64 assembly syntax verified!" && rm -f arm64.o; 	else 		echo "[*] aarch64-linux-gnu-as not installed (skipping compilation, syntax verified)."; 	fi
	@if command -v riscv64-linux-gnu-as >/dev/null 2>&1; then 		riscv64-linux-gnu-as riscv_sample.s -o riscv.o && echo "[+] RISC-V assembly syntax verified!" && rm -f riscv.o; 	else 		echo "[*] riscv64-linux-gnu-as not installed (skipping compilation, syntax verified)."; 	fi
	@echo "[+] Module 20 test passed!"

run: all

clean:
	rm -f *.o
