# Standalone Makefile for Module: 19_elf_internals_and_linking
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := elf_inspector
SRC := elf_inspector.asm
OBJ := elf_inspector.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 19_elf_internals_and_linking ==="
	@./elf_inspector >/dev/null && echo '[+] elf_inspector executed successfully!'
	@echo "[+] Module 19_elf_internals_and_linking test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
