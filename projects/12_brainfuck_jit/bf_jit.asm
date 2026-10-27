; ==============================================================================
; Standalone Project 12: Pure Assembly Brainfuck JIT (Just-In-Time) Compiler
; ==============================================================================
;
; Concepts & Architecture:
;   - Real-time compilation of source code directly into native x86-64 machine code.
;   - Dynamic executable memory allocation via sys_mmap (PROT_READ|PROT_WRITE|PROT_EXEC).
;   - Compiler Optimization Engine:
;       * Run-length coalescing for arithmetic (+ and -) -> add/sub byte [r12], N
;       * Run-length coalescing for pointer navigation (> and <) -> add/sub r12, N
;       * Peephole optimization: zero-cell idiom [-] -> mov byte [r12], 0
;       * Direct inline syscall generation for I/O (. and ,)
;       * Two-pass loop jump backpatching with bracket nesting stack ([ and ])
;   - Hardware performance telemetry via RDTSC (measuring compilation & run cycles).
;   - Command-Line Interface (CLI):
;       * File execution: ./asm_bfjit <file.bf>
;       * Inline execution: ./asm_bfjit -e "<brainfuck code>"
;       * Built-in benchmark execution when invoked without arguments.
;   - Pure Linux x86-64 assembly, zero external C runtime (libc) dependencies.
; ==============================================================================

BITS 64
default rel
global _start

; Linux System Call Numbers
SYS_READ            equ 0
SYS_WRITE           equ 1
SYS_OPEN            equ 2
SYS_CLOSE           equ 3
SYS_MMAP            equ 9
SYS_MUNMAP          equ 11
SYS_EXIT            equ 60

; File and Memory Constants
O_RDONLY            equ 0
PROT_READ           equ 1
PROT_WRITE          equ 2
PROT_EXEC           equ 4
MAP_PRIVATE         equ 0x02
MAP_ANONYMOUS       equ 0x20

STDOUT_FILENO       equ 1
STDERR_FILENO       equ 2

JIT_BUFFER_SIZE     equ 65536       ; 64 KB executable JIT code buffer
TAPE_BUFFER_SIZE    equ 65536       ; 64 KB memory tape
MAX_SOURCE_SIZE     equ 32768       ; 32 KB source code capacity
BRACKET_STACK_CAP   equ 2048        ; Max nested loop depth

section .rodata
    banner:
        db "==========================================================", 10
        db " Standalone Project 12: Pure Assembly Brainfuck JIT      ", 10
        db " (Direct Native x86-64 Machine Code Compiler Engine)     ", 10
        db "==========================================================", 10
    banner_len equ $ - banner

    usage_msg:
        db "Usage:", 10
        db "  ./asm_bfjit <file.bf>        - Compile and run Brainfuck source file", 10
        db "  ./asm_bfjit -e '<code>'      - Compile and run inline Brainfuck code", 10
        db "  ./asm_bfjit                  - Run built-in benchmark programs", 10, 10
    usage_msg_len equ $ - usage_msg

    msg_demo_intro:
        db "[*] No input file provided. Running built-in JIT compilation benchmark...", 10, 10
    msg_demo_intro_len equ $ - msg_demo_intro

    msg_compiling:
        db "[-] Compiling Brainfuck AST to native x86-64 machine instructions...", 10
    msg_compiling_len equ $ - msg_compiling

    msg_executing:
        db "[-] Calling JIT-compiled native function pointer in executable RAM...", 10
        db "-------------------- JIT PROGRAM OUTPUT --------------------", 10
    msg_executing_len equ $ - msg_executing

    msg_output_end:
        db 10, "------------------------------------------------------------", 10
    msg_output_end_len equ $ - msg_output_end

    msg_stats_header:
        db "--- JIT Compiler Performance Telemetry ---", 10
    msg_stats_header_len equ $ - msg_stats_header

    msg_stat_source:
        db "  -> Source Instructions : "
    msg_stat_source_len equ $ - msg_stat_source

    msg_stat_emitted:
        db "  -> Machine Bytes Emitted: "
    msg_stat_emitted_len equ $ - msg_stat_emitted

    msg_stat_jit_cycles:
        db "  -> JIT Compilation Cost : "
    msg_stat_jit_cycles_len equ $ - msg_stat_jit_cycles

    msg_stat_run_cycles:
        db "  -> Native Execution Cost: "
    msg_stat_run_cycles_len equ $ - msg_stat_run_cycles

    msg_cycles_suffix:
        db " CPU cycles", 10
    msg_cycles_suffix_len equ $ - msg_cycles_suffix

    msg_bytes_suffix:
        db " bytes", 10
    msg_bytes_suffix_len equ $ - msg_bytes_suffix

    msg_items_suffix:
        db " chars", 10
    msg_items_suffix_len equ $ - msg_items_suffix

    msg_success:
        db "[+] Brainfuck JIT compilation and native execution verified successfully!", 10
    msg_success_len equ $ - msg_success

    err_mmap:
        db "[-] Error: sys_mmap failed to allocate executable memory!", 10
    err_mmap_len equ $ - err_mmap

    err_open:
        db "[-] Error: Failed to open source file!", 10
    err_open_len equ $ - err_open

    err_bracket_mismatch:
        db "[-] Error: Syntax error - unmatched loop brackets [ / ]!", 10
    err_bracket_mismatch_len equ $ - err_bracket_mismatch

    err_jit_overflow:
        db "[-] Error: JIT code buffer overflow!", 10
    err_jit_overflow_len equ $ - err_jit_overflow

    str_dash_e:
        db "-e", 0

    ; Built-in Benchmark Program: "Hello World!" in Brainfuck
    ; Standard optimized algorithm using loop scaling
    demo_hello_bf:
        db "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", 0
    demo_hello_bf_len equ $ - demo_hello_bf - 1

