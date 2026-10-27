; ==============================================================================
; Standalone Project 11: Pure x86-64 Assembly POSIX tar Archiver & Extractor
; Architecture: x86-64 (Linux ELF)
; Description:  A standalone POSIX ustar-compliant archive tool CLI.
;               Creates, lists, and extracts standard uncompressed .tar archives.
;               Fully interoperable with the Linux GNU tar utility.
; Zero external libraries or C runtime dependencies. Pure Linux system calls.
; ==============================================================================

global _start

; --- Linux System Call Numbers (x86-64) ---
%define SYS_READ            0
%define SYS_WRITE           1
%define SYS_OPEN            2
%define SYS_CLOSE           3
%define SYS_FSTAT           5
%define SYS_LSEEK           8
%define SYS_EXIT            60

; --- File Open Flags & Constants ---
%define O_RDONLY            0
%define O_WRONLY            1
%define O_CREAT             64
%define O_TRUNC             512
%define O_CREAT_WRTRUNC     (O_WRONLY | O_CREAT | O_TRUNC)  ; 577

%define SEEK_CUR            1

%define STDIN_FILENO        0
%define STDOUT_FILENO       1
%define STDERR_FILENO       2

%define TAR_BLOCK_SIZE      512
%define STAT_SIZE           144

; struct stat offsets
%define STAT_MODE_OFF       24
%define STAT_SIZE_OFF       48
%define STAT_MTIME_OFF      88

section .data
    banner:
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
        db 0x1B, "[1;32m", " [PROJECT 11] Pure x86-64 Assembly POSIX tar Archiver", 0x1B, "[0m", 10
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
    banner_len equ $ - banner

    usage_msg:
        db "Usage: asm_tar <command> <archive.tar> [files...]", 10, 10
        db "Commands:", 10
        db "  create  <archive.tar> <file1> [file2...] - Create a POSIX ustar archive", 10
        db "  list    <archive.tar>                    - List files inside archive", 10
        db "  extract <archive.tar>                    - Extract files from archive", 10
    usage_msg_len equ $ - usage_msg

    cmd_create:     db "create", 0
    cmd_list:       db "list", 0
    cmd_extract:    db "extract", 0

    magic_ustar:    db "ustar", 0       ; 6 bytes
    version_ustar:  db "00"             ; 2 bytes
    user_str:       db "user", 0        ; 5 bytes

    msg_creating:
        db "[-] Creating POSIX tar archive: ", 0x1B, "[1;37m", 0
    msg_adding:
        db "  [+] Adding file: ", 0x1B, "[32m", 0
    msg_bytes:
        db 0x1B, "[0m", " (", 0
    msg_bytes_close:
        db " bytes)", 10, 0
    msg_create_success:
        db 0x1B, "[1;32m", "[+] Archive created successfully with 1024-byte EOF padding!", 0x1B, "[0m", 10
    msg_create_success_len equ $ - msg_create_success

    msg_listing:
        db "[-] Listing contents of archive: ", 0x1B, "[1;37m", 0
    msg_extracting:
        db "[-] Extracting contents from archive: ", 0x1B, "[1;37m", 0
    msg_extracted_file:
        db "  [+] Extracted: ", 0x1B, "[32m", 0

    msg_err_open:
        db 0x1B, "[31m", "[-] Error: Failed to open file or archive.", 0x1B, "[0m", 10
    msg_err_open_len equ $ - msg_err_open

    msg_err_stat:
        db 0x1B, "[31m", "[-] Error: Failed to retrieve file metadata via sys_fstat.", 0x1B, "[0m", 10
    msg_err_stat_len equ $ - msg_err_stat

    newline:
        db 10

section .bss
    argc:           resq 1
    argv_cmd:       resq 1
    argv_tar:       resq 1
    file_indices:   resq 16     ; up to 16 input files
    file_count:     resq 1

    tar_fd:         resq 1
    in_fd:          resq 1
    out_fd:         resq 1

    align 8
    stat_buf:       resb STAT_SIZE
    align 8
    header_block:   resb TAR_BLOCK_SIZE
    io_buf:         resb 4096
    num_buf:        resb 32

section .text

