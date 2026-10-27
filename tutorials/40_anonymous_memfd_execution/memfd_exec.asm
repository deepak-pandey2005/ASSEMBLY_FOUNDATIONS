; ==============================================================================
; Tutorial 40: Anonymous In-Memory Execution (sys_memfd_create & sys_execveat)
; ==============================================================================
;
; Concepts Covered:
;   - In-memory execution without touching the disk or filesystem.
;   - sys_memfd_create (syscall 319): creating an anonymous RAM file descriptor.
;   - sys_fcntl (syscall 72): sealing file descriptors (F_ADD_SEALS).
;   - Handcrafted 64-bit ELF executable binary structure and execution.
;   - sys_execveat (syscall 322) with AT_EMPTY_PATH (0x1000): executing directly
;     from an open file descriptor without specifying a path.
;   - sys_fork (syscall 57) & sys_wait4 (syscall 61): process management.
;   - Pure assembly, zero libc dependencies, 100% Linux x86-64 syscalls.
; ==============================================================================

BITS 64
default rel
global _start

; Linux System Call Numbers
SYS_WRITE           equ 1
SYS_CLOSE           equ 3
SYS_FORK            equ 57
SYS_EXIT            equ 60
SYS_WAIT4           equ 61
SYS_FCNTL           equ 72
SYS_MEMFD_CREATE    equ 319
SYS_EXECVEAT        equ 322

; Constants
STDOUT_FILENO       equ 1
MFD_ALLOW_SEALING   equ 2
F_ADD_SEALS         equ 1033
F_SEAL_SEAL         equ 1
F_SEAL_SHRINK       equ 2
F_SEAL_GROW         equ 4
F_SEAL_WRITE        equ 8
AT_EMPTY_PATH       equ 0x1000

