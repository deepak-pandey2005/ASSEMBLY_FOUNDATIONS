# Standalone Makefile for Module 17: C & Python Interop
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

CC ?= gcc
CFLAGS ?= -Wall -O2

all: test_c libasm_math.so

asm_math.o: asm_math.asm
	$(NASM) $(NASMFLAGS) $< -o $@

libasm_math.so: asm_math.o
	$(LD) -shared $< -o $@

test_c: test_c.c asm_math.o
	$(CC) $(CFLAGS) test_c.c asm_math.o -o $@

.PHONY: all run test clean

run: test_c
	./test_c

test: all
	@echo "=== Testing Module 17: C & Python Interop ==="
	@./test_c >/dev/null && echo "[+] C FFI interop test passed!"
	@python3 test_py.py >/dev/null && echo "[+] Python ctypes FFI interop test passed!"
	@echo "[+] Module 17 test passed!"

clean:
	rm -f asm_math.o libasm_math.so test_c
