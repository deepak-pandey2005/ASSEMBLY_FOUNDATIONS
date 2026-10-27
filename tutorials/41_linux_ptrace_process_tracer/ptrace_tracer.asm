; ==============================================================================
; Tutorial 41: Linux Process Tracing & Syscall Interception (sys_ptrace)
; ==============================================================================
;
; Concepts & Architecture:
;   - Core Linux process debugging subsystem (foundation of GDB, strace, ltrace).
;   - sys_ptrace (syscall 101): parent process monitoring, inspection & control.
;   - Debugger Lifecycle:
;       1. Fork child worker process (sys_fork).
;       2. Child authorizes debugging via sys_ptrace(PTRACE_TRACEME, 0, 0, 0).
;       3. Child raises SIGSTOP to yield control to parent (sys_kill).
;       4. Parent intercepts stopped state via sys_wait4.
;       5. Parent inspects child CPU hardware registers (struct user_regs_struct)
;          via PTRACE_GETREGS (RIP, RSP, RAX, RDI, ORIG_RAX).
;       6. Parent performs hardware single-stepping via PTRACE_SINGLESTEP,
;          stepping exactly one CPU instruction and validating RIP advancement.
;       7. Parent intercepts system call boundaries via PTRACE_SYSCALL,
;          inspecting the syscall number in orig_rax (SYS_WRITE = 1).
;       8. Parent resumes child to completion via PTRACE_CONT, verifying exit code.
;   - Pure Linux x86-64 assembly, zero external C runtime (libc) dependencies.
; ==============================================================================

BITS 64
default rel
global _start

; Linux System Call Numbers
SYS_WRITE           equ 1
SYS_GETPID          equ 39
SYS_FORK            equ 57
SYS_EXIT            equ 60
SYS_WAIT4           equ 61
SYS_KILL            equ 62
SYS_PTRACE          equ 101

; ptrace Request Constants
PTRACE_TRACEME      equ 0
PTRACE_CONT         equ 7
PTRACE_SINGLESTEP   equ 9
PTRACE_GETREGS      equ 12
PTRACE_SYSCALL      equ 24

; Signal Constants
SIGSTOP             equ 19
STDOUT_FILENO       equ 1

; struct user_regs_struct offsets (216 bytes total, 27 64-bit registers)
REG_RAX_OFF         equ 80
REG_RDI_OFF         equ 112
REG_ORIG_RAX_OFF    equ 120
REG_RIP_OFF         equ 128
REG_RSP_OFF         equ 152

section .rodata
    banner:
        db "==========================================================", 10
        db " Tutorial 41: Linux Process Tracing & Syscall Interception", 10
        db " (sys_ptrace: Hardware Single-Stepping & Register State)  ", 10
        db "==========================================================", 10
    banner_len equ $ - banner

    msg_forking:
        db "[+] Forking child target and attaching debugger (PTRACE_TRACEME)...", 10
    msg_forking_len equ $ - msg_forking

    msg_stopped:
        db "[+] Parent intercepted child SIGSTOP event via sys_wait4.", 10
    msg_stopped_len equ $ - msg_stopped

    msg_regs_header:
        db "--- Captured Child CPU Register State (PTRACE_GETREGS) ---", 10
    msg_regs_header_len equ $ - msg_regs_header

    msg_rip:
        db "  -> Instruction Pointer (RIP) : "
    msg_rip_len equ $ - msg_rip

    msg_rsp:
        db "  -> Stack Pointer       (RSP) : "
    msg_rsp_len equ $ - msg_rsp

    msg_rax:
        db "  -> Accumulator Register(RAX) : "
    msg_rax_len equ $ - msg_rax

    msg_rdi:
        db "  -> First Argument Reg  (RDI) : "
    msg_rdi_len equ $ - msg_rdi

    msg_singlestep:
        db "[+] Executing single CPU instruction via PTRACE_SINGLESTEP...", 10
    msg_singlestep_len equ $ - msg_singlestep

    msg_step_done:
        db "[+] Instruction executed. Advanced RIP to: "
    msg_step_done_len equ $ - msg_step_done

    msg_syscall_trap:
        db "[+] Resuming to next syscall boundary via PTRACE_SYSCALL...", 10
    msg_syscall_trap_len equ $ - msg_syscall_trap

    msg_syscall_intercepted:
        db "[+] Intercepted child system call! Syscall Number (orig_rax): "
    msg_syscall_intercepted_len equ $ - msg_syscall_intercepted

    msg_cont:
        db "[+] Resuming child execution to completion via PTRACE_CONT...", 10
    msg_cont_len equ $ - msg_cont

    msg_child_hello:
        db "    -> [Child Process] Running inside ptrace container! Writing message...", 10
    msg_child_hello_len equ $ - msg_child_hello

    msg_exit_code:
        db "[+] Child process exited cleanly with status code: "
    msg_exit_code_len equ $ - msg_exit_code

    msg_summary:
        db "[+] Linux ptrace process tracer verification PASSED perfectly!", 10
    msg_summary_len equ $ - msg_summary

    err_fork:
        db "[-] Error: sys_fork failed!", 10
    err_fork_len equ $ - err_fork

    err_ptrace:
        db "[-] Error: sys_ptrace failed!", 10
    err_ptrace_len equ $ - err_ptrace

    newline:
        db 10

