# Standalone Makefile for Module 03: Arithmetic & Logic
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := arithmetic bitwise
SRCS := arithmetic.asm bitwise.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

arithmetic: arithmetic.o
	$(LD) $(LDFLAGS) $< -o $@

bitwise: bitwise.o
	$(LD) $(LDFLAGS) $< -o $@

run: arithmetic
	./arithmetic

test: all
	@echo "=== Testing Module 03: Arithmetic & Logic ==="
	@./arithmetic >/dev/null && echo "[+] arithmetic executed successfully!"
	@./bitwise >/dev/null && echo "[+] bitwise executed successfully!"
	@echo "[+] Module 03 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
