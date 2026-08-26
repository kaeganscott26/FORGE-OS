# Clean install from the FORGE-OS test ISO

This flow is for **`0.2.4`**, bundling FORGE **`2.4.0-beta`**.

The installer deliberately does **not** partition or format disks. You own the disk layout; FORGE Setup takes over once the target filesystems are mounted.

## 1. Boot the USB in UEFI mode

The live image starts the same FORGE/KWin Wayland stack used by the installed OS. After KWin, Plasma services, PolicyKit, and FORGE are up, **FORGE-OS Setup opens automatically as a normal KDE/Qt window**. The live FORGE desktop remains available underneath.

The ephemeral live account is `forge`. Its password is locked. Passwordless sudo exists only for this disposable live environment and is removed from every installed target.

## 2. Connect to the network

Choose **Network** in FORGE-OS Setup. The clean installer needs network access for the current Arch package set and repository bootstrap.

## 3. Partition and format the disk

Choose **Partition Disks** to open KDE Partition Manager, or open the Advanced Root Shell and use standard Arch tools.

For a simple UEFI installation create at minimum:

- an EFI System Partition formatted FAT32;
- a Linux root filesystem.

Device names are hardware-specific. Verify the target with `lsblk -f` before changing anything.

## 4. Mount the target

The default setup path expects the root filesystem at `/mnt` and the EFI System Partition at `/mnt/boot`.

Example only — replace these with the partitions you actually created:

```bash
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

Confirm them:

```bash
findmnt /mnt
findmnt /mnt/boot
lsblk -f
```

## 5. Run Guided Install

Choose **Guided Install** in FORGE-OS Setup. It collects:

- mounted target root;
- primary administrator username;
- hostname;
- timezone;
- optional-service checkboxes for Bluetooth, printing, Ollama local AI, power profiles, and firmware refresh.

Required networking, firewall, time sync, PipeWire/WirePlumber, trim, mirror maintenance, greetd, recovery, and Wayland services are not optional.

After the GUI summary, the installation opens in a Konsole window. Two deliberate confirmations remain there:

1. set the new installed user's password;
2. type the literal word `INSTALL` before target mutation begins.

The direct advanced equivalent is:

```bash
sudo forge-clean-install --target /mnt --user YOUR_USER --hostname forge-linux
```

The direct path receives the same finalization pass as Guided Install: Advanced maintenance tools, service manifest, first-boot verification, checkpoint recovery, and live-sudo cleanup are installed either way.

## What the installer does

After confirmation it:

- verifies the explicit mounted target and UEFI boot mount;
- installs the authoritative Arch package manifest with `pacstrap`;
- generates a UUID-based `fstab`;
- installs the exact FORGE runtime embedded and hash-recorded in the ISO;
- installs canonical `greetd -> /usr/local/bin/tuigreet -> /usr/local/bin/forge-wayland-session`;
- installs Matrix-default/F4-background greeter configuration using pinned canonical tuigreet 0.11.0;
- enables multilib, Chaotic-AUR, `yay`, tracked HTTPS mirrors and Reflector policy;
- installs the authoritative system-service manifest;
- enables required system/timer/global-user services persistently;
- applies Guided Setup's selected optional-service policy;
- installs Advanced service/admin/verify/repair/update controls;
- installs reversible runtime rollback and full pre-update FORGE-OS checkpoint recovery;
- installs the tty2 graphical recovery path and console break-glass recovery;
- creates the requested wheel administrator and prompts for its password;
- installs systemd-boot automatically when the live system is booted in UEFI mode;
- enables `forge-first-boot.service` so the installed machine verifies/starts all required services before normal graphical use;
- removes the live environment's passwordless-sudo rules from the target.

The installer **never calls `mkfs`, `fdisk`, `cfdisk`, `parted`, `sgdisk`, or `wipefs`**. If the target mounts are missing or wrong, it stops instead of guessing.

## 6. Reboot into the installed system

After Guided Setup reports completion, use its **Restart** control. If you are working from the root shell instead:

```bash
umount -R /mnt
systemctl reboot
```

Remove the USB when firmware begins the reboot.

## Expected first boot

The first installed boot runs the one-shot required-service verifier and then enters the normal graphical path:

```text
greetd
  -> canonical tuigreet 0.11.0 (Matrix default; F4 background selector)
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland
  -> FORGE-OS
```

Physical USB boot, clean installation, services, UI scaling, power/session controls, recovery, update, and rollback remain hardware acceptance checks for this release.
