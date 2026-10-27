# Standalone Makefile for Module 02: Registers & Memory
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := addressing_modes data_sections
SRCS := addressing_modes.asm data_sections.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

addressing_modes: addressing_modes.o
	$(LD) $(LDFLAGS) $< -o $@

data_sections: data_sections.o
	$(LD) $(LDFLAGS) $< -o $@

run: addressing_modes
	./addressing_modes

test: all
	@echo "=== Testing Module 02: Registers & Memory ==="
	@./addressing_modes >/dev/null && echo "[+] addressing_modes executed successfully!"
	@./data_sections >/dev/null && echo "[+] data_sections executed successfully!"
	@echo "[+] Module 02 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
