#!/usr/bin/env python3
import ctypes
import os
import sys

def main():
    local_so = os.path.abspath(os.path.join(os.path.dirname(__file__), "libasm_math.so"))
    bin_so = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../bin/libasm_math.so"))
    so_path = local_so if os.path.exists(local_so) else bin_so
    if not os.path.exists(so_path):
        print(f"[-] Shared library not found at: {local_so} or {bin_so}")
        sys.exit(1)

    lib = ctypes.CDLL(so_path)

    # Prototype: int64_t fast_multiply_add(int64_t, int64_t, int64_t)
    lib.fast_multiply_add.restype = ctypes.c_int64
    lib.fast_multiply_add.argtypes = [ctypes.c_int64, ctypes.c_int64, ctypes.c_int64]

    # Prototype: int64_t fast_factorial(int64_t)
    lib.fast_factorial.restype = ctypes.c_int64
    lib.fast_factorial.argtypes = [ctypes.c_int64]

    fma = lib.fast_multiply_add(12, 4, 2)    # (12 * 4) + 2 = 50
    fact = lib.fast_factorial(6)            # 6! = 720

    print(f"[Python ctypes] fast_multiply_add(12, 4, 2) = {fma}")
    print(f"[Python ctypes] fast_factorial(6) = {fact}")

    assert fma == 50, f"Expected 50, got {fma}"
    assert fact == 720, f"Expected 720, got {fact}"
    print("[+] Python to Assembly ctypes FFI verification PASSED!")

if __name__ == "__main__":
    main()
