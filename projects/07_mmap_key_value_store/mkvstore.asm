; ==============================================================================
; projects/07_mmap_key_value_store/mkvstore.asm
; Standalone Persistent Memory-Mapped Key-Value Store in Pure x86-64 Assembly.
;
; Implements:
; - File creation & sizing via sys_open, sys_ftruncate
; - Zero-copy memory mapping via sys_mmap (MAP_SHARED) & sys_msync
; - Slot-based fixed-width binary table format:
;     Header (16 bytes):
;       offset 0: Magic "SMKV" (0x564B4D53)
;       offset 4: Version (uint32_t = 1)
;       offset 8: Max Slots (uint64_t = 64)
;     Each Slot (64 bytes):
;       offset 0:  Status byte (0x00 = empty, 0x01 = active)
;       offset 1:  Key (31 bytes, null-padded)
;       offset 32: Value (32 bytes, null-padded)
; - Operations:
;     ./mkvstore set <key> <val>
;     ./mkvstore get <key>
;     ./mkvstore dump
; ==============================================================================

global _start

%define SYS_READ      0
%define SYS_WRITE     1
%define SYS_OPEN      2
%define SYS_CLOSE     3
%define SYS_MMAP      9
%define SYS_MUNMAP    11
%define SYS_MSYNC     26
%define SYS_EXIT      60
%define SYS_FTRUNCATE 77

%define STDOUT_FILENO 1
%define STDERR_FILENO 2

; Open flags: O_RDWR (02) | O_CREAT (0100)
%define O_RDWR   0x0002
%define O_CREAT  0x0040
%define FILE_MODE 0644o

; mmap constants
%define PROT_READ  0x1
%define PROT_WRITE 0x2
%define MAP_SHARED 0x01
%define MS_SYNC    0x04

; DB Structure constants
%define DB_MAGIC      0x564B4D53    ; "SMKV" in little-endian
%define DB_VERSION    1
%define MAX_SLOTS     64
%define HEADER_SIZE   16
%define SLOT_SIZE     64
%define TOTAL_DB_SIZE (HEADER_SIZE + (MAX_SLOTS * SLOT_SIZE)) ; 16 + 4096 = 4112 bytes

section .data
    db_filename     db "data.mkv", 0

    cmd_set         db "set", 0
    cmd_get         db "get", 0
    cmd_dump        db "dump", 0

    msg_banner      db "+================================================+", 10
                    db "|    MEMORY-MAPPED KEY-VALUE STORE (mkvstore)    |", 10
                    db "+================================================+", 10
    len_banner      equ $ - msg_banner

    msg_usage       db "Usage: ./mkvstore <set <key> <val> | get <key> | dump>", 10
    len_usage       equ $ - msg_usage

    msg_set_ok      db "[+] Key stored successfully.", 10
    len_set_ok      equ $ - msg_set_ok

    msg_not_found   db "[-] Key not found.", 10
    len_not_found   equ $ - msg_not_found

    msg_key_prefix  db "  [Key]: '", 0
    len_key_prefix  equ $ - msg_key_prefix - 1

    msg_val_prefix  db "' => [Value]: '", 0
    len_val_prefix  equ $ - msg_val_prefix - 1

    msg_val_suffix  db "'", 10
    len_val_suffix  equ $ - msg_val_suffix

    msg_dump_head   db "--- Active Key-Value Database Records ---", 10
    len_dump_head   equ $ - msg_dump_head

    newline         db 10

section .bss
    db_fd           resq 1
    mmap_ptr        resq 1
    argc            resq 1
    argv_cmd        resq 1      ; argv[1]
    argv_key        resq 1      ; argv[2]
    argv_val        resq 1      ; argv[3]

section .text

_start:
    ; System V AMD64 ABI on ELF entry:
    ; [rsp] = argc
    ; [rsp + 8] = argv[0]
    ; [rsp + 16] = argv[1] ...
    pop     rax
    mov     [rel argc], rax

    ; Check if at least 1 command line argument is provided
    cmp     rax, 2
    jl      .show_usage

    ; Save argv pointers
    pop     rdi                         ; argv[0] (binary name)
    pop     rdi                         ; argv[1] (subcommand: set/get/dump)
    mov     [rel argv_cmd], rdi

    cmp     qword [rel argc], 3
    jl      .parse_no_key
    pop     rdi                         ; argv[2] (key)
    mov     [rel argv_key], rdi

.parse_no_key:
    cmp     qword [rel argc], 4
    jl      .init_database
    pop     rdi                         ; argv[3] (value)
    mov     [rel argv_val], rdi

