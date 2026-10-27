# Standalone Makefile for Module: 16_concurrency_and_atomics
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := atomic_spinlock
SRC := atomic_spinlock.asm
OBJ := atomic_spinlock.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 16_concurrency_and_atomics ==="
	@./atomic_spinlock >/dev/null && echo '[+] atomic_spinlock executed successfully!'
	@echo "[+] Module 16_concurrency_and_atomics test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
