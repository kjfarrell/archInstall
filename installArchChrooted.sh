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
pacman -S grub efibootmgr os-prober --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=esp --bootloader-id=GRUB
