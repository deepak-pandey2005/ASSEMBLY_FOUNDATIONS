; ==============================================================================
; Program: cpu_telemetry.asm
; Description: Interrogates CPU using CPUID for vendor string and benchmarks with RDTSC
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    msg_vendor: db "[+] CPU Vendor String: "
    len_vendor: equ $ - msg_vendor

    msg_bench:  db "[+] Benchmarked 1,000,000 iterations cycle latency measured successfully!", 10
    len_bench:  equ $ - msg_bench

    newline:    db 10

section .bss
    vendor_str: resb 13         ; 12 bytes string + 1 null terminator
    cycles_elapsed: resq 1

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. QUERY CPU VENDOR VIA CPUID (Leaf 0)
    ; --------------------------------------------------------------------------
    xor eax, eax                ; EAX = 0 (Query vendor string)
    cpuid                       ; Writes 12 chars to EBX, EDX, ECX

    ; Store in correct sequence: EBX -> EDX -> ECX
    mov dword [vendor_str], ebx
    mov dword [vendor_str + 4], edx
    mov dword [vendor_str + 8], ecx
    mov byte  [vendor_str + 12], 0

    ; Print Vendor Prefix
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    lea rsi, [msg_vendor]
    mov rdx, len_vendor
    syscall

    ; Print Extracted Vendor String (e.g. "GenuineIntel" or "AuthenticAMD")
    mov rax, 1
    mov rdi, 1
    lea rsi, [vendor_str]
    mov rdx, 12
    syscall

    ; Print Newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    ; --------------------------------------------------------------------------
    ; 2. HARDWARE BENCHMARKING USING RDTSC
    ; --------------------------------------------------------------------------
    ; Serialize pipeline before reading start cycles
    xor eax, eax
    cpuid
    rdtsc                       ; EDX:EAX = start timestamp counter
    shl rdx, 32
    or  rax, rdx
    mov r12, rax                ; r12 = start_cycles

    ; Benchmark loop: execute 1,000,000 iterations of simple arithmetic
    mov rcx, 1000000
.bench_loop:
    nop
    dec rcx
    jnz .bench_loop

    ; Read end timestamp with RDTSCP (serialized reading)
    rdtscp                      ; EDX:EAX = end timestamp counter
    shl rdx, 32
    or  rax, rdx
    sub rax, r12                ; rax = end_cycles - start_cycles
    mov [cycles_elapsed], rax

    ; Print Benchmark Completed message
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_bench]
    mov rdx, len_bench
    syscall

    ; Clean Exit
    mov rax, 60
    xor rdi, rdi
    syscall
