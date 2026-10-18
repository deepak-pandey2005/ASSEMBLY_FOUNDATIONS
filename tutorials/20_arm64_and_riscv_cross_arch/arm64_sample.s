/* ==============================================================================
 * Program: arm64_sample.s
 * Description: Clean ARM64 (AArch64) Linux assembly reference
 * Assembler: GNU as (aarch64-linux-gnu-as)
 * ============================================================================== */

.data
msg:
    .ascii "Hello from ARM64 (AArch64)!\n"
len = . - msg

.text
.globl _start

_start:
    /* sys_write(fd=1, buf=msg, count=len) */
    mov x8, 64                  /* syscall 64 = sys_write in ARM64 Linux */
    mov x0, 1                   /* stdout (fd: 1) */
    ldr x1, =msg                /* pointer to message */
    mov x2, len                 /* length */
    svc #0                      /* Supervisor Call (syscall) */

    /* sys_exit(0) */
    mov x8, 93                  /* syscall 93 = sys_exit in ARM64 Linux */
    mov x0, 0                   /* status code = 0 */
    svc #0
