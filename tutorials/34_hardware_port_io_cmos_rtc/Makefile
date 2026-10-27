# Standalone Makefile for Module: 34_hardware_port_io_cmos_rtc
NASM ?= nasm
NASMFLAGS ?= -f elf64 -g -F dwarf -w-implicit-abs-deprecated
LD ?= ld
LDFLAGS ?=

TARGET := cmos_rtc
SRC := cmos_rtc.asm
OBJ := cmos_rtc.o

.PHONY: all run test clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "=== Testing Module: 34_hardware_port_io_cmos_rtc ==="
	@./cmos_rtc >/dev/null && echo '[+] cmos_rtc executed successfully!'
	@echo "[+] Module 34_hardware_port_io_cmos_rtc test passed!"

clean:
	rm -f $(OBJ) $(TARGET)