section .rodata
    banner:
        db "==========================================================", 10
        db " Tutorial 40: Anonymous In-Memory Binary Execution        ", 10
        db " (sys_memfd_create & sys_execveat - Zero Disk Footprints) ", 10
        db "==========================================================", 10
    banner_len equ $ - banner

    msg_create:
        db "[+] Calling sys_memfd_create(name='anon_elf', flags=MFD_ALLOW_SEALING)...", 10
    msg_create_len equ $ - msg_create

    msg_created_fd:
        db "[+] Successfully allocated anonymous RAM memfd: "
    msg_created_fd_len equ $ - msg_created_fd

    msg_writing:
        db "[+] Writing handcrafted 64-bit ELF binary into anonymous RAM descriptor...", 10
    msg_writing_len equ $ - msg_writing

    msg_written:
        db "[+] Successfully wrote payload bytes into memory (zero disk I/O): "
    msg_written_len equ $ - msg_written

    msg_sealing:
        db "[+] Applying kernel file seals (F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_GROW)...", 10
    msg_sealing_len equ $ - msg_sealing

    msg_sealed:
        db "[+] In-memory ELF sealed as immutable.", 10
    msg_sealed_len equ $ - msg_sealed

    msg_forking:
        db "[+] Forking child to invoke sys_execveat(fd, '', argv, envp, AT_EMPTY_PATH)...", 10
    msg_forking_len equ $ - msg_forking

    msg_parent_wait:
        db "[+] Parent waiting for anonymous child execution...", 10
    msg_parent_wait_len equ $ - msg_parent_wait

    msg_parent_success:
        db "[+] Child exited cleanly with expected return code: "
    msg_parent_success_len equ $ - msg_parent_success

    msg_summary:
        db "[+] Anonymous memory execution test passed with 0 disk footprints!", 10
    msg_summary_len equ $ - msg_summary

    err_memfd:
        db "[-] Error: sys_memfd_create failed!", 10
    err_memfd_len equ $ - err_memfd

    err_write:
        db "[-] Error: sys_write to memfd failed!", 10
    err_write_len equ $ - err_write

    err_fcntl:
        db "[-] Error: sys_fcntl F_ADD_SEALS failed!", 10
    err_fcntl_len equ $ - err_fcntl

    err_fork:
        db "[-] Error: sys_fork failed!", 10
    err_fork_len equ $ - err_fork

    err_execveat:
        db "[-] Error: sys_execveat failed inside child process!", 10
    err_execveat_len equ $ - err_execveat

    newline:
        db 10

    memfd_name:
        db "anon_elf", 0

    empty_path:
        db 0

    child_arg0:
        db "[anon_payload]", 0

    ; Child argv array: [child_arg0, NULL]
    align 8
    child_argv:
        dq child_arg0
        dq 0

    ; Child envp array: [NULL]
    align 8
    child_envp:
        dq 0

    ; --------------------------------------------------------------------------
    ; Handcrafted 64-bit Minimalist Executable ELF Binary
    ; Size: 242 bytes
    ; Entry Point: 0x400078
    ; Behavior:
    ;   1. Prints confirmation message to STDOUT via sys_write.
    ;   2. Exits with return code 42 via sys_exit.
    ; --------------------------------------------------------------------------
    align 16
    elf_payload:
        ; --- ELF Header (64 bytes) ---
        db 0x7f, "ELF"                      ; e_ident[EI_MAG0..3]: Magic number
        db 2                                ; e_ident[EI_CLASS]: 2 = 64-bit Architecture
        db 1                                ; e_ident[EI_DATA]: 1 = 2's complement, little-endian
        db 1                                ; e_ident[EI_VERSION]: 1 = Current ELF version
        db 0                                ; e_ident[EI_OSABI]: 0 = System V UNIX
        times 8 db 0                        ; e_ident[EI_PAD]: 8 bytes reserved padding
        dw 2                                ; e_type: 2 = ET_EXEC (Executable file)
        dw 0x3e                             ; e_machine: 0x3e = Advanced Micro Devices X86-64
        dd 1                                ; e_version: 1 = Current version
        dq 0x400078                         ; e_entry: Virtual address entry point (_start)
        dq 0x40                             ; e_phoff: Program header offset (64 bytes from start)
        dq 0                                ; e_shoff: Section header offset (none)
        dd 0                                ; e_flags: Processor-specific flags
        dw 64                               ; e_ehsize: ELF header size (64 bytes)
        dw 56                               ; e_phentsize: Program header entry size (56 bytes)
        dw 1                                ; e_phnum: Number of program header entries (1)
        dw 0                                ; e_shentsize: Section header entry size (0)
        dw 0                                ; e_shnum: Number of section header entries (0)
        dw 0                                ; e_shstrndx: Section name string table index (none)

        ; --- Program Header 1: PT_LOAD segment (56 bytes, starts at offset 0x40) ---
        dd 1                                ; p_type: 1 = PT_LOAD (Loadable segment)
        dd 7                                ; p_flags: 7 = PF_R | PF_W | PF_X (Read/Write/Exec)
        dq 0                                ; p_offset: File offset of segment (0)
        dq 0x400000                         ; p_vaddr: Virtual address to load into memory
        dq 0x400000                         ; p_paddr: Physical address (ignored)
        dq 242                              ; p_filesz: Segment size in file (242 bytes)
        dq 242                              ; p_memsz: Segment size in memory (242 bytes)
        dq 0x1000                           ; p_align: Alignment (4096 bytes)

        ; --- Payload Code (_start at virtual address 0x400078, offset 120 / 0x78) ---
        ; Instruction sequence:
        ;   mov eax, 1                      ; sys_write
        ;   mov edi, 1                      ; fd = STDOUT
        ;   mov rsi, 0x40009d               ; buffer address (message string)
        ;   mov edx, 85                     ; message length
        ;   syscall
        ;   mov eax, 60                     ; sys_exit
        ;   mov edi, 42                     ; exit code 42
        ;   syscall
        db 0xb8, 0x01, 0x00, 0x00, 0x00     ; mov eax, 1
        db 0xbf, 0x01, 0x00, 0x00, 0x00     ; mov edi, 1
        db 0x48, 0x8d, 0x34, 0x25           ; lea rsi, [0x40009d]
        dd 0x0040009d
        db 0xba, 0x55, 0x00, 0x00, 0x00     ; mov edx, 85
        db 0x0f, 0x05                       ; syscall (sys_write)
        db 0xb8, 0x3c, 0x00, 0x00, 0x00     ; mov eax, 60
        db 0xbf, 0x2a, 0x00, 0x00, 0x00     ; mov edi, 42
        db 0x0f, 0x05                       ; syscall (sys_exit)

        ; --- Payload Data (String at virtual address 0x40009d, length 85) ---
        db "[In-Memory Child] Executed anonymously from RAM via sys_memfd_create & sys_execveat!", 10
    elf_payload_len equ $ - elf_payload

section .bss
    memfd_val       resq 1
    child_status    resd 1
    num_buf         resb 32

section .text

; ------------------------------------------------------------------------------
; Helper: Print null-terminated or fixed-size string
; ------------------------------------------------------------------------------
print_str:
    ; rdi = buffer, rsi = length
    mov rax, SYS_WRITE
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, STDOUT_FILENO
    syscall
    ret

; ------------------------------------------------------------------------------
; Helper: Print 64-bit unsigned integer in decimal followed by newline
; ------------------------------------------------------------------------------
print_u64:
    ; rdi = number
    mov rax, rdi
    lea rsi, [num_buf + 31]
    mov byte [rsi], 10      ; newline
    mov r8, 10

.loop:
    dec rsi
    xor rdx, rdx
    div r8
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .loop

    ; Print from rsi to buffer end
    lea rdx, [num_buf + 32]
    sub rdx, rsi            ; length
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