_start:
    ; Read argc and argv from stack
    pop rax
    mov [argc], rax

    cmp rax, 3
    jl .show_usage

    ; Print Banner
    mov rsi, banner
    mov rdx, banner_len
    call print_str

    pop rsi                 ; argv[0] (binary name)
    pop rsi                 ; argv[1] (command: create / list / extract)
    mov [argv_cmd], rsi

    pop rsi                 ; argv[2] (archive.tar)
    mov [argv_tar], rsi

    ; Check if command == "create"
    mov rdi, [argv_cmd]
    mov rsi, cmd_create
    call str_eq
    test rax, rax
    jnz .do_create

    ; Check if command == "list"
    mov rdi, [argv_cmd]
    mov rsi, cmd_list
    call str_eq
    test rax, rax
    jnz .do_list

    ; Check if command == "extract"
    mov rdi, [argv_cmd]
    mov rsi, cmd_extract
    call str_eq
    test rax, rax
    jnz .do_extract

.show_usage:
    mov rsi, banner
    mov rdx, banner_len
    call print_str

    mov rsi, usage_msg
    mov rdx, usage_msg_len
    call print_str

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

; ------------------------------------------------------------------------------
; COMMAND: CREATE ARCHIVE
; ------------------------------------------------------------------------------
.do_create:
    ; argc must be at least 4 (asm_tar create archive.tar file1 ...)
    mov rax, [argc]
    cmp rax, 4
    jl .show_usage

    ; Remaining argv elements on stack are input files
    sub rax, 3              ; rax = number of input files
    mov [file_count], rax

    xor rcx, rcx
.read_args:
    pop rsi
    mov [file_indices + rcx*8], rsi
    inc rcx
    cmp rcx, [file_count]
    jl .read_args

    ; Print creating message
    mov rsi, msg_creating
    call print_cstr
    mov rsi, [argv_tar]
    call print_cstr
    mov rsi, newline
    mov rdx, 1
    call print_str

    ; Open archive for writing: sys_open(archive, O_CREAT_WRTRUNC, 0644)
    mov rax, SYS_OPEN
    mov rdi, [argv_tar]
    mov rsi, O_CREAT_WRTRUNC
    mov rdx, 420             ; 0644 octal = 420 decimal
    syscall

    cmp rax, 0
    jl .err_open_archive
    mov [tar_fd], rax

    ; Loop over each file to add to archive
    xor r12, r12            ; r12 = file index (0..file_count-1)
.file_loop:
    mov r13, [file_indices + r12*8] ; r13 = filename pointer

    ; Open input file: sys_open(filename, O_RDONLY)
    mov rax, SYS_OPEN
    mov rdi, r13
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .err_open_file
    mov [in_fd], rax

    ; Query file stats: sys_fstat(in_fd, stat_buf)
    mov rax, SYS_FSTAT
    mov rdi, [in_fd]
    mov rsi, stat_buf
    syscall

    cmp rax, 0
    jl .err_stat

    ; Extract size, mode, and mtime
    mov r14, [stat_buf + STAT_SIZE_OFF]     ; r14 = file size
    mov r15d, [stat_buf + STAT_MODE_OFF]    ; r15d = mode
    and r15d, 0x1FF                         ; mask permissions (e.g. 0644)

    ; Print adding file line
    mov rsi, msg_adding
    call print_cstr
    mov rsi, r13
    call print_cstr
    mov rsi, msg_bytes
    call print_cstr
    mov rdi, r14
    call print_u64
    mov rsi, msg_bytes_close
    call print_cstr

    ; --- Build 512-byte ustar Header Block ---
    mov rdi, header_block
    mov rcx, TAR_BLOCK_SIZE
    xor al, al
    rep stosb

    ; 1. Copy filename into header_block[0..99]
    mov rdi, header_block
    mov rsi, r13
    call copy_cstr_limit_100

    ; 2. Mode: 8 bytes at offset 100 (octal, e.g. "0000644\0")
    mov edi, r15d
    lea rsi, [header_block + 100]
    mov rdx, 8
    call format_octal

    ; 3. UID: 8 bytes at offset 108 (octal 0001000)
    mov rdi, 1000
    lea rsi, [header_block + 108]
    mov rdx, 8
    call format_octal

    ; 4. GID: 8 bytes at offset 116 (octal 0001000)
    mov rdi, 1000
    lea rsi, [header_block + 116]
    mov rdx, 8
    call format_octal

    ; 5. Size: 12 bytes at offset 124 (octal, e.g. "00000000042\0")
    mov rdi, r14
    lea rsi, [header_block + 124]
    mov rdx, 12
    call format_octal

    ; 6. Mtime: 12 bytes at offset 136
    mov rdi, [stat_buf + STAT_MTIME_OFF]
    lea rsi, [header_block + 136]
    mov rdx, 12
    call format_octal

    ; 7. Checksum placeholder: 8 ASCII spaces at offset 148
    lea rdi, [header_block + 148]
    mov al, ' '
    mov rcx, 8
    rep stosb

    ; 8. Typeflag: '0' (regular file) at offset 156
    mov byte [header_block + 156], '0'

    ; 9. Magic: "ustar\0" at offset 257 (6 bytes)
    lea rdi, [header_block + 257]
    mov rsi, magic_ustar
    mov rcx, 6
    rep movsb

    ; 10. Version: "00" at offset 263 (2 bytes)
    lea rdi, [header_block + 263]
    mov rsi, version_ustar
    mov rcx, 2
    rep movsb

    ; 11. Uname & Gname: "user\0" at 265 and 297
    lea rdi, [header_block + 265]
    mov rsi, user_str
    mov rcx, 5
    rep movsb

    lea rdi, [header_block + 297]
    mov rsi, user_str
    mov rcx, 5
    rep movsb

    ; --- Calculate Header Checksum ---
    ; Sum of all 512 bytes treating each byte as unsigned char
    xor rax, rax
    xor rcx, rcx
