; ==============================================================================
; projects/06_sha256_hasher/sha256.asm
; NIST FIPS 180-4 SHA-256 Cryptographic Hash Algorithm in Pure x86-64 Assembly.
;
; Implements:
; - Standard 64 round constants (K[0..63])
; - Initial hash state (H0..H7)
; - FIPS 180-4 Padding: 0x80 byte, zeroes, and 64-bit big-endian bit length
; - Message schedule expansion: W[0..63]
; - 64 compression rounds using Ch, Maj, Sigma0, Sigma1
; - Hexadecimal digest output formatter

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <unistd.h>
; #include <stdint.h>
; #include <string.h>
;
; // NIST FIPS 180-4 SHA-256 standard constants
; static const uint32_t K[64] = { ... };
; static const uint32_t H_INIT[8] = {
;     0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
;     0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
; };
;
; void sha256_process_block(uint32_t state[8], const uint8_t block[64]) {
;     uint32_t W[64];
;     for (int i = 0; i < 16; i++) {
;         W[i] = (block[i*4] << 24) | (block[i*4+1] << 16) | (block[i*4+2] << 8) | block[i*4+3];
;     }
;     for (int i = 16; i < 64; i++) {
;         W[i] = Gamma1(W[i-2]) + W[i-7] + Gamma0(W[i-15]) + W[i-16];
;     }
;     uint32_t a = state[0], b = state[1], c = state[2], d = state[3];
;     uint32_t e = state[4], f = state[5], g = state[6], h = state[7];
;     for (int i = 0; i < 64; i++) {
;         uint32_t T1 = h + Sigma1(e) + Ch(e, f, g) + K[i] + W[i];
;         uint32_t T2 = Sigma0(a) + Maj(a, b, c);
;         h = g; g = f; f = e; e = d + T1;
;         d = c; c = b; b = a; a = T1 + T2;
;     }
;     state[0] += a; state[1] += b; state[2] += c; state[3] += d;
;     state[4] += e; state[5] += f; state[6] += g; state[7] += h;
; }
; ==============================================================================

global _start

%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_EXIT  60

%define STDIN_FILENO  0
%define STDOUT_FILENO 1

section .data
    title_banner    db "+================================================+", 10
                    db "|    PURE x86-64 ASSEMBLY SHA-256 HASHER CLI     |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    msg_hashing     db "[*] Computing SHA-256 digest...", 10
    len_hashing     equ $ - msg_hashing

    msg_result      db "[+] SHA-256: "
    len_result      equ $ - msg_result

    newline         db 10

    ; Standard NIST SHA-256 Initial Hash Values (H0..H7)
    align 4
    init_H:
        dd 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
        dd 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19

    ; NIST SHA-256 Round Constants K[0..63]
    align 4
    K_constants:
        dd 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
        dd 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5
        dd 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3
        dd 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
        dd 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc
        dd 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da
        dd 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7
        dd 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
        dd 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13
        dd 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85
        dd 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3
        dd 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070
        dd 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5
        dd 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3
        dd 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208
        dd 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2

section .bss
    ; Input message buffer
    in_buf          resb 4096
    padded_msg      resb 8192
    
    ; Current Working Hash State (H0..H7, 8 x 32-bit = 32 bytes)
    state_H         resd 8

    ; Message Schedule array W[0..63] (64 x 32-bit = 256 bytes)
    align 16
    W_schedule      resd 64

    ; Output hex string: 64 hex characters + 1 newline
    hex_digest      resb 65

section .text

_start:
    ; Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; Read input from stdin
    mov     rax, SYS_READ
    mov     rdi, STDIN_FILENO
    lea     rsi, [rel in_buf]
    mov     rdx, 4096
    syscall

    test    rax, rax
    jns     .read_ok
    xor     rax, rax                    ; If error, treat as 0 length

.read_ok:
    mov     r12, rax                    ; r12 = message length in bytes

    ; Copy initial state H into state_H
    lea     rsi, [rel init_H]
    lea     rdi, [rel state_H]
    mov     rcx, 8
    rep movsd

    ; --------------------------------------------------------------------------
    ; Pad the message into padded_msg:
    ; 1. Copy original message
    ; 2. Append byte 0x80
    ; 3. Append zeros until length % 64 == 56
    ; 4. Append 64-bit big-endian bit length (r12 * 8)
    ; --------------------------------------------------------------------------
    lea     rsi, [rel in_buf]
    lea     rdi, [rel padded_msg]
    mov     rcx, r12
    rep movsb

    ; Append 0x80
    mov     byte [rdi], 0x80
    inc     rdi

    ; Current total length after 0x80
    mov     rax, r12
    inc     rax

