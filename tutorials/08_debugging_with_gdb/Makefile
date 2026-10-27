# Standalone Makefile for Module: 08_debugging_with_gdb
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := debug_target
SRC := debug_target.asm
OBJ := debug_target.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 08_debugging_with_gdb ==="
	@./debug_target >/dev/null && echo '[+] debug_target executed successfully!'
	@echo "[+] Module 08_debugging_with_gdb test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
