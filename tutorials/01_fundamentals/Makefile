# Standalone Makefile for Module 01: Fundamentals
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := hello_64 minimal_exit
SRCS := hello_64.asm minimal_exit.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

hello_64: hello_64.o
	$(LD) $(LDFLAGS) $< -o $@

minimal_exit: minimal_exit.o
	$(LD) $(LDFLAGS) $< -o $@

run: hello_64
	./hello_64

test: all
	@echo "=== Testing Module 01: Fundamentals ==="
	@./hello_64 | grep -q "Hello, Assembly Foundations!" && echo "[+] hello_64 output verified!"
	@./minimal_exit; ret=$$?; [ $$ret -eq 42 ] && echo "[+] minimal_exit return code 42 verified!" || exit 1
	@echo "[+] Module 01 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