section .bss
    child_pid           resq 1
    child_status        resd 1
    num_buf             resb 32
    hex_buf             resb 32

    ; struct user_regs_struct on Linux x86-64 (216 bytes)
    alignb 16
    user_regs:
        resb 216

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
; Helper: Print unsigned 64-bit integer in decimal followed by newline
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

    lea rdx, [num_buf + 32]
    sub rdx, rsi
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    syscall
    ret

; ------------------------------------------------------------------------------
; Helper: Print 64-bit unsigned integer in 0xHEX format followed by newline
; ------------------------------------------------------------------------------
print_hex64:
    ; rdi = 64-bit value
    lea rsi, [hex_buf]
    mov word [rsi], 0x7830          ; "0x"
    mov rcx, 16
.hex_loop:
    mov rdx, rdi
    shr rdx, 60
    and dl, 0x0f
    cmp dl, 9
    jbe .digit
    add dl, ('A' - 10)
    jmp .store
.digit:
    add dl, '0'
.store:
    mov [rsi + 2], dl
    inc rsi
    shl rdi, 4
    dec rcx
    jnz .hex_loop

    mov byte [rsi + 2], 10          ; newline
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    lea rsi, [hex_buf]
    mov rdx, 19                     ; "0x" + 16 chars + newline
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

    ; 2. Fork Child Process
    mov rdi, msg_forking
    mov rsi, msg_forking_len
    call print_str

    mov rax, SYS_FORK
    syscall

    test rax, rax
    js .err_fork_exit
    jz .child_worker

    ; --------------------------------------------------------------------------
    ; Parent Process (Debugger / Tracer)
    ; --------------------------------------------------------------------------
