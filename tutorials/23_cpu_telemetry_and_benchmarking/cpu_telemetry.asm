; ==============================================================================
; Program: cpu_telemetry.asm
; Description: Interrogates CPU using CPUID for vendor string and benchmarks with RDTSC
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <cpuid.h>
; #include <x86intrin.h>
; #include <stdio.h>
; #include <unistd.h>
;
; int main(void) {
;     // 1. Query CPU vendor via CPUID leaf 0
;     unsigned int eax, ebx, ecx, edx;
;     __cpuid(0, eax, ebx, ecx, edx);
;     char vendor[13];
;     *(uint32_t *)&vendor[0] = ebx;
;     *(uint32_t *)&vendor[4] = edx;
;     *(uint32_t *)&vendor[8] = ecx;
;     vendor[12] = '\0';
;     printf("[+] CPU Vendor String: %s\n", vendor);
;
;     // 2. Hardware benchmarking using RDTSC / LFENCE
;     _mm_lfence();
;     uint64_t start = __rdtsc();
;     _mm_lfence();
;
;     volatile uint64_t counter = 0;
;     for (uint64_t i = 0; i < 1000000; i++) {
;         counter++;
;     }
;
;     _mm_lfence();
;     uint64_t end = __rdtsc();
;     _mm_lfence();
;     uint64_t elapsed = end - start;
;
;     write(STDOUT_FILENO, "[+] Benchmarked 1,000,000 iterations cycle latency measured successfully!\n", 75);
;     _exit(0);
; }
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
    ; C equivalent: __cpuid(0, eax, ebx, ecx, edx);
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
    ; C equivalent: uint64_t start = __rdtsc(); ... uint64_t end = __rdtsc();
    ; --------------------------------------------------------------------------
    lfence                      ; Serialize CPU execution pipeline
    rdtsc                       ; Read Time-Stamp Counter into EDX:EAX
    shl rdx, 32
    or  rax, rdx
    mov r8, rax                 ; r8 = start cycle timestamp

    ; Workload: 1,000,000 loop iterations
    mov rcx, 1000000
    xor rbx, rbx
.workload:
    inc rbx
    dec rcx
    jnz .workload

    ; Read end timestamp
    lfence
    rdtsc
    shl rdx, 32
    or  rax, rdx                ; rax = end cycle timestamp

    sub rax, r8                 ; rax = elapsed cycles
    mov [cycles_elapsed], rax

    ; Print benchmark confirmation
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_bench]
    mov rdx, len_bench
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
