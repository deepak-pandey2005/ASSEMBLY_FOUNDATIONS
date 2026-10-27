# Standalone Makefile for Module 07: String & Arrays
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := strlen_reverse array_sum
SRCS := strlen_reverse.asm array_sum.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

strlen_reverse: strlen_reverse.o
	$(LD) $(LDFLAGS) $< -o $@

array_sum: array_sum.o
	$(LD) $(LDFLAGS) $< -o $@

run: strlen_reverse
	./strlen_reverse

test: all
	@echo "=== Testing Module 07: String & Arrays ==="
	@./strlen_reverse >/dev/null && echo "[+] strlen_reverse executed successfully!"
	@./array_sum >/dev/null && echo "[+] array_sum executed successfully!"
	@echo "[+] Module 07 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
