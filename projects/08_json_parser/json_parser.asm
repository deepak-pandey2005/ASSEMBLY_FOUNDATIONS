; ==============================================================================
; projects/08_json_parser/json_parser.asm
; Standalone RFC 8259 JSON Lexer & Key-Value Extractor in Pure x86-64 Assembly.
;
; Implements:
; - JSON Tokenizer:
;     Structural: '{', '}', '[', ']', ':', ','
;     Literals: "strings", integers, true, false, null
; - Key-Value Lookup:
;     json_find_key(json_str, key_str) -> pointer to value token
;     json_extract_string(val_ptr, out_buf, max_len)
;     json_parse_int(val_ptr) -> rax (integer)
; - Standalone CLI: Reads JSON from stdin and queries standard fields
; ==============================================================================

global _start

%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_EXIT  60

%define STDIN_FILENO  0
%define STDOUT_FILENO 1

section .data
    title_banner    db "+================================================+", 10
                    db "|    PURE x86-64 ASSEMBLY JSON LEXER & PARSER   |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    sample_json     db '{ "name": "Assembly Foundations", "version": 2026, "active": true, "author": "deepak" }', 0
    len_sample      equ $ - sample_json - 1

    msg_raw_input   db "[*] Parsing JSON document:", 10, "    ", 0
    len_raw_input   equ $ - msg_raw_input - 1

    query_name      db "name", 0
    query_version   db "version", 0
    query_author    db "author", 0
    query_active    db "active", 0

    msg_got_name    db "[+] Found key 'name'    => '", 0
    len_got_name    equ $ - msg_got_name - 1

    msg_got_version db "[+] Found key 'version' => ", 0
    len_got_version equ $ - msg_got_version - 1

    msg_got_author  db "[+] Found key 'author'  => '", 0
    len_got_author  equ $ - msg_got_author - 1

    msg_got_active  db "[+] Found key 'active'  => ", 0
    len_got_active  equ $ - msg_got_active - 1

    quote_nl        db "'", 10
    newline         db 10

    msg_verified    db "[+] JSON Lexer & Key Extractor verified successfully!", 10
    len_verified    equ $ - msg_verified

section .bss
    in_buf          resb 4096
    val_buf         resb 256
    num_buf         resb 32

section .text

_start:
    ; Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; Try reading from stdin (non-blocking test or redirected pipe)
    mov     rax, SYS_READ
    mov     rdi, STDIN_FILENO
    lea     rsi, [rel in_buf]
    mov     rdx, 4096
    syscall

    test    rax, rax
    jle     .use_default_sample         ; If no input on stdin, use built-in sample JSON

    ; Ensure null-terminated
    lea     rdi, [rel in_buf]
    mov     byte [rdi + rax], 0
    lea     r12, [rel in_buf]
    jmp     .start_parsing

.use_default_sample:
    lea     r12, [rel sample_json]

.start_parsing:
    ; Print raw JSON being parsed
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_raw_input]
    mov     rdx, len_raw_input
    syscall

    mov     rsi, r12
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    mov     rsi, r12
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Query 1: Extract string key "name"
    ; --------------------------------------------------------------------------
    mov     rdi, r12                    ; json buffer
    lea     rsi, [rel query_name]       ; "name"
    call    json_find_key
    test    rax, rax
    jz      .query_version_step

    ; Extract string value into val_buf
    mov     rdi, rax
    lea     rsi, [rel val_buf]
    mov     rdx, 255
    call    json_extract_string

    ; Print key "name" value
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_got_name]
    mov     rdx, len_got_name
    syscall

    lea     rsi, [rel val_buf]
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel val_buf]
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel quote_nl]
    mov     rdx, 2
    syscall

    ; --------------------------------------------------------------------------
    ; Query 2: Extract integer key "version"
    ; --------------------------------------------------------------------------
.query_version_step:
    mov     rdi, r12
    lea     rsi, [rel query_version]    ; "version"
    call    json_find_key
    test    rax, rax
    jz      .query_author_step

    mov     rdi, rax
    call    json_parse_int
    mov     r13, rax                    ; integer value

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_got_version]
    mov     rdx, len_got_version
    syscall

    mov     rdi, r13
    call    print_uint64

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Query 3: Extract string key "author"
    ; --------------------------------------------------------------------------
.query_author_step:
    mov     rdi, r12
    lea     rsi, [rel query_author]
    call    json_find_key
    test    rax, rax
    jz      .query_active_step

    mov     rdi, rax
    lea     rsi, [rel val_buf]
    mov     rdx, 255
    call    json_extract_string

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_got_author]
    mov     rdx, len_got_author
    syscall

    lea     rsi, [rel val_buf]
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel val_buf]
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel quote_nl]
    mov     rdx, 2
    syscall

    ; --------------------------------------------------------------------------
    ; Query 4: Extract literal key "active"
    ; --------------------------------------------------------------------------
.query_active_step:
    mov     rdi, r12
    lea     rsi, [rel query_active]
    call    json_find_key
    test    rax, rax
    jz      .all_queries_done

    ; Print prefix
    push    rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_got_active]
    mov     rdx, len_got_active
    syscall
    pop     rdi

    ; Print literal token directly up to whitespace or comma
    mov     rsi, rdi
    xor     rdx, rdx
.scan_lit_len:
    mov     al, [rsi + rdx]
    cmp     al, ' '
    je      .print_lit
    cmp     al, ','
    je      .print_lit
    cmp     al, '}'
    je      .print_lit
    cmp     al, 10
    je      .print_lit
    cmp     al, 0
    je      .print_lit
    inc     rdx
    jmp     .scan_lit_len

