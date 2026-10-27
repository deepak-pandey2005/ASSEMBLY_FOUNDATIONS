# Standalone Makefile for Module: 25_x87_fpu_floating_point
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := fpu_math
SRC := fpu_math.asm
OBJ := fpu_math.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 25_x87_fpu_floating_point ==="
	@./fpu_math >/dev/null && echo '[+] fpu_math executed successfully!'
	@echo "[+] Module 25_x87_fpu_floating_point test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
