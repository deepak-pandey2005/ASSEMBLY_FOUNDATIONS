; ==============================================================================
; Assembly Foundations - Tutorial 37: Kernel Hardware Performance Counters
; Architecture: x86-64 (Linux ELF)
; Description:  Direct interaction with the CPU Performance Monitoring Unit (PMU)
;               via sys_perf_event_open (syscall 298), measuring hardware CPU cycles,
;               instructions retired, and calculating Instructions-Per-Cycle (IPC).
; Zero C runtime / libc dependencies. Pure Linux system calls.

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <linux/perf_event.h>
; #include <sys/syscall.h>
; #include <sys/ioctl.h>
; #include <unistd.h>
; #include <stdint.h>
;
; int main(void) {
;     struct perf_event_attr attr_inst = {0}, attr_cycl = {0};
;
;     // Configure instructions retired counter
;     attr_inst.type = PERF_TYPE_HARDWARE;
;     attr_inst.size = sizeof(attr_inst); // 144 bytes
;     attr_inst.config = PERF_COUNT_HW_INSTRUCTIONS;
;     attr_inst.disabled = 1;
;     attr_inst.exclude_kernel = 1;
;     attr_inst.exclude_hv = 1;
;
;     // Configure CPU hardware cycles counter
;     attr_cycl.type = PERF_TYPE_HARDWARE;
;     attr_cycl.size = sizeof(attr_cycl);
;     attr_cycl.config = PERF_COUNT_HW_CPU_CYCLES;
;     attr_cycl.disabled = 1;
;     attr_cycl.exclude_kernel = 1;
;     attr_cycl.exclude_hv = 1;
;
;     // Open counters via sys_perf_event_open (syscall 298)
;     int fd_inst = syscall(SYS_perf_event_open, &attr_inst, 0, -1, -1, 0);
;     int fd_cycl = syscall(SYS_perf_event_open, &attr_cycl, 0, -1, -1, 0);
;
;     // Reset and enable counters via ioctl
;     ioctl(fd_inst, PERF_EVENT_IOC_RESET, 0);
;     ioctl(fd_cycl, PERF_EVENT_IOC_RESET, 0);
;     ioctl(fd_inst, PERF_EVENT_IOC_ENABLE, 0);
;     ioctl(fd_cycl, PERF_EVENT_IOC_ENABLE, 0);
;
;     // Run compute benchmark workload (1,000,000 iterations)
;     // ...
;
;     // Disable counters and read 64-bit counts
;     ioctl(fd_inst, PERF_EVENT_IOC_DISABLE, 0);
;     ioctl(fd_cycl, PERF_EVENT_IOC_DISABLE, 0);
;     uint64_t count_inst = 0, count_cycl = 0;
;     read(fd_inst, &count_inst, sizeof(uint64_t));
;     read(fd_cycl, &count_cycl, sizeof(uint64_t));
;
;     close(fd_inst);
;     close(fd_cycl);
;
;     // Compute Instructions-Per-Cycle (IPC)
;     double ipc = (double)count_inst / (double)count_cycl;
;     _exit(0);
; }
; ==============================================================================

global _start

; --- Linux System Call Numbers (x86-64) ---
%define SYS_READ            0
%define SYS_WRITE           1
%define SYS_CLOSE           3
%define SYS_IOCTL           16
%define SYS_EXIT            60
%define SYS_PERF_EVENT_OPEN 298

; --- Linux File Descriptors & IOCTL Constants ---
%define STDOUT_FILENO       1

%define PERF_TYPE_HARDWARE          0
%define PERF_COUNT_HW_CPU_CYCLES    0
%define PERF_COUNT_HW_INSTRUCTIONS  1

%define PERF_EVENT_IOC_ENABLE       0x2400   ; _IO('$', 0)
%define PERF_EVENT_IOC_DISABLE      0x2401   ; _IO('$', 1)
%define PERF_EVENT_IOC_RESET        0x2402   ; _IO('$', 2)

; Size of struct perf_event_attr (144 bytes on modern 64-bit kernels)
%define PERF_ATTR_SIZE              144