.init_database:
    ; 1. Open or create database file: open("data.mkv", O_RDWR | O_CREAT, 0644)
    mov     rax, SYS_OPEN
    lea     rdi, [rel db_filename]
    mov     rsi, O_RDWR | O_CREAT
    mov     rdx, FILE_MODE
    syscall

    test    rax, rax
    js      .error_exit
    mov     [rel db_fd], rax

    ; 2. Ensure database file has at least TOTAL_DB_SIZE bytes: ftruncate(fd, TOTAL_DB_SIZE)
    mov     rax, SYS_FTRUNCATE
    mov     rdi, [rel db_fd]
    mov     rsi, TOTAL_DB_SIZE
    syscall

    test    rax, rax
    js      .error_close

    ; 3. Memory-map the database file: mmap(NULL, TOTAL_DB_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)
    mov     rax, SYS_MMAP
    xor     rdi, rdi                    ; NULL (kernel chooses virtual address)
    mov     rsi, TOTAL_DB_SIZE          ; Length
    mov     rdx, PROT_READ | PROT_WRITE ; Prot
    mov     r10, MAP_SHARED             ; Flags
    mov     r8, [rel db_fd]             ; FD
    xor     r9, r9                      ; Offset 0
    syscall

    test    rax, rax
    js      .error_close
    mov     [rel mmap_ptr], rax

    ; 4. Check if header is already initialized, otherwise initialize it
    mov     rdi, [rel mmap_ptr]
    cmp     dword [rdi], DB_MAGIC
    je      .header_ok

    ; Initialize new DB header
    mov     dword [rdi], DB_MAGIC
    mov     dword [rdi + 4], DB_VERSION
    mov     qword [rdi + 8], MAX_SLOTS

    ; Zero-out all slots
    lea     rdi, [rdi + HEADER_SIZE]
    xor     al, al
    mov     rcx, (MAX_SLOTS * SLOT_SIZE)
    rep stosb

.header_ok:
    ; 5. Dispatch command: 'set', 'get', 'dump'
    mov     rdi, [rel argv_cmd]
    lea     rsi, [rel cmd_set]
    call    str_eq
    test    rax, rax
    jnz     .exec_set

    mov     rdi, [rel argv_cmd]
    lea     rsi, [rel cmd_get]
    call    str_eq
    test    rax, rax
    jnz     .exec_get

    mov     rdi, [rel argv_cmd]
    lea     rsi, [rel cmd_dump]
    call    str_eq
    test    rax, rax
    jnz     .exec_dump

    jmp     .show_usage

; ------------------------------------------------------------------------------
; SET <key> <val>
; ------------------------------------------------------------------------------
.exec_set:
    cmp     qword [rel argc], 4
    jl      .show_usage

    mov     rsi, [rel argv_key]         ; Target key
    mov     rdi, [rel mmap_ptr]
    lea     rdi, [rdi + HEADER_SIZE]    ; First slot pointer
    mov     rcx, MAX_SLOTS
    xor     rbx, rbx                    ; rbx will hold first free slot if key not found

.find_set_slot:
    ; If status is 0, record as free candidate
    cmp     byte [rdi], 1
    jne     .record_free_candidate

    ; Status is active, compare key (starts at rdi + 1)
    push    rdi
    push    rsi
    push    rcx
    lea     rdi, [rdi + 1]
    call    str_eq
    pop     rcx
    pop     rsi
    pop     rdi
    test    rax, rax
    jnz     .overwrite_existing_slot

    jmp     .next_set_slot

.record_free_candidate:
    test    rbx, rbx
    jnz     .next_set_slot
    mov     rbx, rdi                    ; Save first available free slot

.next_set_slot:
    add     rdi, SLOT_SIZE
    dec     rcx
    jnz     .find_set_slot

    ; If not found existing, use free candidate slot
    test    rbx, rbx
    jz      .db_full
    mov     rdi, rbx

.overwrite_existing_slot:
    ; rdi points to slot
    mov     byte [rdi], 1               ; Set active flag

    ; Clear key and val fields
    push    rdi
    lea     rdi, [rdi + 1]
    xor     al, al
    mov     rcx, 63
    rep stosb
    pop     rdi

    ; Copy key into rdi + 1
    push    rdi
    lea     rdi, [rdi + 1]
    mov     rsi, [rel argv_key]
    call    str_copy_31
    pop     rdi

    ; Copy value into rdi + 32
    lea     rdi, [rdi + 32]
    mov     rsi, [rel argv_val]
    call    str_copy_31

    ; Synchronize memory to disk: msync(mmap_ptr, TOTAL_DB_SIZE, MS_SYNC)
    mov     rax, SYS_MSYNC
    mov     rdi, [rel mmap_ptr]
    mov     rsi, TOTAL_DB_SIZE
    mov     rdx, MS_SYNC
    syscall

    ; Print success
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_set_ok]
    mov     rdx, len_set_ok
    syscall
    jmp     .cleanup_and_exit