.chk_sum_loop:
    movzx rdx, byte [header_block + rcx]
    add rax, rdx
    inc rcx
    cmp rcx, TAR_BLOCK_SIZE
    jl .chk_sum_loop

    ; Write checksum as 6 octal digits + '\0' + ' ' at offset 148
    ; e.g. format 6 digits into header_block + 148
    mov rdi, rax
    lea rsi, [header_block + 148]
    mov rdx, 7
    call format_octal
    mov byte [header_block + 155], ' '

    ; Write 512-byte header to archive
    mov rax, SYS_WRITE
    mov rdi, [tar_fd]
    mov rsi, header_block
    mov rdx, TAR_BLOCK_SIZE
    syscall

    ; Stream file contents in blocks of up to 4096 bytes
    mov rbx, r14                ; rbx = remaining bytes to copy
.copy_content_loop:
    test rbx, rbx
    jz .content_done

    mov rdx, 4096
    cmp rbx, rdx
    cmovb rdx, rbx              ; rdx = min(4096, rbx)

    mov rax, SYS_READ
    mov rdi, [in_fd]
    mov rsi, io_buf
    syscall

    test rax, rax
    jle .content_done

    push rax
    mov rdx, rax
    mov rax, SYS_WRITE
    mov rdi, [tar_fd]
    mov rsi, io_buf
    syscall
    pop rax

    sub rbx, rax
    jmp .copy_content_loop

.content_done:
    ; Close input file
    mov rax, SYS_CLOSE
    mov rdi, [in_fd]
    syscall

    ; Write padding bytes to align payload to 512-byte boundary
    ; pad_len = (512 - (file_size % 512)) % 512
    mov rax, r14
    xor rdx, rdx
    mov rcx, TAR_BLOCK_SIZE
    div rcx                     ; rdx = file_size % 512

    test rdx, rdx
    jz .no_padding

    mov rbx, TAR_BLOCK_SIZE
    sub rbx, rdx                ; rbx = padding needed (1..511)

    ; Zero io_buf
    mov rdi, io_buf
    mov rcx, rbx
    xor al, al
    rep stosb

    mov rax, SYS_WRITE
    mov rdi, [tar_fd]
    mov rsi, io_buf
    mov rdx, rbx
    syscall

.no_padding:
    inc r12
    cmp r12, [file_count]
    jl .file_loop

    ; Write two 512-byte end-of-archive zero blocks (1024 null bytes)
    mov rdi, io_buf
    mov rcx, 1024
    xor al, al
    rep stosb

    mov rax, SYS_WRITE
    mov rdi, [tar_fd]
    mov rsi, io_buf
    mov rdx, 1024
    syscall

    ; Close archive
    mov rax, SYS_CLOSE
    mov rdi, [tar_fd]
    syscall

    mov rsi, msg_create_success
    mov rdx, msg_create_success_len
    call print_str

    xor rdi, rdi
    jmp .exit_clean

