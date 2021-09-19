#!/bin/bash

TARGET_DISK="/dev/nvme0n1"

echo "#### SETTING TIME STUFF ####"
timedatectl set-ntp true


echo "#### Partitioning ####"
# Partition HD
wipefs -a $TARGET_DISK
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $TARGET_DISK
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +300M # 100 MB boot parttion
  t # Change type
  ef # to Uefi 
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +1G # !G for swap 
  t # change type
  2 # partition 2
  82 # to swap
  n # new partition
  p # primary
  3 # Partition number 3
    # default, start immediately after preceding partition
    # default, all the way to the end
  w # write the partition table
  t # change type
  2 # partition 3
  83 # to linux
  q # and we're done
EOF

echo "#### FORMATTING ####"
# Format disks
mkfs.fat -F32 $TARGET_DISK"p1" 
#mkswap $TARGET_DISK"p2"
mkfs.btrfs -f $TARGET_DISK"p3" 



echo "#### MOUNTING ####"
# Mount new disks
mount $TARGET_DISK"p3" /mnt
mount $TARGET_DISK"p1" /mnt/efi
#swapon $TARGET_DISK"p2"

mkdir /mnt/efi

echo "#### PACSTRAP ####"
# Pacstrap baby
pacstrap /mnt base linux linux-firmware

echo "#### COPY SCRIPT ####"
cp installArchChrooted.sh /mnt/installArchChrooted.sh
chmod +x /mnt/installArchChrooted.sh

echo "#### FSTAB ####"
# Create fstab
genfstab -p -U /mnt >> /mnt/etc/fstab

echo "#### CHROOT ####"
arch-chroot /mnt ./installArchChrooted.sh



