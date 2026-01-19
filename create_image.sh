#!/bin/bash
# Script to create a minimal bootable disk image with GRUB
# Must be run with sudo

set -e

IMG_NAME="kfs.img"
IMG_SIZE=8  # MB
MOUNT_POINT="/tmp/kfs_mount"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

# Clean previous image
rm -f "$IMG_NAME"

# Create empty image
dd if=/dev/zero of="$IMG_NAME" bs=1M count=$IMG_SIZE

# Create partition table and partition
parted -s "$IMG_NAME" mklabel msdos
parted -s "$IMG_NAME" mkpart primary ext2 1MiB 100%
parted -s "$IMG_NAME" set 1 boot on

# Setup loop device
LOOP=$(losetup -f --show -P "$IMG_NAME")
echo "Using loop device: $LOOP"

# Create filesystem
mkfs.ext2 "${LOOP}p1"

# Mount and copy files
mkdir -p "$MOUNT_POINT"
mount "${LOOP}p1" "$MOUNT_POINT"
mkdir -p "$MOUNT_POINT/boot/grub"
cp kfs.bin "$MOUNT_POINT/boot/"
cp grub.cfg "$MOUNT_POINT/boot/grub/"

# Install GRUB
grub-install --target=i386-pc --boot-directory="$MOUNT_POINT/boot" --no-floppy "$LOOP"

# Cleanup
umount "$MOUNT_POINT"
losetup -d "$LOOP"
rmdir "$MOUNT_POINT"

echo "Image created successfully: $IMG_NAME"
ls -lh "$IMG_NAME"
