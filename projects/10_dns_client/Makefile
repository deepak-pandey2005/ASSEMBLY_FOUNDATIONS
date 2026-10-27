# Standalone Makefile for RFC 1035 DNS Client CLI Tool

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := dns_client
SRC := dns_client.asm
OBJ := dns_client.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " RFC 1035 DNS Client built! Run with: ./$(TARGET) [domain]"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Testing DNS Resolution for google.com..."
	@OUT=$$(./$(TARGET) google.com); \
	echo "$$OUT"; \
	echo "$$OUT" | grep -q "RFC 1035 DNS Client resolution verified successfully!" || exit 1; \
	echo "[+] Standalone Project 10 (RFC 1035 DNS Client) Test PASSED!"

run: $(TARGET)
	./$(TARGET) google.com

clean:
	rm -f $(OBJ) $(TARGET)
