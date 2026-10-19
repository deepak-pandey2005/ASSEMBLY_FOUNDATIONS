# Standalone Makefile for Base64 File Converter

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := b64encode
SRC := b64encode.asm
OBJ := b64encode.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Base64 Converter built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Assembly Foundations Project" > input.bin
	@./$(TARGET)
	@echo "Encoded output content:"
	@cat output.b64

run: test

clean:
	rm -f $(OBJ) $(TARGET) input.bin output.b64