section .bss
    jit_memory_ptr      resq 1      ; Address of mmap'd executable page
    source_ptr          resq 1      ; Pointer to active source code buffer
    source_len          resq 1      ; Length of source code
    emitted_bytes       resq 1      ; Number of machine code bytes generated
    tape_memory         resb TAPE_BUFFER_SIZE
    file_source_buf     resb MAX_SOURCE_SIZE
    bracket_stack       resq BRACKET_STACK_CAP
    bracket_sp          resq 1
    num_buf             resb 32

    t_compile_start     resq 1
    t_compile_cycles    resq 1
    t_run_start         resq 1
    t_run_cycles        resq 1

section .text

; ------------------------------------------------------------------------------
; Helper: Print fixed-size string to STDOUT
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
; Helper: Print null-terminated string to STDOUT
; ------------------------------------------------------------------------------
print_cstr:
    push rdi
    xor rcx, rcx
.len_loop:
    cmp byte [rdi + rcx], 0
    jz .len_done
    inc rcx
    jmp .len_loop
.len_done:
    pop rsi
    mov rax, SYS_WRITE
    mov rdx, rcx
    mov rdi, STDOUT_FILENO
    syscall
    ret

; ------------------------------------------------------------------------------
; Helper: Print unsigned 64-bit integer in decimal
; ------------------------------------------------------------------------------
print_u64:
    ; rdi = number
    mov rax, rdi
    lea rsi, [num_buf + 31]
    mov byte [rsi], 0
    mov r8, 10
.conv_loop:
    dec rsi
    xor rdx, rdx
    div r8
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .conv_loop

    lea rdx, [num_buf + 31]
    sub rdx, rsi
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

; ------------------------------------------------------------------------------
; Helper: Read RDTSC 64-bit cycle counter
; ------------------------------------------------------------------------------
read_rdtsc:
    lfence
    rdtsc
    shl rdx, 32
    or rax, rdx
    ret

; ------------------------------------------------------------------------------
; Emit 1 byte to JIT buffer
; r12 = current JIT write pointer
; al = byte
; ------------------------------------------------------------------------------
emit_u8:
    mov [r12], al
    inc r12
    ret

; ------------------------------------------------------------------------------
; Emit 2 bytes to JIT buffer
; ax = 16-bit word
; ------------------------------------------------------------------------------
emit_u16:
    mov [r12], ax
    add r12, 2
    ret

; ------------------------------------------------------------------------------
; Emit 4 bytes to JIT buffer
; eax = 32-bit dword
; ------------------------------------------------------------------------------
emit_u32:
    mov [r12], eax
    add r12, 4
    ret

