# Standalone Makefile for Module: 12_framebuffer_and_graphics
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := render_pattern
SRC := render_pattern.asm
OBJ := render_pattern.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 12_framebuffer_and_graphics ==="
	@./render_pattern >/dev/null && [ -f canvas.ppm ] && echo '[+] canvas.ppm generated successfully!' && rm -f canvas.ppm
	@echo "[+] Module 12_framebuffer_and_graphics test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
