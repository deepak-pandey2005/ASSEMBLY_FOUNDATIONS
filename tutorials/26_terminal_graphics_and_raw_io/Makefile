# Standalone Makefile for Module: 26_terminal_graphics_and_raw_io
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := ansi_canvas
SRC := ansi_canvas.asm
OBJ := ansi_canvas.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 26_terminal_graphics_and_raw_io ==="
	@./ansi_canvas >/dev/null && echo '[+] ansi_canvas executed successfully!'
	@echo "[+] Module 26_terminal_graphics_and_raw_io test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