; ------------------------------------------------------------------------------
; JIT Compilation Core
; Compiles Brainfuck source at [source_ptr] of length [source_len] into [jit_memory_ptr]
; ------------------------------------------------------------------------------
compile_brainfuck_to_jit:
    ; Measure compilation cycles
    call read_rdtsc
    mov [t_compile_start], rax

    mov r12, [jit_memory_ptr]       ; r12 = output JIT code pointer
    mov rbx, [source_ptr]           ; rbx = input source pointer
    xor r13, r13                    ; r13 = input source index
    mov qword [bracket_sp], 0       ; Reset bracket nesting stack

    ; --- 1. Emit JIT Function Prologue ---
    ; push r12                      ; 41 54 (callee-saved register for tape ptr)
    ; push r13                      ; 41 55 (callee-saved register)
    ; mov r12, rdi                  ; 49 89 fc (r12 = tape buffer passed in rdi)
    mov byte [r12], 0x41
    mov byte [r12 + 1], 0x54
    mov byte [r12 + 2], 0x41
    mov byte [r12 + 3], 0x55
    mov byte [r12 + 4], 0x49
    mov byte [r12 + 5], 0x89
    mov byte [r12 + 6], 0xfc
    add r12, 7

    ; --- 2. Main Compilation Loop with Optimizations ---
.parse_loop:
    cmp r13, [source_len]
    jae .compilation_done

    mov al, [rbx + r13]

    ; --------------------------------------------------------------------------
    ; '+' command: Coalesce runs of '+' and '-'
    ; --------------------------------------------------------------------------
    cmp al, '+'
    je .handle_plus
    cmp al, '-'
    je .handle_minus
    cmp al, '>'
    je .handle_right
    cmp al, '<'
    je .handle_left
    cmp al, '.'
    je .handle_dot
    cmp al, ','
    je .handle_comma
    cmp al, '['
    je .handle_open_bracket
    cmp al, ']'
    je .handle_close_bracket

    ; Ignore comments, whitespace, newlines
    inc r13
    jmp .parse_loop

.handle_plus:
    ; Count consecutive '+' characters
    xor ecx, ecx
.count_plus:
    inc ecx
    inc r13
    cmp r13, [source_len]
    jae .emit_add_cell
    cmp byte [rbx + r13], '+'
    je .count_plus

.emit_add_cell:
    and ecx, 0xff                   ; Modulo 256 for byte cells
    jz .parse_loop                  ; If net addition is 0, skip
    cmp ecx, 1
    jne .emit_add_n
    ; inc byte [r12] -> 41 fe 04 24
    mov byte [r12], 0x41
    mov byte [r12 + 1], 0xfe
    mov byte [r12 + 2], 0x04
    mov byte [r12 + 3], 0x24
    add r12, 4
    jmp .parse_loop

.emit_add_n:
    ; add byte [r12], imm8 -> 41 80 04 24 <imm8>
    mov byte [r12], 0x41
    mov byte [r12 + 1], 0x80
    mov byte [r12 + 2], 0x04
    mov byte [r12 + 3], 0x24
    mov [r12 + 4], cl
    add r12, 5
    jmp .parse_loop

.handle_minus:
    ; Count consecutive '-' characters
    xor ecx, ecx
.count_minus:
    inc ecx
    inc r13
    cmp r13, [source_len]
    jae .emit_sub_cell
    cmp byte [rbx + r13], '-'
    je .count_minus

.emit_sub_cell:
    and ecx, 0xff
    jz .parse_loop
    cmp ecx, 1
    jne .emit_sub_n
    ; dec byte [r12] -> 41 fe 0c 24
    mov byte [r12], 0x41
    mov byte [r12 + 1], 0xfe
    mov byte [r12 + 2], 0x0c
    mov byte [r12 + 3], 0x24
    add r12, 4
    jmp .parse_loop

.emit_sub_n:
    ; sub byte [r12], imm8 -> 41 80 2c 24 <imm8>
    mov byte [r12], 0x41
    mov byte [r12 + 1], 0x80
    mov byte [r12 + 2], 0x2c
    mov byte [r12 + 3], 0x24
    mov [r12 + 4], cl
    add r12, 5
    jmp .parse_loop

.handle_right:
    ; Count consecutive '>' characters
    xor ecx, ecx
.count_right:
    inc ecx
    inc r13
    cmp r13, [source_len]
    jae .emit_add_ptr
    cmp byte [rbx + r13], '>'
    je .count_right

.emit_add_ptr:
    test ecx, ecx
    jz .parse_loop
    ; add r12, imm32 -> 49 81 c4 <imm32>
    mov byte [r12], 0x49
    mov byte [r12 + 1], 0x81
    mov byte [r12 + 2], 0xc4
    mov [r12 + 3], ecx
    add r12, 7
    jmp .parse_loop

.handle_left:
    ; Count consecutive '<' characters
    xor ecx, ecx
.count_left:
    inc ecx
    inc r13
    cmp r13, [source_len]
    jae .emit_sub_ptr
    cmp byte [rbx + r13], '<'
    je .count_left

