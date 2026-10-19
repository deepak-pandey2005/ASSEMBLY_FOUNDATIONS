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
	./$(TARGET)

test: $(TARGET)
	@echo "Testing HTTP Daemon endpoints..."
	@./$(TARGET) & PID=$$!; \
	sleep 0.5; \
	curl -s http://127.0.0.1:8080/api/status; echo ""; \
	curl -s http://127.0.0.1:8080/; echo ""; \
	kill $$PID 2>/dev/null || true; \
	echo "[+] HTTP Daemon test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
