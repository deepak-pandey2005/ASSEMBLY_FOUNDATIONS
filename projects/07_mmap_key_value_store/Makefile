# Standalone Makefile for Memory-Mapped Key-Value Store CLI

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := mkvstore
SRC := mkvstore.asm
OBJ := mkvstore.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " MKVStore built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@rm -f data.mkv
	@echo "[*] Step 1: Setting key 'user' => 'root'..."
	@./$(TARGET) set user root
	@echo "[*] Step 2: Setting key 'port' => '8080'..."
	@./$(TARGET) set port 8080
	@echo "[*] Step 3: Getting key 'user'..."
	@VAL=$$(./$(TARGET) get user); \
	if [ "$$VAL" = "root" ]; then \
		echo "[+] Key 'user' retrieved successfully: $$VAL"; \
	else \
		echo "[-] Expected 'root', got '$$VAL'"; \
		exit 1; \
	fi
	@echo "[*] Step 4: Dumping database contents..."
	@./$(TARGET) dump
	@echo "[+] Standalone Project 07 (mkvstore) Test PASSED!"

run: test

clean:
	rm -f $(OBJ) $(TARGET) data.mkv
