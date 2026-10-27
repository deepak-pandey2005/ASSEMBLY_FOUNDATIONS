# Standalone Makefile for WAV Audio Generator

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := synth
SRC := synth.asm
OBJ := synth.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Synth built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Generating 44.1kHz 16-bit Stereo WAV audio..."
	@rm -f output.wav
	@./$(TARGET)
	@if [ ! -f output.wav ]; then echo "[-] Error: output.wav was not created!" && exit 1; fi
	@SIZE=$$(stat -c%s output.wav); \
	if [ "$$SIZE" -eq 352844 ]; then \
		echo "[+] File size verified: $$SIZE bytes (44-byte RIFF header + 88,200 4-byte frames)"; \
	else \
		echo "[-] Unexpected file size: $$SIZE bytes (expected 352844)"; \
		exit 1; \
	fi
	@MAGIC=$$(head -c 4 output.wav); \
	if [ "$$MAGIC" = "RIFF" ]; then \
		echo "[+] Valid RIFF container header confirmed!"; \
	else \
		echo "[-] Invalid header: $$MAGIC"; \
		exit 1; \
	fi
	@echo "[+] Standalone Project 03 (WAV Audio Generator) Test PASSED!"

run: test
	@echo "[*] output.wav is ready for playback with aplay or any audio player."

clean:
	rm -f $(OBJ) $(TARGET) output.wav