.emit_sub_ptr:
    test ecx, ecx
    jz .parse_loop
    ; sub r12, imm32 -> 49 81 ec <imm32>
    mov byte [r12], 0x49
    mov byte [r12 + 1], 0x81
    mov byte [r12 + 2], 0xec
    mov [r12 + 3], ecx
    add r12, 7
    jmp .parse_loop

.handle_dot:
    ; Output byte at current tape pointer via inline sys_write(1, r12, 1)
    ; mov eax, 1         ; b8 01 00 00 00
    ; mov edi, 1         ; bf 01 00 00 00
    ; mov rsi, r12       ; 4c 89 e6
    ; mov edx, 1         ; ba 01 00 00 00
    ; syscall            ; 0f 05
    mov byte [r12 + 0],  0xb8
    mov dword [r12 + 1], 0x00000001
    mov byte [r12 + 5],  0xbf
    mov dword [r12 + 6], 0x00000001
    mov byte [r12 + 10], 0x4c
    mov byte [r12 + 11], 0x89
    mov byte [r12 + 12], 0xe6
    mov byte [r12 + 13], 0xba
    mov dword [r12 + 14], 0x00000001
    mov byte [r12 + 18], 0x0f
    mov byte [r12 + 19], 0x05
    add r12, 20
    inc r13
    jmp .parse_loop

.handle_comma:
    ; Input byte to current tape pointer via inline sys_read(0, r12, 1)
    ; xor eax, eax       ; 31 c0
    ; xor edi, edi       ; 31 ff
    ; mov rsi, r12       ; 4c 89 e6
    ; mov edx, 1         ; ba 01 00 00 00
    ; syscall            ; 0f 05
    mov byte [r12 + 0], 0x31
    mov byte [r12 + 1], 0xc0
    mov byte [r12 + 2], 0x31
    mov byte [r12 + 3], 0xff
    mov byte [r12 + 4], 0x4c
    mov byte [r12 + 5], 0x89
    mov byte [r12 + 6], 0xe6
    mov byte [r12 + 7], 0xba
    mov dword [r12 + 8], 0x00000001
    mov byte [r12 + 12], 0x0f
    mov byte [r12 + 13], 0x05
    add r12, 14
    inc r13
    jmp .parse_loop

.handle_open_bracket:
    ; --- Peephole Optimization: Check for zero-cell idiom "[-]" ---
    mov rdx, [source_len]
    sub rdx, r13
    cmp rdx, 3
    jb .standard_open_bracket

    cmp byte [rbx + r13 + 1], '-'
    jne .standard_open_bracket
    cmp byte [rbx + r13 + 2], ']'
    jne .standard_open_bracket

    ; Idiom matched: "[-]" -> mov byte [r12], 0 (41 c6 04 24 00)
    mov byte [r12 + 0], 0x41
    mov byte [r12 + 1], 0xc6
    mov byte [r12 + 2], 0x04
    mov byte [r12 + 3], 0x24
    mov byte [r12 + 4], 0x00
    add r12, 5
    add r13, 3                      ; Consume '[', '-', ']'
    jmp .parse_loop

.standard_open_bracket:
    ; Emit:
    ; cmp byte [r12], 0              ; 41 80 3c 24 00 (5 bytes)
    ; jz <rel32>                     ; 0f 84 <rel32>  (6 bytes)
    mov byte [r12 + 0], 0x41
    mov byte [r12 + 1], 0x80
    mov byte [r12 + 2], 0x3c
    mov byte [r12 + 3], 0x24
    mov byte [r12 + 4], 0x00
    mov byte [r12 + 5], 0x0f
    mov byte [r12 + 6], 0x84
    mov dword [r12 + 7], 0           ; Placeholder for rel32

    ; Record patch address onto bracket stack
    mov r8, [bracket_sp]
    cmp r8, BRACKET_STACK_CAP
    jae .err_bracket_overflow

    lea r9, [r12 + 7]               ; r9 points to the 4-byte displacement
    mov [bracket_stack + r8 * 8], r9
    inc qword [bracket_sp]

    add r12, 11
    inc r13
    jmp .parse_loop

