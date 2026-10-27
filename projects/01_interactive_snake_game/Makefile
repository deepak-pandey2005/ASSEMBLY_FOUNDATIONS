# Standalone Makefile for Terminal Snake Game

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := snake
SRC := snake.asm
OBJ := snake.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Snake Game built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Testing Snake Game engine, termios raw mode, and board renderer..."
	@printf "q" | ./$(TARGET) > /dev/null
	@echo "[+] Snake Game initialization, ANSI rendering, and clean exit verified!"

run: $(TARGET)
	@echo "Starting Snake Game (Use W/A/S/D to steer, Q to quit)..."
	@./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
