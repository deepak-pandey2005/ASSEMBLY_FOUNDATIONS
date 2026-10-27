# Standalone Makefile for Module: 37_kernel_hardware_performance_counters
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := perf_counters
SRC := perf_counters.asm
OBJ := perf_counters.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 37_kernel_hardware_performance_counters ==="
	@./perf_counters >/dev/null && echo '[+] perf_counters executed successfully!'
	@echo "[+] Module 37_kernel_hardware_performance_counters test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
