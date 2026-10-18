# Module 17: Interoperability — C & Python FFI Integration

## 🎯 Objectives
- Understand how Assembly interacts with higher-level languages.
- Learn the Foreign Function Interface (FFI) boundary:
  - Calling handwritten assembly functions from C.
  - Compiling assembly into a Dynamic Shared Object (`.so`).
  - Calling native assembly functions from Python via `ctypes`.
  - Understanding GCC Inline Assembly (`__asm__ volatile`).

---

## 1. Exporting Assembly to C and Python

To make an assembly function callable from C or Python:
1. Export the symbol using `global <function_name>`.
2. Follow the System V AMD64 ABI:
   - First 6 integer/pointer arguments: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.
   - Return value: `rax`.
   - Preserve callee-saved registers (`rbx`, `rsp`, `rbp`, `r12`-`r15`).

### Compiling to Shared Library (`.so`):
```bash
nasm -f elf64 -w-implicit-abs-deprecated asm_math.asm -o asm_math.o
gcc -shared asm_math.o -o libasm_math.so
```

---

## 2. Calling from Python via `ctypes`

```python
import ctypes

# Load native assembly shared library
lib = ctypes.CDLL("./libasm_math.so")

# Configure return type and arguments
lib.fast_multiply_add.restype = ctypes.c_int64
lib.fast_multiply_add.argtypes = [ctypes.c_int64, ctypes.c_int64, ctypes.c_int64]

# Call assembly function directly!
result = lib.fast_multiply_add(10, 5, 7) # (10 * 5) + 7 = 57
print(f"Result from Assembly: {result}")
```

---

## 3. Hands-on Code Files in this Module
- [`asm_math.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/asm_math.asm) - High performance FFI math kernel.
- [`test_c.c`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_c.c) - C host program linking assembly.
- [`test_py.py`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/17_c_and_python_interop/test_py.py) - Python ctypes script invoking the compiled shared library.