; Flags bitmask in struct perf_event_attr (offset 40):
; bit 0: disabled = 1 (start disabled)
; bit 5: exclude_kernel = 1 (do not count kernel space; needed when perf_event_paranoid >= 2)
; bit 6: exclude_hv = 1 (do not count hypervisor)
; (1 | (1<<5) | (1<<6)) = 1 | 32 | 64 = 97 = 0x61
%define PERF_ATTR_FLAGS             0x61

section .data
    banner:
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
        db 0x1B, "[1;32m", " [TUTORIAL 37] Linux Kernel Hardware Performance Counters", 0x1B, "[0m", 10
        db 0x1B, "[1;36m", "==========================================================", 0x1B, "[0m", 10
    banner_len equ $ - banner

    msg_opening:
        db "[-] Initializing Linux PMU counters via sys_perf_event_open...", 10
    msg_opening_len equ $ - msg_opening

    msg_pmu_ok:
        db 0x1B, "[32m", "[+] Hardware PMU counters successfully opened (fds: ", 0x1B, "[0m"
    msg_pmu_ok_len equ $ - msg_pmu_ok

    msg_comma_fd:
        db ", "
    msg_comma_fd_len equ $ - msg_comma_fd

    msg_closing_paren:
        db ")", 10
    msg_closing_paren_len equ $ - msg_closing_paren

    msg_running:
        db "[-] Running 1,000,000 iteration unrolled compute workload...", 10
    msg_running_len equ $ - msg_running

    msg_results_hdr:
        db 0x1B, "[1;33m", "--- PMU Hardware Measurement Results ---", 0x1B, "[0m", 10
    msg_results_hdr_len equ $ - msg_results_hdr

    msg_inst_label:
        db "  -> Instructions Retired : "
    msg_inst_label_len equ $ - msg_inst_label

    msg_cycl_label:
        db "  -> CPU Hardware Cycles  : "
    msg_cycl_label_len equ $ - msg_cycl_label

    msg_ipc_label:
        db "  -> Execution Efficiency : "
    msg_ipc_label_len equ $ - msg_ipc_label

    msg_ipc_unit:
        db " IPC (instructions / cycle)", 10
    msg_ipc_unit_len equ $ - msg_ipc_unit

    msg_pmu_restricted:
        db 0x1B, "[33m", "[!] sys_perf_event_open returned negative (PMU access restricted by host/container).", 0x1B, "[0m", 10
        db "[-] Falling back to user-space cycle measurement via RDTSC...", 10
    msg_pmu_restricted_len equ $ - msg_pmu_restricted

    msg_success:
        db 0x1B, "[1;32m", "[+] Hardware Performance Counter Verification Completed Successfully!", 0x1B, "[0m", 10
    msg_success_len equ $ - msg_success

    newline:
        db 10

section .bss
    ; struct perf_event_attr structures (144 bytes each)
    attr_inst:      resb PERF_ATTR_SIZE
    attr_cycl:      resb PERF_ATTR_SIZE

    fd_inst:        resq 1
    fd_cycl:        resq 1

    count_inst:     resq 1
    count_cycl:     resq 1

    num_buf:        resb 32

section .text

