# Standalone Makefile for 3D Sphere Raytracer

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := raytrace
SRC := raytrace.asm
OBJ := raytrace.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Raytracer built successfully! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "Rendering 3D sphere raytraced image..."
	@rm -f render.ppm
	@./$(TARGET)
	@if [ ! -f render.ppm ]; then echo "[-] Error: render.ppm was not created!" && exit 1; fi
	@SIZE=$$(stat -c%s render.ppm); \
	if [ "$$SIZE" -eq 307215 ]; then \
		echo "[+] File size verified: $$SIZE bytes (15-byte P6 header + 320x320x3 RGB pixels)"; \
	else \
		echo "[-] Unexpected file size: $$SIZE bytes (expected 307215)"; \
		exit 1; \
	fi
	@HEADER=$$(head -n 1 render.ppm); \
	if [ "$$HEADER" = "P6" ]; then \
		echo "[+] Valid Netpbm PPM binary P6 format verified!"; \
	else \
		echo "[-] Invalid header: $$HEADER"; \
		exit 1; \
	fi
	@echo "[+] Standalone Project 04 (3D Sphere Raytracer) Test PASSED!"

run: test
	@echo "[*] render.ppm is ready to view with feh, display, or any image viewer."

clean:
	rm -f $(OBJ) $(TARGET) render.ppm
