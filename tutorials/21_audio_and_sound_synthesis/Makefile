# Standalone Makefile for Module: 21_audio_and_sound_synthesis
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := synth_audio
SRC := synth_audio.asm
OBJ := synth_audio.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 21_audio_and_sound_synthesis ==="
	@./synth_audio >/dev/null && [ -f sound.wav ] && echo '[+] sound.wav generated successfully!' && rm -f sound.wav
	@echo "[+] Module 21_audio_and_sound_synthesis test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
