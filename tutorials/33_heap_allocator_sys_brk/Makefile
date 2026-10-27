# Standalone Makefile for Module: 33_heap_allocator_sys_brk
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := heap_allocator
SRC := heap_allocator.asm
OBJ := heap_allocator.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 33_heap_allocator_sys_brk ==="
	@./heap_allocator >/dev/null && echo '[+] heap_allocator executed successfully!'
	@echo "[+] Module 33_heap_allocator_sys_brk test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
