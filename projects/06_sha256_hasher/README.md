# Standalone Project 06: Pure x86-64 Assembly SHA-256 Hasher CLI

A standalone implementation of the NIST FIPS 180-4 standard **SHA-256** (Secure Hash Algorithm 256-bit) cryptographic hash function in pure Linux x86-64 assembly with **zero standard library (`libc`) dependencies**.

---

## 🎯 Architecture & Specifications

- **Pure x86-64 Assembly**: Assembled with NASM into a standalone ELF64 binary.
- **FIPS 180-4 Compliant**:
  - Initial 256-bit hash values ($H_0 \dots H_7$).
  - 64 round constant table ($K_0 \dots K_{63}$).
  - Full bitwise operations:
    - $\text{Ch}(e, f, g) = (e \land f) \oplus (\neg e \land g)$
    - $\text{Maj}(a, b, c) = (a \land b) \oplus (a \land c) \oplus (b \land c)$
    - $\Sigma_0(a) = \text{ROTR}^2(a) \oplus \text{ROTR}^{13}(a) \oplus \text{ROTR}^{22}(a)$
    - $\Sigma_1(e) = \text{ROTR}^6(e) \oplus \text{ROTR}^{11}(e) \oplus \text{ROTR}^{25}(e)$
    - $\sigma_0(x) = \text{ROTR}^7(x) \oplus \text{ROTR}^{18}(x) \oplus \text{SHR}^3(x)$
    - $\sigma_1(x) = \text{ROTR}^{17}(x) \oplus \text{ROTR}^{19}(x) \oplus \text{SHR}^{10}(x)$
  - 64-word message schedule extension ($W_0 \dots W_{63}$).
  - Standard SHA-256 padding (append `0x80`, zeroes, and 64-bit big-endian length).
- **Dual Mode Operation**:
  - Hashing string/files or verifying known vectors.
  - Can read input from standard input or a sample input file.

---

## 🚀 Building & Testing

```bash
make          # Build the standalone sha256 binary
make test     # Test against standard NIST test vector ("abc") and custom input
make clean    # Remove build artifacts
```
