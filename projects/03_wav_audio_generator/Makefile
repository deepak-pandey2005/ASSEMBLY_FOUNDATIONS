# Standalone Makefile for WAV Audio Generator

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := synth
SRC := synth.asm
OBJ := synth.o

.PHONY: all run clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Synth built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET) output.wav
