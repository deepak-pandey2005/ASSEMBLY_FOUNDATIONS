# Standalone Makefile for CHIP-8 Virtual Machine & Emulator

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := chip8
SRC := chip8.asm
OBJ := chip8.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " CHIP-8 Emulator built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Executing CHIP-8 Emulator with built-in font rendering ROM..."
	@./$(TARGET)

run: test

clean:
	rm -f $(OBJ) $(TARGET)
