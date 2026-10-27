# Standalone Makefile for SHA-256 Hasher CLI
# Assembles pure x86-64 assembly into an independent ELF64 binary.

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := sha256
SRC := sha256.asm
OBJ := sha256.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " SHA-256 Hasher built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Testing SHA-256 with NIST test vectors..."
	@echo "[*] Test 1: Vector 'abc'"
	@HASH=$$(printf "abc" | ./$(TARGET) | grep "SHA-256:" | awk '{print $$3}'); \
	EXPECTED="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"; \
	echo "    -> Output:   $$HASH"; \
	if [ "$$HASH" = "$$EXPECTED" ]; then echo "    [+] PASSED!"; else echo "    [-] FAILED!"; exit 1; fi
	@echo "[*] Test 2: Vector 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'"
	@HASH2=$$(printf "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" | ./$(TARGET) | grep "SHA-256:" | awk '{print $$3}'); \
	EXPECTED2="248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"; \
	echo "    -> Output:   $$HASH2"; \
	if [ "$$HASH2" = "$$EXPECTED2" ]; then echo "    [+] PASSED!"; else echo "    [-] FAILED!"; exit 1; fi
	@echo "[+] Standalone Project 06 (SHA-256 Hasher) All NIST Tests PASSED!"

run: test

clean:
	rm -f $(OBJ) $(TARGET)
