# Standalone Makefile for Module: 38_linux_io_uring_async_io
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := io_uring_demo
SRC := io_uring_demo.asm
OBJ := io_uring_demo.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 38_linux_io_uring_async_io ==="
	@./io_uring_demo >/dev/null && echo '[+] io_uring_demo executed successfully!'
	@echo "[+] Module 38_linux_io_uring_async_io test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
