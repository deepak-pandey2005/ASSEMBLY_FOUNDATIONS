# Standalone Makefile for Module: 15_simd_avx_vectorization
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := avx2_vector_add
SRC := avx2_vector_add.asm
OBJ := avx2_vector_add.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 15_simd_avx_vectorization ==="
	@./avx2_vector_add >/dev/null && echo '[+] avx2_vector_add executed successfully!'
	@echo "[+] Module 15_simd_avx_vectorization test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
