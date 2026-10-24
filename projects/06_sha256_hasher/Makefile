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
	@echo "Testing SHA-256 with standard NIST test vector 'abc'..."
	@HASH=$$(printf "abc" | ./$(TARGET) | grep "SHA-256:" | awk '{print $$3}'); \
	EXPECTED="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"; \
	echo "[+] Output:   $$HASH"; \
	echo "[+] Expected: $$EXPECTED"; \
	if [ "$$HASH" = "$$EXPECTED" ]; then \
		echo "[+] NIST Standard 'abc' SHA-256 Test PASSED!"; \
	else \
		echo "[-] NIST Test FAILED!"; \
		exit 1; \
	fi

run: test

clean:
	rm -f $(OBJ) $(TARGET)