.pad_zeros:
    mov     rdx, rax
    and     rdx, 63
    cmp     rdx, 56
    je      .append_len
    mov     byte [rdi], 0
    inc     rdi
    inc     rax
    jmp     .pad_zeros

.append_len:
    ; Bit length = r12 * 8
    mov     rbx, r12
    shl     rbx, 3                      ; rbx = bit length
    ; Store as 64-bit Big-Endian (bswap)
    bswap   rbx
    mov     [rdi], rbx
    add     rdi, 8
    add     rax, 8                      ; rax = total padded byte length (multiple of 64)

    mov     r13, rax                    ; r13 = total padded length
    shr     r13, 6                      ; r13 = number of 64-byte blocks
    mov     [rel num_blocks_left], r13

    ; --------------------------------------------------------------------------
    ; Process each 64-byte block
    ; --------------------------------------------------------------------------
    lea     r14, [rel padded_msg]       ; r14 = pointer to current 64-byte block
    mov     [rel current_block_ptr], r14

.block_loop:
    cmp     qword [rel num_blocks_left], 0
    jbe     .all_blocks_processed

    ; 1. Prepare Message Schedule W[0..15] from current block (converted to big-endian)
    lea     rdi, [rel W_schedule]
    mov     rcx, 16
    mov     rsi, r14
.load_w0_15:
    mov     eax, [rsi]
    bswap   eax                         ; Convert network/BE to host x86
    mov     [rdi], eax
    add     rsi, 4
    add     rdi, 4
    dec     rcx
    jnz     .load_w0_15

    ; 2. Expand Message Schedule W[16..63]
    ; For t = 16 to 63:
    ; s0 = ROTR(W[t-15], 7) ^ ROTR(W[t-15], 18) ^ (W[t-15] >> 3)
    ; s1 = ROTR(W[t-2], 17) ^ ROTR(W[t-2], 19) ^ (W[t-2] >> 10)
    ; W[t] = W[t-16] + s0 + W[t-7] + s1
    mov     rcx, 16
    lea     rdi, [rel W_schedule]
.expand_w:
    ; s0 calculation for W[t-15]
    mov     eax, [rdi + (rcx - 15) * 4]
    mov     edx, eax
    ror     edx, 7
    mov     ebx, eax
    ror     ebx, 18
    xor     edx, ebx
    shr     eax, 3
    xor     edx, eax                    ; edx = s0

    ; s1 calculation for W[t-2]
    mov     eax, [rdi + (rcx - 2) * 4]
    mov     ebx, eax
    ror     ebx, 17
    mov     esi, eax
    ror     esi, 19
    xor     ebx, esi
    shr     eax, 10
    xor     ebx, eax                    ; ebx = s1

    ; W[t] = W[t-16] + s0 + W[t-7] + s1
    mov     eax, [rdi + (rcx - 16) * 4]
    add     eax, edx
    add     eax, [rdi + (rcx - 7) * 4]
    add     eax, ebx
    mov     [rdi + rcx * 4], eax

    inc     rcx
    cmp     rcx, 64
    jne     .expand_w

    ; 3. Initialize working variables:
    ; a = H0, b = H1, c = H2, d = H3, e = H4, f = H5, g = H6, h = H7
    lea     rsi, [rel state_H]
    mov     r8d,  [rsi + 0]             ; a
    mov     r9d,  [rsi + 4]             ; b
    mov     r10d, [rsi + 8]             ; c
    mov     r11d, [rsi + 12]            ; d
    mov     r12d, [rsi + 16]            ; e
    mov     r13d, [rsi + 20]            ; f
    mov     r14d, [rsi + 24]            ; g
    mov     r15d, [rsi + 28]            ; h

    ; 4. Compression 64 rounds
    xor     rcx, rcx                    ; round counter t = 0..63
