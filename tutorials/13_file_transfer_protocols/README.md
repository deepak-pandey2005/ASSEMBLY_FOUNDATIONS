# Module 13: File Transfer Protocols & Data Encoding

## 🎯 Objectives
- Understand how binary payloads are safely transferred across text-only protocols (e.g., HTTP, email, DNS): **Base64 Encoding & Decoding**.
- Master bit manipulation across byte boundaries:
  - Base64 takes 3 binary bytes (24 bits) and maps them into 4 printable ASCII characters (6 bits each).
  - Understand bit masking (`AND`), bit shifting (`SHL`, `SHR`), and lookup table substitution.
- Implement high-speed file chunk streaming and binary-to-text serialization in pure assembly.

---

## 1. How Base64 Mathematical Encoding Works

A group of 3 8-bit bytes contains 24 bits:
```text
Byte 0: [b7 b6 b5 b4 b3 b2 b1 b0]
Byte 1: [b7 b6 b5 b4 b3 b2 b1 b0]
Byte 2: [b7 b6 b5 b4 b3 b2 b1 b0]
```

These 24 bits are re-partitioned into four 6-bit numbers ($2^6 = 64$ possible values):
```text
Index 0: [b7 b6 b5 b4 b3 b2]           (Byte 0 >> 2)
Index 1: [b1 b0] + [b7 b6 b5 b4]       ((Byte 0 & 3) << 4) | (Byte 1 >> 4)
Index 2: [b3 b2 b1 b0] + [b7 b6]       ((Byte 1 & 15) << 2) | (Byte 2 >> 6)
Index 3: [b5 b4 b3 b2 b1 b0]           (Byte 2 & 63)
```

Each 6-bit index selects an ASCII character from the standard table:
`"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"`

---

## 2. Hands-on Code Files in this Module
- [`base64_encoder.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/13_file_transfer_protocols/base64_encoder.asm) - Complete binary-to-Base64 encoder reading raw data and encoding it to stdout.
