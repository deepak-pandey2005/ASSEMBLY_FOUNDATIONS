learning Assembly X86.

echo "set disassembly-flavor intel" > ~/.gdbint

nasm -f elf -o data.o data.s

ld -m elf_i386 -o data data.o