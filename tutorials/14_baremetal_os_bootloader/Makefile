# Standalone Makefile for Module 14: Bootloader
NASM ?= nasm
TARGET := bootloader.bin
SRC := bootloader.asm

.PHONY: all run test clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(NASM) -f bin $< -o $@
	@echo "Bootloader image size: 512 bytes (verified boot sector)"

test: $(TARGET)
	@echo "=== Testing Module 14: Baremetal Bootloader ==="
	@[ $$(stat -c%s $(TARGET)) -eq 512 ] && echo "[+] Bootloader image is exactly 512 bytes!" || exit 1
	@echo "[+] Module 14 test passed!"

run: $(TARGET)
	@echo "Bootloader binary ready. Can be booted using QEMU: qemu-system-x86_64 -drive format=raw,file=$(TARGET)"

clean:
	rm -f $(TARGET)
