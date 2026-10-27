# Standalone Makefile for POSIX tar Archiver & Extractor CLI

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := asm_tar
SRC := tar_archiver.asm
OBJ := tar_archiver.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " POSIX tar Archiver built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "=== 1. Preparing test files ==="
	@echo "Assembly Foundations Project 11: POSIX tar archiver!" > file_alpha.txt
	@echo "Testing multi-block payloads and padding verification." > file_beta.txt
	@echo "=== 2. Creating archive with asm_tar ==="
	./$(TARGET) create test_bundle.tar file_alpha.txt file_beta.txt
	@echo "=== 3. Listing archive with asm_tar ==="
	./$(TARGET) list test_bundle.tar
	@echo "=== 4. Verifying archive with Linux GNU tar utility ==="
	tar -tvf test_bundle.tar
	@echo "=== 5. Extracting archive with asm_tar ==="
	rm -f file_alpha.txt file_beta.txt
	./$(TARGET) extract test_bundle.tar
	@grep -q "Assembly Foundations" file_alpha.txt && echo "[+] Extraction verification PASSED!" || exit 1
	@rm -f file_alpha.txt file_beta.txt test_bundle.tar
	@echo "=== POSIX tar Archiver & Extractor Verification Complete! ==="

run: test

clean:
	rm -f $(OBJ) $(TARGET) test_bundle.tar file_alpha.txt file_beta.txt
