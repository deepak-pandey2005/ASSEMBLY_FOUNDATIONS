# Standalone Makefile for Module: 09_memory_management_mmap
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := mmap_allocator
SRC := mmap_allocator.asm
OBJ := mmap_allocator.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 09_memory_management_mmap ==="
	@./mmap_allocator >/dev/null && echo '[+] mmap_allocator executed successfully!'
	@echo "[+] Module 09_memory_management_mmap test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