; ------------------------------------------------------------------------------
; COMMAND: LIST ARCHIVE CONTENTS
; ------------------------------------------------------------------------------
.do_list:
    mov rsi, msg_listing
    call print_cstr
    mov rsi, [argv_tar]
    call print_cstr
    mov rsi, newline
    mov rdx, 1
    call print_str

    mov rax, SYS_OPEN
    mov rdi, [argv_tar]
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .err_open_archive
    mov [tar_fd], rax

.list_loop:
    ; Read 512-byte header block
    mov rax, SYS_READ
    mov rdi, [tar_fd]
    mov rsi, header_block
    mov rdx, TAR_BLOCK_SIZE
    syscall

    cmp rax, TAR_BLOCK_SIZE
    jl .list_done

    ; If first byte is 0, end of archive blocks reached
    cmp byte [header_block], 0
    je .list_done

    ; Parse size from octal at offset 124 (12 bytes)
    lea rdi, [header_block + 124]
    mov rsi, 12
    call parse_octal
    mov r14, rax                ; r14 = file size

    ; Print listing item
    mov rsi, msg_adding
    call print_cstr
    mov rsi, header_block       ; filename null-terminated
    call print_cstr
    mov rsi, msg_bytes
    call print_cstr
    mov rdi, r14
    call print_u64
    mov rsi, msg_bytes_close
    call print_cstr

    ; Skip payload: aligned_size = ((size + 511) / 512) * 512
    lea rax, [r14 + 511]
    xor rdx, rdx
    mov rcx, 512
    div rcx
    imul rax, 512               ; rax = bytes to skip in archive

    test rax, rax
    jz .list_loop

    ; Seek past payload: sys_lseek(tar_fd, rax, SEEK_CUR)
    mov rdx, SEEK_CUR
    mov rsi, rax
    mov rdi, [tar_fd]
    mov rax, SYS_LSEEK
    syscall

    jmp .list_loop

.list_done:
    mov rax, SYS_CLOSE
    mov rdi, [tar_fd]
    syscall

    xor rdi, rdi
    jmp .exit_clean

; ------------------------------------------------------------------------------
; COMMAND: EXTRACT ARCHIVE CONTENTS
; ------------------------------------------------------------------------------
.do_extract:
    mov rsi, msg_extracting
    call print_cstr
    mov rsi, [argv_tar]
    call print_cstr
    mov rsi, newline
    mov rdx, 1
    call print_str

    mov rax, SYS_OPEN
    mov rdi, [argv_tar]
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl .err_open_archive
    mov [tar_fd], rax

.extract_loop:
    mov rax, SYS_READ
    mov rdi, [tar_fd]
    mov rsi, header_block
    mov rdx, TAR_BLOCK_SIZE
    syscall

    cmp rax, TAR_BLOCK_SIZE
    jl .extract_done

    cmp byte [header_block], 0
    je .extract_done

    ; Parse file size
    lea rdi, [header_block + 124]
    mov rsi, 12
    call parse_octal
    mov r14, rax                ; r14 = file size

    ; Open extracted output file: sys_open(filename, O_CREAT_WRTRUNC, 0644)
    mov rax, SYS_OPEN
    mov rdi, header_block       ; filename
    mov rsi, O_CREAT_WRTRUNC
    mov rdx, 420                ; 0644
    syscall

    cmp rax, 0
    jl .extract_done
    mov [out_fd], rax

    ; Copy r14 bytes from tar_fd to out_fd
    mov rbx, r14
.copy_extracted_data:
    test rbx, rbx
    jz .extract_file_done

    mov rdx, 4096
    cmp rbx, rdx
    cmovb rdx, rbx

    mov rax, SYS_READ
    mov rdi, [tar_fd]
    mov rsi, io_buf
    syscall

    test rax, rax
    jle .extract_file_done

    push rax
    mov rdx, rax
    mov rax, SYS_WRITE
    mov rdi, [out_fd]
    mov rsi, io_buf
    syscall
    pop rax

    sub rbx, rax
    jmp .copy_extracted_data

