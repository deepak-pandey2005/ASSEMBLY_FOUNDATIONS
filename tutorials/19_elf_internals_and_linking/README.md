# Module 19: ELF Internals & Linker Foundations

## 🎯 Objectives
- Understand the Executable and Linkable Format (ELF-64) file structure.
- Learn ELF file components:
  - ELF Header (`Elf64_Ehdr`): Magic bytes `0x7F 'E' 'L' 'F'`, architecture type, entry point address (`e_entry`).
  - Program Headers (`Elf64_Phdr`): Segments loaded by kernel (`PT_LOAD`, flags `PF_R`, `PF_W`, `PF_X`).
  - Section Headers (`Elf64_Shdr`): Symbols, relocations, debug info (`.symtab`, `.strtab`, `.rela.text`).
- Master the difference between Relocatable Object Files (`.o`) and Executable Files.
- Inspect binary internals using `readelf`, `objdump`, and `nm`.

---

## 1. The 64-bit ELF Header Layout

At offset 0 of every Linux executable:
```text
Offset  Size  Field
0x00    4     e_ident[0..3] = 0x7F, 'E', 'L', 'F'
0x04    1     EI_CLASS      = 2 (64-bit)
0x05    1     EI_DATA       = 1 (Little-Endian)
0x06    1     EI_VERSION    = 1
0x07    1     EI_OSABI      = 0 (System V Linux)
...
0x18    8     e_entry       = Virtual address where CPU begins execution!
0x20    8     e_phoff       = Program header table offset in file
0x28    8     e_shoff       = Section header table offset in file
```

---

## 2. Reading ELF Information via CLI Tools

- Inspect ELF Header:
  ```bash
  readelf -h bin/hello_64
  ```
- Inspect Program Headers (Memory Segments):
  ```bash
  readelf -l bin/hello_64
  ```
- Disassemble Machine Code directly from binary:
  ```bash
  objdump -M intel -d bin/hello_64
  ```

---

## 3. Hands-on Code Files in this Module
- [`elf_inspector.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/19_elf_internals_and_linking/elf_inspector.asm) - Program that self-inspects its own ELF header in memory and prints its entry point address.