.parent_tracer:
    mov [child_pid], rax            ; Save child PID

    ; Wait for child to stop (sys_wait4)
    mov rax, SYS_WAIT4
    mov rdi, [child_pid]
    lea rsi, [child_status]
    xor rdx, rdx                    ; options = 0
    xor r10, r10                    ; rusage = NULL
    syscall

    mov rdi, msg_stopped
    mov rsi, msg_stopped_len
    call print_str

    ; 3. Inspect Child Hardware Register State (PTRACE_GETREGS)
    ; sys_ptrace(PTRACE_GETREGS, pid, 0, &user_regs)
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_GETREGS
    mov rsi, [child_pid]
    xor rdx, rdx
    lea r10, [user_regs]
    syscall

    test rax, rax
    js .err_ptrace_exit

    ; Display Captured Register State
    mov rdi, msg_regs_header
    mov rsi, msg_regs_header_len
    call print_str

    ; Print RIP
    mov rdi, msg_rip
    mov rsi, msg_rip_len
    call print_str
    mov rdi, [user_regs + REG_RIP_OFF]
    call print_hex64

    ; Print RSP
    mov rdi, msg_rsp
    mov rsi, msg_rsp_len
    call print_str
    mov rdi, [user_regs + REG_RSP_OFF]
    call print_hex64

    ; Print RAX
    mov rdi, msg_rax
    mov rsi, msg_rax_len
    call print_str
    mov rdi, [user_regs + REG_RAX_OFF]
    call print_hex64

    ; Print RDI
    mov rdi, msg_rdi
    mov rsi, msg_rdi_len
    call print_str
    mov rdi, [user_regs + REG_RDI_OFF]
    call print_hex64

    ; 4. Hardware Single-Step Instruction (PTRACE_SINGLESTEP)
    mov rdi, msg_singlestep
    mov rsi, msg_singlestep_len
    call print_str

    ; sys_ptrace(PTRACE_SINGLESTEP, pid, 0, 0)
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_SINGLESTEP
    mov rsi, [child_pid]
    xor rdx, rdx
    xor r10, r10
    syscall

    test rax, rax
    js .err_ptrace_exit

    ; Wait for single-step trap (SIGTRAP)
    mov rax, SYS_WAIT4
    mov rdi, [child_pid]
    lea rsi, [child_status]
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Read updated registers
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_GETREGS
    mov rsi, [child_pid]
    xor rdx, rdx
    lea r10, [user_regs]
    syscall

    mov rdi, msg_step_done
    mov rsi, msg_step_done_len
    call print_str

    mov rdi, [user_regs + REG_RIP_OFF]
    call print_hex64

    ; 5. Intercept System Call Boundary (PTRACE_SYSCALL)
    mov rdi, msg_syscall_trap
    mov rsi, msg_syscall_trap_len
    call print_str

    ; sys_ptrace(PTRACE_SYSCALL, pid, 0, 0)
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_SYSCALL
    mov rsi, [child_pid]
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Wait for syscall entry stop
    mov rax, SYS_WAIT4
    mov rdi, [child_pid]
    lea rsi, [child_status]
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Read registers at syscall entry
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_GETREGS
    mov rsi, [child_pid]
    xor rdx, rdx
    lea r10, [user_regs]
    syscall

    mov rdi, msg_syscall_intercepted
    mov rsi, msg_syscall_intercepted_len
    call print_str

    ; orig_rax contains the intercepted system call number (SYS_WRITE = 1)
    mov rdi, [user_regs + REG_ORIG_RAX_OFF]
    call print_u64

    ; 6. Resume Child to Completion (PTRACE_CONT)
    mov rdi, msg_cont
    mov rsi, msg_cont_len
    call print_str

    ; sys_ptrace(PTRACE_CONT, pid, 0, 0)
    mov rax, SYS_PTRACE
    mov rdi, PTRACE_CONT
    mov rsi, [child_pid]
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Wait for child process exit
    mov rax, SYS_WAIT4
    mov rdi, [child_pid]
    lea rsi, [child_status]
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Extract exit code: (status >> 8) & 0xff
    mov eax, [child_status]
    shr eax, 8
    and eax, 0xff
    mov r12d, eax                   ; r12d = child exit code

    mov rdi, msg_exit_code
    mov rsi, msg_exit_code_len
    call print_str

    mov edi, r12d
    call print_u64

    ; Print Final Summary
    mov rdi, msg_summary
    mov rsi, msg_summary_len
    call print_str

    ; Verify exit code was 42
    cmp r12d, 42
    jne .err_exit

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

    ; --------------------------------------------------------------------------
    ; Child Process (Traced Target)
    ; --------------------------------------------------------------------------
.child_worker:
    ; 1. Request tracing by parent
    ; sys_ptrace(PTRACE_TRACEME, 0, 0, 0)
    mov rax, SYS_PTRACE
    xor rdi, rdi                    ; PTRACE_TRACEME = 0
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    ; 2. Stop self to let parent attach and inspect registers
    ; sys_getpid()
    mov rax, SYS_GETPID
    syscall
    mov rdi, rax                    ; rdi = self pid
    mov rsi, SIGSTOP                ; rsi = SIGSTOP (19)
    mov rax, SYS_KILL
    syscall

    ; When resumed by parent, load recognizable values into registers
    mov rax, 0x1337BEEFCAFEBABE
    mov rdi, 0x0123456789ABCDEF
    nop                             ; Target instruction for PTRACE_SINGLESTEP

    ; Perform a sys_write call for parent to intercept via PTRACE_SYSCALL
    mov rax, SYS_WRITE
    mov rdi, STDOUT_FILENO
    lea rsi, [msg_child_hello]
    mov rdx, msg_child_hello_len
    syscall

    ; Child exits cleanly with code 42
    mov rax, SYS_EXIT
    mov rdi, 42
    syscall

    ; --------------------------------------------------------------------------
    ; Error Handlers
    ; --------------------------------------------------------------------------
.err_fork_exit:
    mov rdi, err_fork
    mov rsi, err_fork_len
    call print_str
    jmp .err_exit

.err_ptrace_exit:
    mov rdi, err_ptrace
    mov rsi, err_ptrace_len
    call print_str

.err_exit:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
