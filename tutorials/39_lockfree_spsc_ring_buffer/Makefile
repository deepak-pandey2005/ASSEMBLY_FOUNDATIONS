# Standalone Makefile for Module: 39_lockfree_spsc_ring_buffer
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := spsc_ring
SRC := spsc_ring.asm
OBJ := spsc_ring.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 39_lockfree_spsc_ring_buffer ==="
	@./spsc_ring >/dev/null && echo '[+] spsc_ring executed successfully!'
	@echo "[+] Module 39_lockfree_spsc_ring_buffer test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
