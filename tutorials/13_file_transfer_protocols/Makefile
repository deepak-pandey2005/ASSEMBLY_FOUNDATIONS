# Standalone Makefile for Module: 13_file_transfer_protocols
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := base64_encoder
SRC := base64_encoder.asm
OBJ := base64_encoder.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 13_file_transfer_protocols ==="
	@./base64_encoder >/dev/null && echo '[+] base64_encoder executed successfully!'
	@echo "[+] Module 13_file_transfer_protocols test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
