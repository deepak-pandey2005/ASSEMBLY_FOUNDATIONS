# Standalone Makefile for Module 05: Stack & Functions
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGETS := function_call stack_frame
SRCS := function_call.asm stack_frame.asm
OBJS := $(SRCS:.asm=.o)

.PHONY: all run test clean

all: $(TARGETS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

function_call: function_call.o
	$(LD) $(LDFLAGS) $< -o $@

stack_frame: stack_frame.o
	$(LD) $(LDFLAGS) $< -o $@

run: function_call
	./function_call

test: all
	@echo "=== Testing Module 05: Stack & Functions ==="
	@./function_call >/dev/null && echo "[+] function_call executed successfully!"
	@./stack_frame >/dev/null && echo "[+] stack_frame executed successfully!"
	@echo "[+] Module 05 test passed!"

clean:
	rm -f $(OBJS) $(TARGETS)