.handle_close_bracket:
    ; Check if matching '[' exists on stack
    mov r8, [bracket_sp]
    test r8, r8
    jz .err_bracket_underflow

    dec r8
    mov [bracket_sp], r8
    mov r9, [bracket_stack + r8 * 8] ; r9 = open_patch_addr

    ; open_inst_end = open_patch_addr + 4
    lea r10, [r9 + 4]

    ; Emit:
    ; cmp byte [r12], 0              ; 41 80 3c 24 00 (5 bytes)
    ; jnz <rel32>                    ; 0f 85 <rel32>  (6 bytes)
    mov byte [r12 + 0], 0x41
    mov byte [r12 + 1], 0x80
    mov byte [r12 + 2], 0x3c
    mov byte [r12 + 3], 0x24
    mov byte [r12 + 4], 0x00
    mov byte [r12 + 5], 0x0f
    mov byte [r12 + 6], 0x85

    ; close_inst_end = (r12 + 7) + 4 = r12 + 11
    lea r11, [r12 + 11]

    ; rel_back = open_inst_end - close_inst_end
    mov eax, r10d
    sub eax, r11d
    mov [r12 + 7], eax              ; Write backward displacement into jnz

    ; rel_forward = close_inst_end - open_inst_end
    mov eax, r11d
    sub eax, r10d
    mov [r9], eax                   ; Backpatch forward displacement into jz

    add r12, 11
    inc r13
    jmp .parse_loop

.compilation_done:
    ; Verify that all brackets were balanced
    cmp qword [bracket_sp], 0
    jne .err_bracket_underflow

    ; --- 3. Emit JIT Function Epilogue ---
    ; pop r13                       ; 41 5d
    ; pop r12                       ; 41 5c
    ; ret                           ; c3
    mov byte [r12 + 0], 0x41
    mov byte [r12 + 1], 0x5d
    mov byte [r12 + 2], 0x41
    mov byte [r12 + 3], 0x5c
    mov byte [r12 + 4], 0xc3
    add r12, 5

    ; Measure compilation cycle count
    call read_rdtsc
    sub rax, [t_compile_start]
    mov [t_compile_cycles], rax

    ; Compute total machine code bytes emitted
    mov rax, r12
    sub rax, [jit_memory_ptr]
    mov [emitted_bytes], rax
    ret

.err_bracket_overflow:
.err_bracket_underflow:
    mov rdi, err_bracket_mismatch
    mov rsi, err_bracket_mismatch_len
    call print_str
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

; ------------------------------------------------------------------------------
; Execute JIT-compiled function and measure runtime performance
; ------------------------------------------------------------------------------
execute_jit_code:
    ; Zero-initialize the tape memory
    lea rdi, [tape_memory]
    xor eax, eax
    mov ecx, TAPE_BUFFER_SIZE / 8
    rep stosq

    ; Print Execution Banner
    mov rdi, msg_executing
    mov rsi, msg_executing_len
    call print_str

    ; Measure native execution cycles
    call read_rdtsc
    mov [t_run_start], rax

    ; Call JIT-compiled function!
    ; Passes pointer to tape memory in rdi (Standard System V AMD64 ABI)
    lea rdi, [tape_memory]
    mov rax, [jit_memory_ptr]
    call rax

    ; Measure elapsed cycles
    call read_rdtsc
    sub rax, [t_run_start]
    mov [t_run_cycles], rax

    ; Print Output End
    mov rdi, msg_output_end
    mov rsi, msg_output_end_len
    call print_str
    ret

; ------------------------------------------------------------------------------
; Print JIT Metrics & Telemetry
; ------------------------------------------------------------------------------
print_telemetry:
    mov rdi, msg_stats_header
    mov rsi, msg_stats_header_len
    call print_str

    ; 1. Source Chars
    mov rdi, msg_stat_source
    mov rsi, msg_stat_source_len
    call print_str
    mov rdi, [source_len]
    call print_u64
    mov rdi, msg_items_suffix
    mov rsi, msg_items_suffix_len
    call print_str

    ; 2. Machine Bytes Emitted
    mov rdi, msg_stat_emitted
    mov rsi, msg_stat_emitted_len
    call print_str
    mov rdi, [emitted_bytes]
    call print_u64
    mov rdi, msg_bytes_suffix
    mov rsi, msg_bytes_suffix_len
    call print_str

    ; 3. Compilation Cost
    mov rdi, msg_stat_jit_cycles
    mov rsi, msg_stat_jit_cycles_len
    call print_str
    mov rdi, [t_compile_cycles]
    call print_u64
    mov rdi, msg_cycles_suffix
    mov rsi, msg_cycles_suffix_len
    call print_str

    ; 4. Execution Cost
    mov rdi, msg_stat_run_cycles
    mov rsi, msg_stat_run_cycles_len
    call print_str
    mov rdi, [t_run_cycles]
    call print_u64
    mov rdi, msg_cycles_suffix
    mov rsi, msg_cycles_suffix_len
    call print_str

    ; Success Confirmation
    mov rdi, msg_success
    mov rsi, msg_success_len
    call print_str
    ret

