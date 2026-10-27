# Standalone Makefile for Module: 40_anonymous_memfd_execution
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := memfd_exec
SRC := memfd_exec.asm
OBJ := memfd_exec.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 40_anonymous_memfd_execution ==="
	@./memfd_exec >/dev/null && echo '[+] memfd_exec executed successfully!'
	@echo "[+] Module 40_anonymous_memfd_execution test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
