# Standalone Makefile for 3D Sphere Raytracer

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := raytrace
SRC := raytrace.asm
OBJ := raytrace.o

.PHONY: all run clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Raytracer built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET) render.ppm