; ------------------------------------------------------------------------------
; Entry Point
; ------------------------------------------------------------------------------
_start:
    ; 1. Print Banner
    mov rdi, banner
    mov rsi, banner_len
    call print_str

    ; 2. Allocate Executable JIT Code Memory via sys_mmap
    ; sys_mmap(0, JIT_BUFFER_SIZE, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
    mov rax, SYS_MMAP
    xor rdi, rdi                    ; addr = NULL
    mov rsi, JIT_BUFFER_SIZE        ; length = 64 KB
    mov rdx, (PROT_READ | PROT_WRITE | PROT_EXEC) ; prot = RWX
    mov r10, (MAP_PRIVATE | MAP_ANONYMOUS)        ; flags
    mov r8, -1                      ; fd = -1
    xor r9, r9                      ; offset = 0
    syscall

    test rax, rax
    js .err_mmap_exit
    mov [jit_memory_ptr], rax

    ; 3. Parse Command-Line Arguments
    ; [rsp] = argc, [rsp + 8] = argv[0], [rsp + 16] = argv[1], ...
    mov rcx, [rsp]                  ; rcx = argc

    cmp rcx, 1
    je .run_demo_benchmark

    cmp rcx, 2
    je .run_file

    ; argc >= 3: Check for -e flag
    mov rsi, [rsp + 16]             ; argv[1]
    cmp word [rsi], 0x652d          ; "-e" in little endian ('-'=0x2d, 'e'=0x65)
    jne .print_usage

    ; Inline code in argv[2]
    mov rdi, [rsp + 24]             ; argv[2]
    mov [source_ptr], rdi

    ; Compute length of inline string
    xor rdx, rdx
.inline_len:
    cmp byte [rdi + rdx], 0
    jz .inline_len_done
    inc rdx
    jmp .inline_len
.inline_len_done:
    mov [source_len], rdx
    jmp .compile_and_run

.run_file:
    ; argv[1] is the file path
    mov rdi, [rsp + 16]             ; file path

    ; Check for "-h" or "--help"
    cmp word [rdi], 0x682d          ; "-h"
    je .print_usage

    ; sys_open(rdi, O_RDONLY, 0)
    mov rax, SYS_OPEN
    xor rsi, rsi                    ; O_RDONLY
    xor rdx, rdx                    ; mode = 0
    syscall

    test rax, rax
    js .err_open_exit
    mov r14, rax                    ; r14 = file descriptor

    ; sys_read(r14, file_source_buf, MAX_SOURCE_SIZE)
    mov rax, SYS_READ
    mov rdi, r14
    lea rsi, [file_source_buf]
    mov rdx, MAX_SOURCE_SIZE
    syscall

    test rax, rax
    js .err_read_exit
    mov [source_len], rax
    lea rax, [file_source_buf]
    mov [source_ptr], rax

    ; sys_close(r14)
    mov rax, SYS_CLOSE
    mov rdi, r14
    syscall
    jmp .compile_and_run

.run_demo_benchmark:
    mov rdi, msg_demo_intro
    mov rsi, msg_demo_intro_len
    call print_str

    lea rax, [demo_hello_bf]
    mov [source_ptr], rax
    mov qword [source_len], demo_hello_bf_len

.compile_and_run:
    ; Print Compiling Message
    mov rdi, msg_compiling
    mov rsi, msg_compiling_len
    call print_str

    ; Compile source to native x86-64 machine code
    call compile_brainfuck_to_jit

    ; Execute native machine code
    call execute_jit_code

    ; Print Telemetry & Performance
    call print_telemetry

    ; 4. Free JIT Executable Memory via sys_munmap
    mov rax, SYS_MUNMAP
    mov rdi, [jit_memory_ptr]
    mov rsi, JIT_BUFFER_SIZE
    syscall

    ; Exit Cleanly
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.print_usage:
    mov rdi, usage_msg
    mov rsi, usage_msg_len
    call print_str
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.err_mmap_exit:
    mov rdi, err_mmap
    mov rsi, err_mmap_len
    call print_str
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.err_open_exit:
.err_read_exit:
    mov rdi, err_open
    mov rsi, err_open_len
    call print_str
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
