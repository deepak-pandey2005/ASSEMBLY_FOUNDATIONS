# Standalone Makefile for Pure Assembly Brainfuck JIT Compiler

NASM := nasm
NASMFLAGS := -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD := ld
LDFLAGS :=

TARGET := asm_bfjit
SRC := bf_jit.asm
OBJ := bf_jit.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@
	@echo "=========================================================="
	@echo " Brainfuck JIT Compiler built! Run with: ./$(TARGET)"
	@echo "=========================================================="

test: $(TARGET)
	@echo "=== 1. Testing Built-in JIT Benchmark (Hello World) ==="
	./$(TARGET)
	@echo "=== 2. Testing Inline JIT Code Compilation (-e) ==="
	./$(TARGET) -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++."
	@echo "=== 3. Testing Brainfuck Source File Compilation ==="
	@echo "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>." > test_program.bf
	./$(TARGET) test_program.bf
	@rm -f test_program.bf
	@echo "=== Brainfuck JIT Verification Completed Successfully! ==="

run: test

clean:
	rm -f $(OBJ) $(TARGET) test_program.bf
