# Module 07: String & Array Instructions (`REP`, `MOVS`, `STOS`, `SCAS`)

## 🎯 Objectives
- Understand hardware-accelerated string instructions:
  - `MOVSB` / `MOVSW` / `MOVSD` / `MOVSQ`: Move string byte/word/dword/qword.
  - `STOSB` / `STOSQ`: Store to string (fill memory like `memset`).
  - `LODSB` / `LODSQ`: Load from string.
  - `SCASB` / `SCASQ`: Scan string (search character like `memchr` / `strlen`).
- Master Direction Flag (`DF`) via `CLD` (Clear Direction Flag = forward) and `STD` (Set Direction Flag = backward).
- Master Repeat prefixes: `REP`, `REPE` / `REPZ`, `REPNE` / `REPNZ`.
- Implement practical string operations: `strlen`, `strcpy`, and string reversal.

---

## 1. Hardware String Registers Convention

String instructions use fixed registers:
- `RSI`: Source Index pointer (`[rsi]`)
- `RDI`: Destination Index pointer (`[rdi]`)
- `RCX`: Counter (number of items to repeat)
- `RAX` / `AL`: Accumulator (holds value to search for or store)

```text
cld                   ; Clear direction flag -> DF=0 (Pointers increment)
rep stosb             ; Fill memory at [RDI] with byte in AL, repeated RCX times!
```

---

## 2. Implementing `strlen` with `SCASB`

```nasm
; RDI = pointer to null-terminated string
; Returns length in RAX
strlen_scas:
    mov rcx, -1             ; Set RCX to maximum possible value
    xor al, al              ; Byte to find: '\0' (0)
    cld                     ; Scan forward
    repne scasb             ; Scan until byte matches AL (0) or RCX runs out
    not rcx                 ; Invert RCX
    dec rcx                 ; rcx now contains the exact length!
    mov rax, rcx
    ret
```

---

## 3. Hands-on Code Files in this Module
- [`strlen_reverse.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/strlen_reverse.asm) - In-place string length calculation and string reversal.
- [`array_sum.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/07_string_and_arrays/array_sum.asm) - Array manipulation, copy, and transformation.
