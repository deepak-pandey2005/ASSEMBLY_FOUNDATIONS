# Standalone Makefile for Module: 36_inotify_file_system_watcher
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := inotify_watcher
SRC := inotify_watcher.asm
OBJ := inotify_watcher.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 36_inotify_file_system_watcher ==="
	@./inotify_watcher >/dev/null && echo '[+] inotify_watcher executed successfully!'
	@echo "[+] Module 36_inotify_file_system_watcher test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
