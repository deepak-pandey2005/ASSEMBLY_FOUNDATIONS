# Standalone Project 08: Pure x86-64 Assembly JSON Lexer & Parser (`asm_json`)

A high-performance, streaming RFC 8259-compliant JSON tokenizer, lexer, and AST value extractor written entirely in pure x86-64 assembly with **zero external libraries or C runtime dependencies**.

---

## 🎯 Architecture & Specifications

- **Zero-Copy Lexer & Tokenizer**:
  - Direct byte-by-byte scanning with whitespace skipping (spaces, tabs, carriage returns, newlines).
  - Categorizes JSON tokens into standard types:
    - `TOKEN_OBJECT_OPEN` (`{`), `TOKEN_OBJECT_CLOSE` (`}`)
    - `TOKEN_ARRAY_OPEN` (`[`), `TOKEN_ARRAY_CLOSE` (`]`)
    - `TOKEN_COLON` (`:`), `TOKEN_COMMA` (`,`)
    - `TOKEN_STRING` (`"..."`) with escape sequence handling (`\"`, `\\`, `\n`, `\t`)
    - `TOKEN_NUMBER` (signed integers, multi-digit scanning)
    - `TOKEN_BOOLEAN` (`true` / `false`)
    - `TOKEN_NULL` (`null`)
- **Key-Value Lookup Engine**:
  - Implements `json_get_string(json_buf, "key")` and `json_get_int(json_buf, "key")`.
  - Searches JSON object keys and extracts the associated scalar or string value into user buffers.
- **Standalone CLI Execution**:
  - Reads JSON text from standard input or files via `sys_read`.
  - Parses payload structure and prints formatted key-value lookups with syntax highlighting in ANSI terminal colors.

---

## 🚀 Building & Testing

```bash
make          # Build the standalone asm_json binary
make test     # Test JSON lexing, tokenization, and key extraction against sample payload
make clean    # Remove build artifacts
```
