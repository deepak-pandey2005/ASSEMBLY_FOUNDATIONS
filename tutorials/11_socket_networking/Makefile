# Standalone Makefile for Module 11: Socket Networking
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := tcp_webserver
SRC := tcp_webserver.asm
OBJ := tcp_webserver.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	@echo "Starting TCP Web Server on http://127.0.0.1:8080..."
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module 11: TCP Web Server ==="
	@./$(TARGET) & PID=$$!; \
	sleep 0.5; \
	RESP=$$(curl -s http://127.0.0.1:8080 || true); \
	wait $$PID 2>/dev/null || true; \
	if echo "$$RESP" | grep -q "Pure x86-64 Assembly Web Server"; then \
		echo "[+] Web server response verified!"; \
	else \
		echo "[-] Web server test failed!"; \
		exit 1; \
	fi
	@echo "[+] Module 11 test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
