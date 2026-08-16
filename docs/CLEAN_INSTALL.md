# Clean install from the FORGE-OS test ISO

This flow is for the **0.2.3-test.1** test image. It is intentionally not a stable-release installer.

The live installer does **not** partition or format disks. You own those steps. That boundary is deliberate: the test installer will only operate on a root filesystem that you explicitly mounted.

## 1. Boot the USB

Boot the FORGE-OS ISO in UEFI mode. The live environment enters FORGE Live Recovery using the same Wayland runtime packaged into the image.

## 2. Connect to the network

Use the Network control in the FORGE-OS top bar or NetworkManager from the recovery shell. A clean install needs network access for current Arch packages, Chaotic-AUR setup, `yay`, and the exact source checkouts recorded in the ISO.

## 3. Partition and format the target yourself

Use the disk tools you prefer from the recovery root shell. The ISO contains standard Arch partitioning/formatting tools, including GPT and FAT utilities.

For a simple UEFI install, create at minimum:

- an EFI System Partition formatted FAT32;
- a Linux root filesystem.

The exact device names are hardware-specific. Verify them with `lsblk -f` before making changes.

## 4. Mount the target

Example only — replace the devices with the partitions you actually created:

```bash
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

Confirm them before installing:

```bash
findmnt /mnt
findmnt /mnt/boot
lsblk -f
```

## 5. Run the guarded installer

From FORGE Live Recovery, choose **Install FORGE-OS to mounted disk**, or run:

```bash
sudo forge-clean-install --target /mnt --user YOUR_USER --hostname forge-linux
```

The installer prints the resolved target device, FORGE-OS version, username, hostname, and timezone, then requires you to type `INSTALL` before it mutates the mounted target.

It will:

- install the authoritative Arch package manifest with `pacstrap`;
- generate a UUID-based `fstab`;
- install the exact FORGE runtime embedded in the ISO;
- install the canonical Wayland/greetd session and Matrix/F4 greeter configuration;
- enable multilib, Chaotic-AUR, `yay`, mirrors, Reflector, and package routing;
- enable the required system and user services persistently;
- create the requested desktop user and prompt for its password;
- clone FORGE and FORGE-OS at the commits recorded in the ISO while leaving `main` attached to `origin/main` for later `git pull --ff-only` updates;
- install systemd-boot automatically when the live machine is booted in UEFI mode.

The installer **never calls `mkfs`, `fdisk`, `cfdisk`, `parted`, `sgdisk`, or `wipefs`**. If the root filesystem or EFI partition is not mounted where expected, it stops.

## 6. Reboot

After the installer finishes, inspect the target if desired, then unmount and reboot:

```bash
umount -R /mnt
reboot
```

Remove the USB when the firmware begins the reboot.

## Expected first boot

The installed machine should boot through greetd into the FORGE login screen with Matrix as the default background, F4 background selection, the canonical `/usr/local/bin/forge-wayland-session` path, and the **0.2.3-test.1** FORGE-OS runtime. This is still a test image; report hardware/session/install failures before any stable release is cut.
