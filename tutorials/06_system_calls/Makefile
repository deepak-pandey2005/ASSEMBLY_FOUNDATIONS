# Standalone Makefile for Module 06: System Calls
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := cat_file user_input
SRCS := cat_file.asm user_input.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

cat_file: cat_file.o
	$(LD) $(LDFLAGS) $< -o $@

user_input: user_input.o
	$(LD) $(LDFLAGS) $< -o $@

run: cat_file
	./cat_file

test: all
	@echo "=== Testing Module 06: System Calls ==="
	@./cat_file >/dev/null && echo "[+] cat_file read sample.txt successfully!"
	@printf "TestUser\n" | ./user_input >/dev/null && echo "[+] user_input read and echoed successfully!"
	@echo "[+] Module 06 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
