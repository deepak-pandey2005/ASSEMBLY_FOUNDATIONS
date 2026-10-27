# Standalone Makefile for Module: 31_multithreading_raw_clone
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := raw_threads
SRC := raw_threads.asm
OBJ := raw_threads.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 31_multithreading_raw_clone ==="
	@./raw_threads >/dev/null && echo '[+] raw_threads executed successfully!'
	@echo "[+] Module 31_multithreading_raw_clone test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
