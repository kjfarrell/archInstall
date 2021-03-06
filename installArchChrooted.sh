#!/bin/bash

phase1=(
  "fish" "openssh" "sudo" "base" "base-devel" "wget" "pacman-contrib" "python-pip" 
  "alacritty" "neovim" "efibootmgr" "os-prober" "vim" "networkmanager" "git"
  "grub" "efibootmgr"
)

phase2=(
  "xorg" "xorg-xinit" "gdm" "qtile" "pacman-contrib" "nerd-fonts-ubuntu-mono" 
  "tealdeer" "man" "exa" "ripgrep" "fd" "starship" "neofetch" "google-chrome"
  "code" "nitrogen" "jq" "pywal" "bat"
)

: <<'END'
END

sed 's/#Color/Color/' </etc/pacman.conf >/etc/pacman.conf.new
sed 's/#ParallelDownloads/ParallelDownloads/' </etc/pacman.conf.new >/etc/pacman.conf

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
echo "root:"$2 | chpasswd

echo "#### INSTALL PHASE 1 ####"
#install packages we need Phase 1
pacman -S --noconfirm --needed ${phase1[@]} 
pip install psutil

echo "#### INSTALL GRUB ####"
#Install grub
mkdir -p /boot/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "#### INSTALL NETWORK MANAGER ####"
# Install network manager
systemctl enable NetworkManager

echo "#### CREATE TEMP FOLDER ####"
# Create temp file and cd into it.
tmpdir="$(command mktemp -d)"
command cd "${tmpdir}"
echo ${tmpdir}
chmod 777 "${tmpdir}"

echo "#### PERMISSIONS FOR PARU ####"
# Permission changes to make Paru work
mkdir /.cache
chmod 777 /.cache

echo "#### CREATE USER ####"
# Create user
useradd -m -G "wheel" -s /bin/fish $1
echo "$1:$2" | chpasswd

echo "#### CREATE TEMP FOLDER ####"
# Create temp file and cd into it.
tmpdir="$(command mktemp -d)"
command cd "${tmpdir}"
echo ${tmpdir}
chmod 777 "${tmpdir}"

systemctl enable sshd

sed 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' </etc/sudoers >/etc/sudoers.new
mv -f /etc/sudoers.new /etc/sudoers
rm -f /etc/sudoers.new

sudo -u $1 git clone https://aur.archlinux.org/paru.git
cd paru
sudo -u $1 makepkg -si --noconfirm
sudo -u $1 paru -S --noconfirm ${phase2[@]}

# Dotfiles
#mkdir /home/$1/.config
sudo -u ${1} mkdir -p /home/${1}/bin/styli.sh
git clone https://github.com/kjfarrell/dotfiles.git
cp -fr dotfiles/.config/ /home/$1/
cp -fr dotfiles/bin /home/$1/
chown -R $1 /home/$1/.config/ /home/$1/bin
chgrp -R $1 /home/$1/.config/ /home/$1/bin

sudo -u ${1} mkdir -p /home/${1}/.config/systemd/user
sudo -u ${1} mkdir -p /home/${1}/bin/styli.sh
sudo -u ${1} git clone https://github.com/thevinter/styli.sh
cd styli.sh
sudo -u ${1} cp styli.sh /home/${1}/bin/styli.sh/
sudo -u ${1} cp subreddits /home/${1}/bin/styli.sh/

rm -rf "${tmpdir}"

#End stuff
systemctl enable gdm