.db_full:
    jmp     .error_exit

; ------------------------------------------------------------------------------
; GET <key>
; ------------------------------------------------------------------------------
.exec_get:
    cmp     qword [rel argc], 3
    jl      .show_usage

    mov     rsi, [rel argv_key]         ; Target key
    mov     rdi, [rel mmap_ptr]
    lea     rdi, [rdi + HEADER_SIZE]    ; First slot pointer
    mov     rcx, MAX_SLOTS

.search_get_loop:
    cmp     byte [rdi], 1
    jne     .next_get_slot

    ; Active slot, check key
    push    rdi
    push    rsi
    push    rcx
    lea     rdi, [rdi + 1]
    call    str_eq
    pop     rcx
    pop     rsi
    pop     rdi
    test    rax, rax
    jnz     .get_match_found

.next_get_slot:
    add     rdi, SLOT_SIZE
    dec     rcx
    jnz     .search_get_loop

    ; Not found
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_not_found]
    mov     rdx, len_not_found
    syscall
    jmp     .cleanup_and_exit

.get_match_found:
    ; Print value at rdi + 32
    lea     rsi, [rdi + 32]
    call    str_len
    mov     rdx, rax                    ; Value length

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    ; rsi already points to value
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall
    jmp     .cleanup_and_exit

; ------------------------------------------------------------------------------
; DUMP
; ------------------------------------------------------------------------------
.exec_dump:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_dump_head]
    mov     rdx, len_dump_head
    syscall

    mov     r12, [rel mmap_ptr]
    lea     r12, [r12 + HEADER_SIZE]
    mov     r13, MAX_SLOTS

.dump_loop:
    cmp     byte [r12], 1
    jne     .next_dump_slot

    ; Print Key Prefix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_key_prefix]
    mov     rdx, len_key_prefix
    syscall

    ; Print Key
    lea     rsi, [r12 + 1]
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    syscall

    ; Print Val Prefix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_val_prefix]
    mov     rdx, len_val_prefix
    syscall

    ; Print Value
    lea     rsi, [r12 + 32]
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    syscall

    ; Print Val Suffix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_val_suffix]
    mov     rdx, len_val_suffix
    syscall

.next_dump_slot:
    add     r12, SLOT_SIZE
    dec     r13
    jnz     .dump_loop

    jmp     .cleanup_and_exit

; ------------------------------------------------------------------------------
; Clean Exit / Helpers
; ------------------------------------------------------------------------------
.cleanup_and_exit:
    ; munmap(mmap_ptr, TOTAL_DB_SIZE)
    mov     rax, SYS_MUNMAP
    mov     rdi, [rel mmap_ptr]
    mov     rsi, TOTAL_DB_SIZE
    syscall

.error_close:
    ; close(fd)
    mov     rax, SYS_CLOSE
    mov     rdi, [rel db_fd]
    syscall

    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

.show_usage:
    mov     rax, SYS_WRITE
    mov     rdi, STDERR_FILENO
    lea     rsi, [rel msg_usage]
    mov     rdx, len_usage
    syscall

.error_exit:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

; ------------------------------------------------------------------------------
; String Helpers
; ------------------------------------------------------------------------------
; str_eq(rdi, rsi) -> rax (1 if equal, 0 if not)
str_eq:
    push    rdx
.cmp_loop:
    mov     al, [rdi]
    mov     dl, [rsi]
    cmp     al, dl
    jne     .not_equal
    test    al, al
    jz      .equal
    inc     rdi
    inc     rsi
    jmp     .cmp_loop
.equal:
    mov     rax, 1
    pop     rdx
    ret
.not_equal:
    xor     rax, rax
    pop     rdx
    ret

; str_copy_31(rdi, rsi)
; Copies up to 31 bytes from rsi to rdi, null-terminated
str_copy_31:
    mov     rcx, 31
.copy_loop:
    mov     al, [rsi]
    test    al, al
    jz      .terminate
    mov     [rdi], al
    inc     rdi
    inc     rsi
    dec     rcx
    jnz     .copy_loop
.terminate:
    mov     byte [rdi], 0
    ret

; str_len(rsi) -> rax (length)
str_len:
    xor     rax, rax
.len_loop:
    cmp     byte [rsi + rax], 0
    je      .len_done
    inc     rax
    jmp     .len_loop
.len_done:
    ret
