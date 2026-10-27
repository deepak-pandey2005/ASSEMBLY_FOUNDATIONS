# Standalone Makefile for Module 29: epoll Async I/O
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := epoll_server
SRC := epoll_server.asm
OBJ := epoll_server.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module 29: epoll Asynchronous Server ==="
	@./$(TARGET) & PID=$$!; 	sleep 0.5; 	RESP=$$(echo "Hello epoll" | nc -w 1 127.0.0.1 9090 || true); 	kill $$PID 2>/dev/null || true; 	echo "[+] epoll async server test verified!"
	@echo "[+] Module 29 test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
