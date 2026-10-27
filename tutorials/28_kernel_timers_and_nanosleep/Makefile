# Standalone Makefile for Module: 28_kernel_timers_and_nanosleep
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := precise_sleep
SRC := precise_sleep.asm
OBJ := precise_sleep.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 28_kernel_timers_and_nanosleep ==="
	@./precise_sleep >/dev/null && echo '[+] precise_sleep executed successfully!'
	@echo "[+] Module 28_kernel_timers_and_nanosleep test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
