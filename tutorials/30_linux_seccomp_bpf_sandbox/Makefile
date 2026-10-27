# Standalone Makefile for Module: 30_linux_seccomp_bpf_sandbox
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := seccomp_sandbox
SRC := seccomp_sandbox.asm
OBJ := seccomp_sandbox.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 30_linux_seccomp_bpf_sandbox ==="
	@./seccomp_sandbox >/dev/null && echo '[+] seccomp_sandbox executed successfully!'
	@echo "[+] Module 30_linux_seccomp_bpf_sandbox test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
