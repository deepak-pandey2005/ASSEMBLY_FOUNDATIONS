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
	@echo "Testing JSON Lexer & Parser with structured JSON payload..."
	@OUT=$$(printf '{"name":"Assembly Foundations","version":2026,"author":"deepak","active":true}' | ./$(TARGET)); \
	echo "$$OUT"; \
	echo "$$OUT" | grep -q "Found key 'name'    => 'Assembly Foundations'" || exit 1; \
	echo "$$OUT" | grep -q "Found key 'version' => 2026" || exit 1; \
	echo "$$OUT" | grep -q "Found key 'author'  => 'deepak'" || exit 1; \
	echo "$$OUT" | grep -q "Found key 'active'  => true" || exit 1; \
	echo "[+] Standalone Project 08 (JSON Lexer & Parser) Assertions PASSED!"

run: test

clean:
	rm -f $(OBJ) $(TARGET)
