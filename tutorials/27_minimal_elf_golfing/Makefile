# Standalone Makefile for Module 27: Minimal ELF Golfing
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := tiny_golf
SRC := tiny_golf.asm

.PHONY: all run test clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(NASM) -f bin $< -o $@
	@chmod +x $@

run: $(TARGET)
	./$(TARGET) || true

test: $(TARGET)
	@echo "=== Testing Module 27: Minimal ELF Golfing ==="
	@./$(TARGET); ret=$$?; [ $$ret -eq 42 ] && echo "[+] Exit code 42 verified ($$(stat -c%s $(TARGET)) bytes)!" || exit 1
	@echo "[+] Module 27 test passed!"

clean:
	rm -f $(TARGET)
