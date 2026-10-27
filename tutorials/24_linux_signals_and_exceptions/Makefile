# Standalone Makefile for Module: 24_linux_signals_and_exceptions
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := signal_handler
SRC := signal_handler.asm
OBJ := signal_handler.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 24_linux_signals_and_exceptions ==="
	@./signal_handler >/dev/null && echo '[+] signal_handler executed successfully!'
	@echo "[+] Module 24_linux_signals_and_exceptions test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
