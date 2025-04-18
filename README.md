# 🧵 Multi-Stage x86 Bootloader with Kernel Loader

This project implements a minimal **multi-stage bootloader** targeting the x86 architecture. It showcases how to manually construct a bootable disk image that includes:

- A **Stage 1 bootloader** (MBR-compliant, 512 bytes)
- A **Stage 2 bootloader** (loaded by Stage 1)
- A **simple kernel** (loaded by Stage 2)
- An emulated disk bootable via QEMU

---

## 🗂️ Project Files

| File           | Description |
|----------------|-------------|
| `boot1.asm`    | First-stage bootloader (executed by BIOS at boot) |
| `boot2.asm`    | Second-stage loader (loaded by Stage 1) |
| `kernel.asm`   | Simple flat binary kernel |
| `Makefile`     | Automates assembly, disk creation, and QEMU launch |
| `disk.img`     | Final bootable disk image (generated) |

---

## 🧠 Boot Flow Overview

```
BIOS → [boot1 (MBR)] → [boot2 (LBA 1)] → [kernel (LBA 2–21)]
```

1. **boot1** (Stage 1):
   - MBR (512 bytes)
   - Loaded automatically by BIOS at `0x7C00`
   - Loads and jumps to `boot2` from LBA sector 1 using BIOS INT 13h

2. **boot2** (Stage 2):
   - Loaded at a higher address (e.g., `0x8000`)
   - Reads `kernel` (20 blocks starting at LBA 2) using BIOS disk services
   - Jumps to the kernel entry point

3. **kernel**:
   - Flat binary
   - Can be anything from real-mode code to a long-mode transition stub

---

## 🛠️ Build & Execution

### 🔧 Requirements

- `nasm` — x86 assembler (e.g. via `sudo apt install nasm`)
- `qemu-system-i386` — to emulate BIOS + MBR (e.g. via `sudo apt install qemu-system`)
- `make`, `dd`, POSIX shell tools

### ⚙️ Targets

```bash
make            # Build and launch QEMU
make clean      # Remove binaries and disk image
```

### What `make` does under the hood:

| Target           | Description |
|------------------|-------------|
| `create_disk`    | Creates a zeroed `disk.img` of 100 × 512-byte sectors |
| `boot1_only`     | Assembles `boot1.asm` to `boot1.bin` |
| `boot2_only`     | Assembles `boot2.asm` to `boot2.bin` |
| `kernel_only`    | Assembles `kernel.asm` to `kernel.bin` |
| `write_boot1`    | Writes `boot1.bin` to LBA 0 (MBR) |
| `write_boot2`    | Writes `boot2.bin` to LBA 1 |
| `write_kernel`   | Writes `kernel.bin` to LBA 2–21 |
| `launch_qemu`    | Boots `disk.img` using QEMU in legacy BIOS mode |

---

## 💾 Disk Layout

```
disk.img (512 * 100 bytes)
├── [LBA 0] boot1 (512 bytes)        ; MBR, must end with 0x55AA
├── [LBA 1] boot2 (512 bytes)
├── [LBA 2-21] kernel (10 KiB max)
└── [LBA 22-99] unused
```

- `block_size = 512`
- `disk_size = 100` blocks
- `kernel_size = 20` blocks

All writes use `dd` with `conv=notrunc` to prevent truncating the disk image.

---

## 🧪 QEMU Launch

```bash
qemu-system-i386 -fda disk.img
```

- Boots in real-mode using BIOS emulation.
- Loads `boot1` → `boot2` → `kernel`.

If your kernel performs graphics or input/output, use QEMU flags accordingly (e.g. `-serial stdio` for printing via BIOS INT 10h).

---

## 🚧 Notes & Caveats

- Ensure `boot1.bin` is **exactly 512 bytes** and ends with the **boot signature `0x55AA`**.
- `boot2.asm` and `kernel.asm` must fit within their allocated sizes.
- All binaries are assembled in **flat binary format** (`nasm -f bin`).

---

## 📚 Learn More

This project is educational and great for understanding:

- BIOS boot process
- Real-mode assembly
- Disk sector addressing via LBA
- Bootstrapping custom kernels

For deeper understanding, you may explore:
- [OSDev Wiki](https://wiki.osdev.org)
- Intel x86 manuals
- BIOS INT 13h Disk Services

---

## 🧼 Cleanup

```bash
make clean
```

Removes:
- `*.bin`
- `disk.img`
- Backup/editor files (`*~`)

---
