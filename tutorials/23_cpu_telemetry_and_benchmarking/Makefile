# Standalone Makefile for Module: 23_cpu_telemetry_and_benchmarking
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := cpu_telemetry
SRC := cpu_telemetry.asm
OBJ := cpu_telemetry.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 23_cpu_telemetry_and_benchmarking ==="
	@./cpu_telemetry >/dev/null && echo '[+] cpu_telemetry executed successfully!'
	@echo "[+] Module 23_cpu_telemetry_and_benchmarking test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