; ------------------------------------------------------------------------------
; Entry Point
; ------------------------------------------------------------------------------
_start:
    ; 1. Print Banner
    mov rdi, banner
    mov rsi, banner_len
    call print_str

    ; 2. Call sys_memfd_create
    mov rdi, msg_create
    mov rsi, msg_create_len
    call print_str

    mov rax, SYS_MEMFD_CREATE
    mov rdi, memfd_name             ; name for debugging/diagnostics
    mov rsi, MFD_ALLOW_SEALING      ; flags = 2 (allow fcntl sealing)
    syscall

    test rax, rax
    js .err_memfd_exit
    mov [memfd_val], rax

    ; Print created FD
    mov rdi, msg_created_fd
    mov rsi, msg_created_fd_len
    call print_str

    mov rdi, [memfd_val]
    call print_u64

    ; 3. Write handcrafted ELF binary into memory FD
    mov rdi, msg_writing
    mov rsi, msg_writing_len
    call print_str

    mov rax, SYS_WRITE
    mov rdi, [memfd_val]
    mov rsi, elf_payload
    mov rdx, elf_payload_len
    syscall

    ; Save bytes written into r14
    mov r14, rax
    test r14, r14
    js .err_write_exit

    ; Print written bytes confirmation
    mov rdi, msg_written
    mov rsi, msg_written_len
    call print_str

    mov rdi, r14
    call print_u64

    ; 4. Apply file seals via sys_fcntl
    mov rdi, msg_sealing
    mov rsi, msg_sealing_len
    call print_str

    mov rax, SYS_FCNTL
    mov rdi, [memfd_val]
    mov rsi, F_ADD_SEALS
    mov rdx, (F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_GROW)
    syscall

    test rax, rax
    js .err_fcntl_exit

    mov rdi, msg_sealed
    mov rsi, msg_sealed_len
    call print_str

    ; 5. Fork child process
    mov rdi, msg_forking
    mov rsi, msg_forking_len
    call print_str

    mov rax, SYS_FORK
    syscall

    test rax, rax
    js .err_fork_exit
    jz .child_process

    ; --------------------------------------------------------------------------
    ; Parent Process Logic
    ; --------------------------------------------------------------------------
.parent_process:
    mov r12, rax                    ; r12 = child PID

    mov rdi, msg_parent_wait
    mov rsi, msg_parent_wait_len
    call print_str

    ; sys_wait4(pid, &wstatus, 0, NULL)
    mov rax, SYS_WAIT4
    mov rdi, r12
    mov rsi, child_status
    xor rdx, rdx                    ; options = 0
    xor r10, r10                    ; rusage = NULL
    syscall

    ; Extract exit status: WEXITSTATUS(status) = (status >> 8) & 0xff
    mov eax, [child_status]
    shr eax, 8
    and eax, 0xff
    mov r13d, eax                   ; r13d = exit code

    mov rdi, msg_parent_success
    mov rsi, msg_parent_success_len
    call print_str

    mov edi, r13d
    call print_u64

    ; Close anonymous memfd
    mov rax, SYS_CLOSE
    mov rdi, [memfd_val]
    syscall

    ; Print final summary
    mov rdi, msg_summary
    mov rsi, msg_summary_len
    call print_str

    ; Exit parent with 0 if child exit code was 42, else 1
    cmp r13d, 42
    jne .err_exit

    mov rax, SYS_EXIT
    xor rdi, rdi                    ; return 0
    syscall

    ; --------------------------------------------------------------------------
    ; Child Process Logic
    ; --------------------------------------------------------------------------
.child_process:
    ; sys_execveat(dirfd, pathname, argv, envp, flags)
    ;   dirfd    = [memfd_val]
    ;   pathname = "" (empty string)
    ;   argv     = child_argv
    ;   envp     = child_envp
    ;   flags    = AT_EMPTY_PATH (0x1000)
    mov rax, SYS_EXECVEAT
    mov rdi, [memfd_val]            ; dirfd = memfd
    mov rsi, empty_path             ; pathname = ""
    mov rdx, child_argv             ; argv
    mov r10, child_envp             ; envp
    mov r8, AT_EMPTY_PATH           ; flags = 0x1000
    syscall

    ; If execveat returns, it encountered an error!
    mov rdi, err_execveat
    mov rsi, err_execveat_len
    call print_str

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

    ; --------------------------------------------------------------------------
    ; Error Handlers
    ; --------------------------------------------------------------------------
.err_memfd_exit:
    mov rdi, err_memfd
    mov rsi, err_memfd_len
    call print_str
    jmp .err_exit

.err_write_exit:
    mov rdi, err_write
    mov rsi, err_write_len
    call print_str
    jmp .err_exit

.err_fcntl_exit:
    mov rdi, err_fcntl
    mov rsi, err_fcntl_len
    call print_str
    jmp .err_exit

.err_fork_exit:
    mov rdi, err_fork
    mov rsi, err_fork_len
    call print_str

.err_exit:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
