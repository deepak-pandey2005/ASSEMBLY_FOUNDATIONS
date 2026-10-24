# Module 32: Hardware Virtualization & Hypervisor Detection (VMX / SVM)

## 🎯 Objectives
- Understand CPU hardware virtualization extensions in x86-64:
  - **Intel VT-x** (Virtual Machine eXtension - `VMX`)
  - **AMD-V** (Secure Virtual Machine - `SVM`)
- Master querying hardware capability bits using the **`CPUID`** instruction.
- Learn standard CPUID virtualization detection mechanisms:
  - **Hypervisor Present Bit**: `CPUID` with `EAX=1` -> Bit 31 of `ECX` is set if running inside a virtual machine (hypervisor present).
  - **Hypervisor Vendor Signature**: Querying `CPUID` with `EAX=0x40000000` to extract standard 12-character hypervisor signatures:
    - `"KVMKVMKVM\0\0\0"` (Linux KVM / QEMU)
    - `"Microsoft Hv"` (Microsoft Hyper-V / WSL2)
    - `"VMwareVMware"` (VMware Workstation / ESXi)
    - `"XenVMMXenVMM"` (Xen Hypervisor)
    - `"bhyve bhyve "` (FreeBSD bhyve)
    - `"TCGTCGTCGTCG"` (QEMU Software TCG emulation)
  - **Bare-Metal Virtualization Support**:
    - Intel: `CPUID` with `EAX=1` -> Bit 5 of `ECX` indicates Intel VT-x (`VMX`) support.
    - AMD: `CPUID` with `EAX=0x80000001` -> Bit 2 of `ECX` indicates AMD-V (`SVM`) support.
- Implement a comprehensive hardware/hypervisor diagnostic tool in pure x86-64 assembly without any C runtime.

---

## 1. The Hypervisor Detection Standard

The hypervisor detection interface is standardized across modern x86 hypervisors:

### Step 1: Check Hypervisor Present Bit
Execute `CPUID` with `EAX = 1`:
- Inspect register `ECX`:
  - **Bit 31** (`1 << 31`): Reserved by Intel/AMD to indicate the presence of a hypervisor.
  - If `0`: System is executing directly on bare-metal hardware (no hypervisor present).
  - If `1`: System is executing inside a virtual machine / hypervisor guest container!

### Step 2: Extract Hypervisor Signature
When the hypervisor present bit is `1`, execute `CPUID` with `EAX = 0x40000000`:
- `EBX`, `ECX`, and `EDX` contain a 12-byte ASCII string identifying the hypervisor technology:

| Hypervisor | EBX (bytes 0..3) | ECX (bytes 4..7) | EDX (bytes 8..11) |
|---|---|---|---|
| **KVM** | `KVMK` | `VMKV` | `M\0\0\0` |
| **Microsoft Hyper-V / WSL2** | `Micr` | `osof` | `t Hv` |
| **VMware** | `VMwa` | `reVM` | `ware` |
| **Xen** | `XenV` | `MMXe` | `nVMM` |
| **QEMU TCG** | `TCGT` | `CGTC` | `GTCG` |

---

## 2. Bare-Metal Hardware Virtualization Flags

When running on bare-metal, a machine might support hardware-assisted virtualization for hosting virtual machines (e.g. running Docker, KVM, VirtualBox):

- **Intel VT-x**:
  - `EAX = 1` -> Check `ECX`, bit 5 (`1 << 5`).
- **AMD-V**:
  - `EAX = 0x80000001` -> Check `ECX`, bit 2 (`1 << 2`).

---

## 3. Hands-on Code Files in this Module
- [`vm_detect.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/32_hardware_virtualization_detection/vm_detect.asm) - Complete, standalone diagnostic tool that probes CPUID leaves and reports virtualization status.
