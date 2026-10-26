# Module 34: Hardware Port I/O (`in`/`out`) & CMOS Real-Time Clock (RTC)

## 🎯 Objectives
- Understand the fundamental difference in x86 architecture between:
  - **Memory-Mapped I/O (MMIO)**: Devices mapped into the physical address space accessed via standard `mov` instructions.
  - **Port-Mapped I/O (PMIO)**: A dedicated 16-bit physical bus address space (ports `0x0000` to `0xFFFF`) accessed via the specialized instructions:
    - `IN AL/AX/EAX, DX` (or immediate port)
    - `OUT DX, AL/AX/EAX` (or immediate port)
- Master Linux privileges for hardware port access:
  - In user mode (Ring 3), port I/O triggers a General Protection Fault (`#GP`, SIGSEGV) unless permission is granted.
  - **`sys_ioperm`** (Syscall 173): Sets port access permissions for specific port ranges (`from`, `num`, `turn_on`).
  - **`sys_iopl`** (Syscall 172): Alters the CPU I/O Privilege Level in the RFLAGS register (`IOPL = 3`).
- Interfacing with the standard **Motorola MC146818 CMOS RTC Hardware**:
  - Port `0x70`: CMOS Index/Address port (write target register number, bit 7 controls NMI disable).
  - Port `0x71`: CMOS Data port (read or write the selected CMOS register).
  - Standard CMOS RTC Registers:
    - `0x00`: RTC Seconds
    - `0x02`: RTC Minutes
    - `0x04`: RTC Hours
    - `0x07`: RTC Day of Month
    - `0x08`: RTC Month
    - `0x09`: RTC Year
    - `0x0A`: Status Register A (bit 7: Update In Progress `UIP`)
    - `0x0B`: Status Register B (bit 2: BCD vs Binary mode)
- Handling **Binary Coded Decimal (BCD)**:
  - CMOS hardware registers traditionally store digits in BCD format (e.g., decimal `25` stored as hex byte `0x25`).
  - Decoding BCD to binary: `binary = (bcd & 0x0F) + ((bcd >> 4) * 10)`.

---

## 1. Hardware Architecture: Port I/O vs Memory

```text
CPU 
 │
 ├── Memory Bus (Physical Addresses) ───> RAM & MMIO Devices (mov [addr], reg)
 │
 └── Port Bus (16-bit I/O Space)      ───> Motherboard Controllers (in al, dx / out dx, al)
                                            ├── Port 0x70: CMOS Index Port
                                            └── Port 0x71: CMOS Data Port
```

---

## 2. Hands-on Code Files in this Module
- [`cmos_rtc.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/34_hardware_port_io_cmos_rtc/cmos_rtc.asm) - Tests user-space port permissions with `sys_ioperm`, queries the motherboard CMOS real-time clock, decodes BCD hardware registers, and formats the UTC timestamp.
