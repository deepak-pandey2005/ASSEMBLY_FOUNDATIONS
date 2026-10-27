# Standalone Makefile for Base64 File Converter

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := b64encode
SRC := b64encode.asm
OBJ := b64encode.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Base64 Converter built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Testing Base64 File Converter with standard payload..."
	@printf "Assembly Foundations Pure x86-64 Linux Machine Code" > input.bin
	@./$(TARGET)
	@ENCODED=$$(cat output.b64); \
	EXPECTED=$$(base64 -w 0 input.bin); \
	echo "[+] Output:   $$ENCODED"; \
	echo "[+] Expected: $$EXPECTED"; \
	if [ "$$ENCODED" = "$$EXPECTED" ]; then \
		echo "[+] Base64 bit-exact verification with GNU coreutils PASSED!"; \
	else \
		echo "[-] Verification FAILED!"; \
		exit 1; \
	fi
	@rm -f input.bin output.b64

run: test

clean:
	rm -f $(OBJ) $(TARGET) input.bin output.b64
