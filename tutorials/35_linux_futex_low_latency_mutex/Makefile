# Standalone Makefile for Module: 35_linux_futex_low_latency_mutex
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := futex_mutex
SRC := futex_mutex.asm
OBJ := futex_mutex.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 35_linux_futex_low_latency_mutex ==="
	@./futex_mutex >/dev/null && echo '[+] futex_mutex executed successfully!'
	@echo "[+] Module 35_linux_futex_low_latency_mutex test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
