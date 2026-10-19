# Standalone Makefile for Terminal Snake Game

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := snake
SRC := snake.asm
OBJ := snake.o

.PHONY: all run clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Snake Game built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
