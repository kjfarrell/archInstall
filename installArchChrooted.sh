#!/bin/bash

echo "#### SET ROOT PASSWORD ####"
read -sp "Enter password: " passvar

echo "#### LOCALES ####"
ln -sf /usr/share/zoneinfo/Australia/Perth /etc/localtime 
hwclock --systohc
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "#### HOSTNAME HOSTS ####"
echo "myArchiePoo" >> /etc/hostname
echo -e "127.0.0.1    localhost\n::1          localhost\n127.0.1.1    myhostname. localdomain myhostname" >> /etc/hosts

echo "#### MKINITCPIO ####"
# mkinitcpio -P

echo "#### SET ROOT PASSWORD ####"
echo "root:"$passvar | chpasswd
pacman -S grub os-prober --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=i386-pc /dev/nvme0n1
