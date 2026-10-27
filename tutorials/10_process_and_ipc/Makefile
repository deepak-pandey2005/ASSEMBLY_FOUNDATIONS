# Standalone Makefile for Module: 10_process_and_ipc
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := fork_pipe_ipc
SRC := fork_pipe_ipc.asm
OBJ := fork_pipe_ipc.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 10_process_and_ipc ==="
	@./fork_pipe_ipc >/dev/null && echo '[+] fork_pipe_ipc executed successfully!'
	@echo "[+] Module 10_process_and_ipc test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