.extract_file_done:
    mov rax, SYS_CLOSE
    mov rdi, [out_fd]
    syscall

    ; Print extracted confirmation
    mov rsi, msg_extracted_file
    call print_cstr
    mov rsi, header_block
    call print_cstr
    mov rsi, msg_bytes
    call print_cstr
    mov rdi, r14
    call print_u64
    mov rsi, msg_bytes_close
    call print_cstr

    ; Skip remaining padding in archive to next 512-byte boundary
    mov rax, r14
    xor rdx, rdx
    mov rcx, 512
    div rcx                     ; rdx = size % 512

    test rdx, rdx
    jz .extract_loop

    mov rbx, 512
    sub rbx, rdx                ; padding to skip

    mov rax, SYS_LSEEK
    mov rdi, [tar_fd]
    mov rsi, rbx
    mov rdx, SEEK_CUR
    syscall

    jmp .extract_loop

.extract_done:
    mov rax, SYS_CLOSE
    mov rdi, [tar_fd]
    syscall

    xor rdi, rdi
    jmp .exit_clean

; ------------------------------------------------------------------------------
; Error Handlers
; ------------------------------------------------------------------------------
.err_open_archive:
.err_open_file:
    mov rsi, msg_err_open
    mov rdx, msg_err_open_len
    call print_str
    mov rdi, 1
    jmp .exit_clean

.err_stat:
    mov rsi, msg_err_stat
    mov rdx, msg_err_stat_len
    call print_str
    mov rdi, 1
    jmp .exit_clean

.exit_clean:
    mov rax, SYS_EXIT
    syscall

; ------------------------------------------------------------------------------
; Helper Functions
; ------------------------------------------------------------------------------
str_eq:
    ; Checks null-terminated string equality: rdi vs rsi -> rax (1 if equal, 0 if not)
    push rbx
.cmp_loop:
    mov al, [rdi]
    mov bl, [rsi]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc rdi
    inc rsi
    jmp .cmp_loop
.equal:
    mov rax, 1
    pop rbx
    ret
.not_equal:
    xor rax, rax
    pop rbx
    ret

copy_cstr_limit_100:
    ; Copies null-terminated string from RSI to RDI, max 99 chars + 0
    push rcx
    xor rcx, rcx
.copy_l:
    cmp rcx, 99
    jge .copy_end
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    test al, al
    jz .copy_done
    inc rcx
    jmp .copy_l
.copy_end:
    mov byte [rdi + 99], 0
.copy_done:
    pop rcx
    ret

format_octal:
    ; Formats unsigned integer in RDI as octal string of RDX characters into RSI
    ; Writes (RDX - 1) octal digits followed by a null terminator byte.
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    mov rcx, rdx
    dec rcx                     ; number of digits
    mov byte [rsi + rcx], 0     ; null terminator

    mov rax, rdi
.oct_loop:
    dec rcx
    mov rbx, rax
    and rbx, 7
    add bl, '0'
    mov [rsi + rcx], bl
    shr rax, 3
    test rcx, rcx
    jnz .oct_loop

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

parse_octal:
    ; Parses octal string in RDI (length in RSI) -> RAX (uint64)
    push rbx
    push rcx
    push rdx

    xor rax, rax
    xor rcx, rcx
.po_loop:
    cmp rcx, rsi
    jge .po_done
    movzx rdx, byte [rdi + rcx]
    cmp dl, '0'
    jl .po_skip
    cmp dl, '7'
    jg .po_skip
    shl rax, 3
    sub dl, '0'
    add rax, rdx
.po_skip:
    inc rcx
    jmp .po_loop

.po_done:
    pop rdx
    pop rcx
    pop rbx
    ret

print_str:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

print_cstr:
    push rdi
    push rsi
    push rdx
    push rcx

    xor rcx, rcx
.c_len:
    cmp byte [rsi + rcx], 0
    je .c_write
    inc rcx
    jmp .c_len

.c_write:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    mov rdx, rcx
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ret

print_u64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, rdi
    lea rsi, [num_buf + 31]
    mov byte [rsi], 0
    mov rbx, 10
    xor rcx, rcx

    test rax, rax
    jnz .u64_loop
    dec rsi
    mov byte [rsi], '0'
    inc rcx
    jmp .u64_write

.u64_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz .u64_loop

.u64_write:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    mov rdx, rcx
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
