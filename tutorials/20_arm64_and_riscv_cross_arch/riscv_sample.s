/* ==============================================================================
 * Program: riscv_sample.s
 * Description: Clean RISC-V (RV64GC) Linux assembly reference
 * Assembler: GNU as (riscv64-linux-gnu-as)
 * ============================================================================== */

.data
msg:
    .ascii "Hello from RISC-V (RV64)!\n"
len = . - msg

.text
.globl _start

_start:
    /* sys_write(fd=1, buf=msg, count=len) */
    li a7, 64                   /* syscall 64 = sys_write in RISC-V Linux */
    li a0, 1                    /* stdout (fd: 1) */
    la a1, msg                  /* pointer to message */
    li a2, len                  /* length */
    ecall                       /* Environment Call (syscall) */

    /* sys_exit(0) */
    li a7, 93                   /* syscall 93 = sys_exit in RISC-V Linux */
    li a0, 0                    /* status = 0 */
    ecall