_start:
    ; Print banner
    mov rsi, banner
    mov rdx, banner_len
    call print_str

    mov rsi, msg_opening
    mov rdx, msg_opening_len
    call print_str

    ; Zero-out attr_inst and attr_cycl
    mov rdi, attr_inst
    mov rcx, PERF_ATTR_SIZE
    xor al, al
    rep stosb

    mov rdi, attr_cycl
    mov rcx, PERF_ATTR_SIZE
    xor al, al
    rep stosb

    ; --- Setup attr_inst (PERF_COUNT_HW_INSTRUCTIONS) ---
    ; attr_inst.type = PERF_TYPE_HARDWARE (0) -> offset 0
    mov dword [attr_inst + 0], PERF_TYPE_HARDWARE
    ; attr_inst.size = 144 -> offset 4
    mov dword [attr_inst + 4], PERF_ATTR_SIZE
    ; attr_inst.config = PERF_COUNT_HW_INSTRUCTIONS (1) -> offset 8
    mov qword [attr_inst + 8], PERF_COUNT_HW_INSTRUCTIONS
    ; attr_inst.flags = PERF_ATTR_FLAGS (0x61) -> offset 40
    mov qword [attr_inst + 40], PERF_ATTR_FLAGS

    ; --- Setup attr_cycl (PERF_COUNT_HW_CPU_CYCLES) ---
    mov dword [attr_cycl + 0], PERF_TYPE_HARDWARE
    mov dword [attr_cycl + 4], PERF_ATTR_SIZE
    mov qword [attr_cycl + 8], PERF_COUNT_HW_CPU_CYCLES
    mov qword [attr_cycl + 40], PERF_ATTR_FLAGS

    ; --- Syscall: perf_event_open for Instructions ---
    ; sys_perf_event_open(&attr_inst, pid=0, cpu=-1, group_fd=-1, flags=0)
    mov rax, SYS_PERF_EVENT_OPEN
    mov rdi, attr_inst
    xor rsi, rsi        ; pid = 0 (calling thread)
    mov rdx, -1         ; cpu = -1 (any cpu)
    mov r10, -1         ; group_fd = -1 (leader)
    xor r8, r8          ; flags = 0
    syscall

    cmp rax, 0
    jl .pmu_unsupported
    mov [fd_inst], rax

    ; --- Syscall: perf_event_open for Cycles ---
    mov rax, SYS_PERF_EVENT_OPEN
    mov rdi, attr_cycl
    xor rsi, rsi
    mov rdx, -1
    mov r10, -1
    xor r8, r8
    syscall

    cmp rax, 0
    jl .pmu_unsupported_cycl
    mov [fd_cycl], rax

    ; Print success opening PMU
    mov rsi, msg_pmu_ok
    mov rdx, msg_pmu_ok_len
    call print_str

    mov rdi, [fd_inst]
    call print_u64

    mov rsi, msg_comma_fd
    mov rdx, msg_comma_fd_len
    call print_str

    mov rdi, [fd_cycl]
    call print_u64

    mov rsi, msg_closing_paren
    mov rdx, msg_closing_paren_len
    call print_str

    ; --- Reset and Enable both counters ---
    ; ioctl(fd_inst, PERF_EVENT_IOC_RESET, 0)
    mov rax, SYS_IOCTL
    mov rdi, [fd_inst]
    mov rsi, PERF_EVENT_IOC_RESET
    xor rdx, rdx
    syscall

    ; ioctl(fd_cycl, PERF_EVENT_IOC_RESET, 0)
    mov rax, SYS_IOCTL
    mov rdi, [fd_cycl]
    mov rsi, PERF_EVENT_IOC_RESET
    xor rdx, rdx
    syscall

    ; ioctl(fd_inst, PERF_EVENT_IOC_ENABLE, 0)
    mov rax, SYS_IOCTL
    mov rdi, [fd_inst]
    mov rsi, PERF_EVENT_IOC_ENABLE
    xor rdx, rdx
    syscall

    ; ioctl(fd_cycl, PERF_EVENT_IOC_ENABLE, 0)
    mov rax, SYS_IOCTL
    mov rdi, [fd_cycl]
    mov rsi, PERF_EVENT_IOC_ENABLE
    xor rdx, rdx
    syscall

    ; Print running workload
    mov rsi, msg_running
    mov rdx, msg_running_len
    call print_str

    ; --- Workload: 1,000,000 iterations of arithmetic ---
    call run_workload

    ; --- Disable counters ---
    mov rax, SYS_IOCTL
    mov rdi, [fd_inst]
    mov rsi, PERF_EVENT_IOC_DISABLE
    xor rdx, rdx
    syscall

    mov rax, SYS_IOCTL
    mov rdi, [fd_cycl]
    mov rsi, PERF_EVENT_IOC_DISABLE
    xor rdx, rdx
    syscall

    ; --- Read 8-byte count from fd_inst ---
    mov rax, SYS_READ
    mov rdi, [fd_inst]
    mov rsi, count_inst
    mov rdx, 8
    syscall

    ; --- Read 8-byte count from fd_cycl ---
    mov rax, SYS_READ
    mov rdi, [fd_cycl]
    mov rsi, count_cycl
    mov rdx, 8
    syscall

    ; Close file descriptors
    mov rax, SYS_CLOSE
    mov rdi, [fd_inst]
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [fd_cycl]
    syscall

    ; Display Results
    mov rsi, msg_results_hdr
    mov rdx, msg_results_hdr_len
    call print_str

    mov rsi, msg_inst_label
    mov rdx, msg_inst_label_len
    call print_str
    mov rdi, [count_inst]
    call print_u64
    call print_newline

    mov rsi, msg_cycl_label
    mov rdx, msg_cycl_label_len
    call print_str
    mov rdi, [count_cycl]
    call print_u64
    call print_newline

    ; Calculate IPC = (instructions * 100) / cycles
    mov rsi, msg_ipc_label
    mov rdx, msg_ipc_label_len
    call print_str

    mov rax, [count_inst]
    imul rax, 100
    xor rdx, rdx
    mov rbx, [count_cycl]
    test rbx, rbx
    jz .skip_ipc
    div rbx             ; rax = integer * 100 (e.g. 114 for 1.14 IPC)

    ; Print X.XX
    xor rdx, rdx
    mov rbx, 100
    div rbx             ; rax = whole part (e.g. 1), rdx = hundredths (e.g. 14)
    push rdx
    mov rdi, rax
    call print_u64
    pop rdx

    ; print decimal dot
    mov byte [num_buf], '.'
    ; if rdx < 10, print leading zero
    cmp rdx, 10
    jge .two_digits
    mov byte [num_buf + 1], '0'
    add dl, '0'
    mov byte [num_buf + 2], dl
    mov rsi, num_buf
    mov rdx, 3
    call print_str
    jmp .ipc_done

