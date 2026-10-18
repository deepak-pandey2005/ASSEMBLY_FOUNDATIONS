# Module 14: Bare-Metal OS & Bootloaders — Running Without an OS

## 🎯 Objectives
- Understand how a PC boots from raw power-on to CPU execution:
  - Power-On Self Test (POST) $\to$ BIOS / UEFI $\to$ Master Boot Record (MBR).
  - Real Mode (16-bit addressing via Segment:Offset `CS:IP`).
  - The magic boot signature: `0xAA55` at bytes 510-511 of Sector 0.
- Understand BIOS Software Interrupts (`int 0x10` for video teletype).
- Build a real 512-byte MBR Boot Sector that boots natively on hardware or inside QEMU/VirtualBox!

---

## 1. How the x86 CPU Powers Up

When power hits an x86/x86-64 processor:
1. The CPU starts in **16-bit Real Mode** for backwards compatibility with the 1978 Intel 8086!
2. `CS` is loaded with `0xF000` and `IP` with `0xFFF0` (the Reset Vector).
3. The BIOS runs hardware checks and looks for a bootable drive.
4. The BIOS loads the **first 512-byte sector (LBA 0)** into physical RAM address **`0x7C00`**.
5. The BIOS verifies if the last two bytes are `0x55` and `0xAA`.
6. If valid, the BIOS executes a long jump `jmp 0x0000:0x7C00`, handing total control of the hardware to your assembly code!

```text
Physical Memory at 0x7C00
[ 510 Bytes of Your Bootloader Code & Strings ] [ 0x55 ] [ 0xAA ]
                                                    ^       ^
                                           Magic Boot Signature
```

---

## 2. Real Mode Video Output via BIOS `int 0x10`

In 16-bit real mode, there is no Linux kernel and no `syscall` instruction.
To print characters to the display, we trigger the BIOS Video Interrupt (`int 0x10`) in **Teletype Mode** (`AH = 0x0E`):

```nasm
mov ah, 0x0E    ; BIOS teletype function
mov al, 'A'     ; ASCII character to print
int 0x10        ; Call video BIOS
```

---

## 3. Hands-on Code Files in this Module
- [`bootloader.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/14_baremetal_os_bootloader/bootloader.asm) - Authentic 512-byte boot sector that boots a standalone greeting and halts the CPU with `hlt`.
