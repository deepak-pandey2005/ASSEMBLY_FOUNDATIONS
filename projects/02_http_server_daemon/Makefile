# Standalone Makefile for Assembly HTTP Server Daemon

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := http_server
SRC := server_daemon.asm
OBJ := server_daemon.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " HTTP Server built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

run: $(TARGET)
	@echo "Starting HTTP Server Daemon on http://127.0.0.1:8080 (Press Ctrl+C to stop)..."
	@echo "Tip: Run 'make test' to execute automated endpoint tests without blocking."
	./$(TARGET)

test: $(TARGET)
	@echo "Testing HTTP Daemon endpoints..."
	@./$(TARGET) & PID=$$!; \
	sleep 0.5; \
	API_RESP=$$(curl -s http://127.0.0.1:8080/api/status); \
	HTML_RESP=$$(curl -s http://127.0.0.1:8080/); \
	ERR_RESP=$$(curl -s http://127.0.0.1:8080/nonexistent); \
	kill $$PID 2>/dev/null || true; \
	echo "[*] GET /api/status response: $$API_RESP"; \
	if echo "$$API_RESP" | grep -q '"status":"online"'; then \
		echo "[+] /api/status JSON endpoint verified!"; \
	else \
		echo "[-] /api/status verification failed!"; \
		exit 1; \
	fi; \
	if echo "$$HTML_RESP" | grep -q "Assembly Foundations HTTP Server Daemon"; then \
		echo "[+] Root '/' HTML endpoint verified!"; \
	else \
		echo "[-] Root endpoint verification failed!"; \
		exit 1; \
	fi; \
	if echo "$$ERR_RESP" | grep -q "404 Not Found"; then \
		echo "[+] 404 handler verified!"; \
	else \
		echo "[-] 404 handler verification failed!"; \
		exit 1; \
	fi; \
	echo "[+] HTTP Daemon test passed successfully!"

clean:
	rm -f $(OBJ) $(TARGET)