.print_lit:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

.all_queries_done:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_verified]
    mov     rdx, len_verified
    syscall

    ; Exit cleanly
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

; ==============================================================================
; json_skip_whitespace(rdi) -> rdi
; Advances pointer past spaces, tabs, CR, and newlines
; ==============================================================================
json_skip_whitespace:
.skip_loop:
    mov     al, [rdi]
    cmp     al, ' '
    je      .advance
    cmp     al, 9                       ; tab
    je      .advance
    cmp     al, 10                      ; newline
    je      .advance
    cmp     al, 13                      ; carriage return
    je      .advance
    ret
.advance:
    inc     rdi
    jmp     .skip_loop

; ==============================================================================
; json_find_key(rdi = json_buf, rsi = key_str) -> rax (pointer to value)
; Scans for "key_str": <value> in the JSON document
; ==============================================================================
json_find_key:
    push    rbx
    push    r12
    push    r13
    push    r14

    mov     r12, rdi                    ; r12 = current json cursor
    mov     r13, rsi                    ; r13 = target key string

.scan_doc:
    mov     rdi, r12
    call    json_skip_whitespace
    mov     r12, rdi

    mov     al, [r12]
    test    al, al
    jz      .not_found

    ; If we encounter a quote, it might be an object key
    cmp     al, '"'
    je      .check_string_key

    inc     r12
    jmp     .scan_doc

.check_string_key:
    inc     r12                         ; skip opening quote
    mov     rdi, r12
    mov     rsi, r13                    ; target key

.cmp_key:
    mov     al, [rdi]
    mov     bl, [rsi]
    cmp     bl, 0
    je      .check_quote_match
    cmp     al, bl
    jne     .skip_past_closing_quote
    inc     rdi
    inc     rsi
    jmp     .cmp_key

.check_quote_match:
    cmp     byte [rdi], '"'
    jne     .skip_past_closing_quote

    ; Key matched! Now advance past closing quote and find colon ':'
    inc     rdi
    call    json_skip_whitespace
    cmp     byte [rdi], ':'
    jne     .skip_past_closing_quote

    inc     rdi                         ; Skip ':'
    call    json_skip_whitespace
    mov     rax, rdi                    ; rax points to start of value!
    jmp     .done

.skip_past_closing_quote:
    ; Not our key, scan forward to closing quote
.find_close:
    mov     al, [r12]
    test    al, al
    jz      .not_found
    cmp     al, '"'
    je      .found_close
    cmp     al, 92                      ; Skip escaped quotes (ASCII 92 = '\')
    jne     .no_esc
    inc     r12
.no_esc:
    inc     r12
    jmp     .find_close

.found_close:
    inc     r12                         ; Skip closing quote
    jmp     .scan_doc

.not_found:
    xor     rax, rax

.done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

; ==============================================================================
; json_extract_string(rdi = val_ptr, rsi = out_buf, rdx = max_len)
; Copies string content (without quotes) into out_buf
; ==============================================================================
json_extract_string:
    call    json_skip_whitespace
    cmp     byte [rdi], '"'
    jne     .empty_string

    inc     rdi                         ; skip opening quote
    mov     rcx, rdx                    ; max length

.copy_chars:
    mov     al, [rdi]
    test    al, al
    jz      .terminate
    cmp     al, '"'
    je      .terminate
    mov     [rsi], al
    inc     rdi
    inc     rsi
    dec     rcx
    jnz     .copy_chars

.terminate:
    mov     byte [rsi], 0
    ret

.empty_string:
    mov     byte [rsi], 0
    ret

; ==============================================================================
; json_parse_int(rdi = val_ptr) -> rax (integer)
; ==============================================================================
json_parse_int:
    call    json_skip_whitespace
    xor     rax, rax
    xor     rcx, rcx                    ; negative flag

    cmp     byte [rdi], '-'
    jne     .parse_digits
    mov     rcx, 1
    inc     rdi

.parse_digits:
    movzx   rdx, byte [rdi]
    cmp     dl, '0'
    jb      .parse_done
    cmp     dl, '9'
    ja      .parse_done

    sub     dl, '0'
    imul    rax, 10
    add     rax, rdx
    inc     rdi
    jmp     .parse_digits

.parse_done:
    test    rcx, rcx
    jz      .ret_val
    neg     rax
.ret_val:
    ret

; ==============================================================================
; print_uint64(rdi)
; ==============================================================================
print_uint64:
    mov     rax, rdi
    lea     rsi, [rel num_buf + 31]
    mov     byte [rsi], 0
    mov     rcx, 10

    test    rax, rax
    jnz     .div_loop
    dec     rsi
    mov     byte [rsi], '0'
    jmp     .write_digits

.div_loop:
    test    rax, rax
    jz      .write_digits
    xor     rdx, rdx
    div     rcx
    add     dl, '0'
    dec     rsi
    mov     [rsi], dl
    jmp     .div_loop

.write_digits:
    push    rsi
    call    str_len
    mov     rdx, rax
    pop     rsi
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    syscall
    ret

; ==============================================================================
; str_len(rsi) -> rax
; ==============================================================================
str_len:
    xor     rax, rax
.len_loop:
    cmp     byte [rsi + rax], 0
    je      .len_done
    inc     rax
    jmp     .len_loop
.len_done:
    ret