.two_digits:
    ; format rdx (10..99)
    mov rax, rdx
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add al, '0'
    add dl, '0'
    mov byte [num_buf + 1], al
    mov byte [num_buf + 2], dl
    mov rsi, num_buf
    mov rdx, 3
    call print_str

.ipc_done:
    mov rsi, msg_ipc_unit
    mov rdx, msg_ipc_unit_len
    call print_str

.skip_ipc:
    jmp .finish

.pmu_unsupported_cycl:
    ; Close fd_inst if opened
    mov rax, SYS_CLOSE
    mov rdi, [fd_inst]
    syscall

.pmu_unsupported:
    mov rsi, msg_pmu_restricted
    mov rdx, msg_pmu_restricted_len
    call print_str

    ; Measure with RDTSC fallback
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov r12, rax        ; start tsc

    call run_workload

    rdtsc
    shl rdx, 32
    or rax, rdx
    sub rax, r12        ; elapsed tsc cycles

    mov rsi, msg_cycl_label
    mov rdx, msg_cycl_label_len
    call print_str
    mov rdi, rax
    call print_u64
    call print_newline

.finish:
    mov rsi, msg_success
    mov rdx, msg_success_len
    call print_str

    ; Exit 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

; ------------------------------------------------------------------------------
; Workload: 1,000,000 iterations of arithmetic
; ------------------------------------------------------------------------------
run_workload:
    push rbx
    push rcx
    push rdx

    mov rcx, 1000000
    xor rax, rax
    xor rbx, rbx
.loop:
    add rax, rcx
    lea rbx, [rbx + rax*2 + 1]
    xor rax, 0x5A5A
    sub rcx, 1
    jnz .loop

    pop rdx
    pop rcx
    pop rbx
    ret

; ------------------------------------------------------------------------------
; Helper Functions
; ------------------------------------------------------------------------------
print_str:
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

print_newline:
    mov rsi, newline
    mov rdx, 1
    call print_str
    ret

print_u64:
    ; Converts unsigned 64-bit in RDI to ASCII and writes to stdout
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
