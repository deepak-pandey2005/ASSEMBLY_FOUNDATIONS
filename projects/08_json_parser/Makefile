# Standalone Makefile for JSON Lexer & Parser CLI

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := asm_json
SRC := json_parser.asm
OBJ := json_parser.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " JSON Parser built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Testing JSON Parser with piped custom JSON payload..."
	@printf '{"name":"x86-64_Assembly","version":2026,"author":"deepak","active":true}' | ./$(TARGET)

run: test

clean:
	rm -f $(OBJ) $(TARGET)
