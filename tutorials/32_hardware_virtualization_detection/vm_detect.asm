; ==============================================================================
; tutorials/32_hardware_virtualization_detection/vm_detect.asm
; Hardware Virtualization & Hypervisor Detection in Pure x86-64 Assembly.
;
; Detects:
; 1. Whether running inside a Hypervisor / Virtual Machine (CPUID.1:ECX[31])
; 2. Hypervisor Vendor signature string via CPUID leaf 0x40000000 (KVM, Hyper-V, VMware, Xen)
; 3. Bare-metal hardware virtualization capabilities:
;    - Intel VT-x (VMX) support via CPUID.1:ECX[5]
;    - AMD-V (SVM) support via CPUID.0x80000001:ECX[2]
; ==============================================================================

global _start

%define SYS_WRITE 1
%define SYS_EXIT  60
%define STDOUT    1

section .data
    title_banner    db "+================================================+", 10
                    db "|    HARDWARE VIRTUALIZATION & HYPERVISOR DETECT |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    msg_checking_hv db "[*] Probing CPUID.1:ECX[bit 31] for Hypervisor presence...", 10
    len_checking_hv equ $ - msg_checking_hv

    msg_in_vm       db "[+] HYPERVISOR DETECTED: System is running inside a Virtual Machine!", 10
    len_in_vm       equ $ - msg_in_vm

    msg_bare_metal  db "[-] NO HYPERVISOR DETECTED: System is running directly on BARE-METAL hardware.", 10
    len_bare_metal  equ $ - msg_bare_metal

    msg_sig_prefix  db '[+] Hypervisor Signature String: "', 0
    len_sig_prefix  equ $ - msg_sig_prefix - 1

    msg_sig_suffix  db '"', 10
    len_sig_suffix  equ $ - msg_sig_suffix

    msg_vtx_yes     db "[+] Hardware Virtualization: Intel VT-x (VMX) is SUPPORTED by this CPU.", 10
    len_vtx_yes     equ $ - msg_vtx_yes

    msg_vtx_no      db "[-] Hardware Virtualization: Intel VT-x (VMX) is NOT supported.", 10
    len_vtx_no      equ $ - msg_vtx_no

    msg_svm_yes     db "[+] Hardware Virtualization: AMD-V (SVM) is SUPPORTED by this CPU.", 10
    len_svm_yes     equ $ - msg_svm_yes

    msg_svm_no      db "[-] Hardware Virtualization: AMD-V (SVM) is NOT supported.", 10
    len_svm_no      equ $ - msg_svm_no

    msg_done        db "[+] Virtualization detection diagnostic completed successfully.", 10
    len_done        equ $ - msg_done

section .bss
    hv_sig_buffer   resb 16

section .text

_start:
    ; Print Title Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; Print checking message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_checking_hv]
    mov     rdx, len_checking_hv
    syscall

    ; --------------------------------------------------------------------------
    ; 1. Check Hypervisor Presence: CPUID EAX = 1
    ; --------------------------------------------------------------------------
    mov     eax, 1
    cpuid

    ; Check bit 31 of ECX (Hypervisor present bit)
    ; In x86, bit 31 of a 32-bit register can be checked with 'bt ecx, 31' or 'test ecx, 0x80000000'
    bt      ecx, 31
    jc      .hypervisor_found

.bare_metal_path:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_bare_metal]
    mov     rdx, len_bare_metal
    syscall
    jmp     .check_hw_extensions

.hypervisor_found:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_in_vm]
    mov     rdx, len_in_vm
    syscall

    ; --------------------------------------------------------------------------
    ; 2. Query Hypervisor Signature Leaf: CPUID EAX = 0x40000000
    ; --------------------------------------------------------------------------
    mov     eax, 0x40000000
    cpuid

    ; Return registers contain 12-byte hypervisor string:
    ; EBX = bytes 0..3
    ; ECX = bytes 4..7
    ; EDX = bytes 8..11
    lea     rdi, [rel hv_sig_buffer]
    mov     [rdi + 0], ebx
    mov     [rdi + 4], ecx
    mov     [rdi + 8], edx
    mov     byte [rdi + 12], 0          ; Null terminator

    ; Print Signature Prefix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_sig_prefix]
    mov     rdx, len_sig_prefix
    syscall

    ; Print 12-byte signature
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel hv_sig_buffer]
    mov     rdx, 12
    syscall

    ; Print Signature Suffix
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_sig_suffix]
    mov     rdx, len_sig_suffix
    syscall

    ; --------------------------------------------------------------------------
    ; 3. Check Hardware Virtualization Extensions (Intel VT-x & AMD-V)
    ; --------------------------------------------------------------------------
.check_hw_extensions:
    ; Check Intel VT-x (VMX): CPUID EAX = 1 -> ECX[bit 5]
    mov     eax, 1
    cpuid
    bt      ecx, 5
    jc      .vtx_supported

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_vtx_no]
    mov     rdx, len_vtx_no
    syscall
    jmp     .check_amd_svm

.vtx_supported:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_vtx_yes]
    mov     rdx, len_vtx_yes
    syscall

.check_amd_svm:
    ; Check AMD extended CPUID support: CPUID EAX = 0x80000000
    mov     eax, 0x80000000
    cpuid
    cmp     eax, 0x80000001
    jb      .svm_not_supported          ; Extended function not supported

    ; Check AMD-V (SVM): CPUID EAX = 0x80000001 -> ECX[bit 2]
    mov     eax, 0x80000001
    cpuid
    bt      ecx, 2
    jc      .svm_supported

.svm_not_supported:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_svm_no]
    mov     rdx, len_svm_no
    syscall
    jmp     .finish

.svm_supported:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_svm_yes]
    mov     rdx, len_svm_yes
    syscall

.finish:
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    lea     rsi, [rel msg_done]
    mov     rdx, len_done
    syscall

    ; Clean exit
    mov     rax, SYS_EXIT
    xor     rdi, rdi                    ; Exit code 0
    syscall