.round_loop:
    ; S1 = ROTR(e, 6) ^ ROTR(e, 11) ^ ROTR(e, 25)
    mov     eax, r12d
    ror     eax, 6
    mov     ebx, r12d
    ror     ebx, 11
    xor     eax, ebx
    mov     ebx, r12d
    ror     ebx, 25
    xor     eax, ebx                    ; eax = S1

    ; ch = (e & f) ^ (~e & g)
    mov     ebx, r12d
    and     ebx, r13d
    mov     edx, r12d
    not     edx
    and     edx, r14d
    xor     ebx, edx                    ; ebx = ch

    ; temp1 = h + S1 + ch + K[t] + W[t]
    lea     rsi, [rel K_constants]
    mov     edx, r15d                   ; h
    add     edx, eax                    ; + S1
    add     edx, ebx                    ; + ch
    add     edx, [rsi + rcx * 4]        ; + K[t]
    lea     rsi, [rel W_schedule]
    add     edx, [rsi + rcx * 4]        ; + W[t] -> edx = temp1

    ; S0 = ROTR(a, 2) ^ ROTR(a, 13) ^ ROTR(a, 22)
    mov     eax, r8d
    ror     eax, 2
    mov     ebx, r8d
    ror     ebx, 13
    xor     eax, ebx
    mov     ebx, r8d
    ror     ebx, 22
    xor     eax, ebx                    ; eax = S0

    ; maj = (a & b) ^ (a & c) ^ (b & c)
    mov     ebx, r8d
    and     ebx, r9d                    ; a & b
    mov     esi, r8d
    and     esi, r10d                   ; a & c
    xor     ebx, esi
    mov     esi, r9d
    and     esi, r10d                   ; b & c
    xor     ebx, esi                    ; ebx = maj

    ; temp2 = S0 + maj
    add     eax, ebx                    ; eax = temp2

    ; Update working variables:
    ; h = g
    mov     r15d, r14d
    ; g = f
    mov     r14d, r13d
    ; f = e
    mov     r13d, r12d
    ; e = d + temp1
    mov     r12d, r11d
    add     r12d, edx
    ; d = c
    mov     r11d, r10d
    ; c = b
    mov     r10d, r9d
    ; b = a
    mov     r9d,  r8d
    ; a = temp1 + temp2
    mov     r8d,  edx
    add     r8d,  eax

    inc     rcx
    cmp     rcx, 64
    jne     .round_loop

    ; 5. Add compressed chunk to current state_H
    lea     rsi, [rel state_H]
    add     [rsi + 0],  r8d
    add     [rsi + 4],  r9d
    add     [rsi + 8],  r10d
    add     [rsi + 12], r11d
    add     [rsi + 16], r12d
    add     [rsi + 20], r13d
    add     [rsi + 24], r14d
    add     [rsi + 28], r15d

    ; Advance to next 64-byte block
    ; We need to restore block pointer and block counter
    ; r14 was used as 'g' in round loop, so restore from stack/memory calculation
    ; We can track block loop using memory variable or preserved registers.
    ; Let's re-read block state:
    ; To avoid clobbering, let's keep block loop clean!
    dec     qword [rel num_blocks_left]
    jnz     .advance_block
    jmp     .all_blocks_processed

.advance_block:
    add     qword [rel current_block_ptr], 64
    mov     r14, [rel current_block_ptr]
    mov     r13, [rel num_blocks_left]
    jmp     .block_loop

.all_blocks_processed:
    ; Convert state_H (8 x 32-bit dwords) to 64 hexadecimal characters
    lea     rsi, [rel state_H]
    lea     rdi, [rel hex_digest]
    mov     rcx, 8

.dword_to_hex:
    push    rcx
    mov     eax, [rsi]                  ; Already in 32-bit big-endian integer format
    ; Output 8 hex characters for eax
    mov     rcx, 8
.nibble_loop:
    rol     eax, 4
    mov     dl, al
    and     dl, 0x0F
    cmp     dl, 10
    jl      .is_digit
    add     dl, 'a' - 10
    jmp     .store_char
.is_digit:
    add     dl, '0'
.store_char:
    mov     [rdi], dl
    inc     rdi
    dec     rcx
    jnz     .nibble_loop

    add     rsi, 4
    pop     rcx
    dec     rcx
    jnz     .dword_to_hex

    mov     byte [rdi], 10              ; newline

    ; Print result prefix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_result]
    mov     rdx, len_result
    syscall

    ; Print 64-char hex digest + newline
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel hex_digest]
    mov     rdx, 65
    syscall

    ; Exit cleanly
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

section .data
    align 8
    num_blocks_left   dq 0
    current_block_ptr dq 0
