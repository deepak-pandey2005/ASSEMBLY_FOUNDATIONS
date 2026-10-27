# Standalone Makefile for Module: 32_hardware_virtualization_detection
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := vm_detect
SRC := vm_detect.asm
OBJ := vm_detect.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 32_hardware_virtualization_detection ==="
	@./vm_detect >/dev/null && echo '[+] vm_detect executed successfully!'
	@echo "[+] Module 32_hardware_virtualization_detection test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
