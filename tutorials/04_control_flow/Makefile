# Standalone Makefile for Module 04: Control Flow
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := branches loop_sum
SRCS := branches.asm loop_sum.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

branches: branches.o
	$(LD) $(LDFLAGS) $< -o $@

loop_sum: loop_sum.o
	$(LD) $(LDFLAGS) $< -o $@

run: branches
	./branches

test: all
	@echo "=== Testing Module 04: Control Flow ==="
	@./branches >/dev/null && echo "[+] branches executed successfully!"
	@./loop_sum >/dev/null && echo "[+] loop_sum executed successfully!"
	@echo "[+] Module 04 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
