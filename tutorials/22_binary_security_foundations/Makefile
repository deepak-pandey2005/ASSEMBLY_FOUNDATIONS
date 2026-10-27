# Standalone Makefile for Module: 22_binary_security_foundations
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := shellcode_demo
SRC := shellcode_demo.asm
OBJ := shellcode_demo.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 22_binary_security_foundations ==="
	@./shellcode_demo >/dev/null && echo '[+] shellcode_demo executed successfully!'
	@echo "[+] Module 22_binary_security_foundations test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
