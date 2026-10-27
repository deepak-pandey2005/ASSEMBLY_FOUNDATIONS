# Standalone Makefile for Module: 41_linux_ptrace_process_tracer
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := ptrace_tracer
SRC := ptrace_tracer.asm
OBJ := ptrace_tracer.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 41_linux_ptrace_process_tracer ==="
	@./ptrace_tracer >/dev/null && echo '[+] ptrace_tracer executed successfully!'
	@echo "[+] Module 41_linux_ptrace_process_tracer test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
