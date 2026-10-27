# Standalone Makefile for Module: 18_cryptography_and_hashing
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := hash_algorithms
SRC := hash_algorithms.asm
OBJ := hash_algorithms.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 18_cryptography_and_hashing ==="
	@./hash_algorithms >/dev/null && echo '[+] hash_algorithms executed successfully!'
	@echo "[+] Module 18_cryptography_and_hashing test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
