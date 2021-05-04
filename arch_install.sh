#!/bin/bash
if [ ! -d '/sys/firmware/efi/efivars' ]; then
    echo 'not is uefi!'
    exit 1
fi

systemctl stop reflector.service
timedatectl set-ntp true
echo 'Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

cfdisk /dev/sda

mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mkswap -f /dev/sda4
swapon /dev/sda4

mount /dev/sda2 /mnt
mkdir /mnt/home
mount /dev/sda3 /mnt/home
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi

pacstrap /mnt base base-devel linux linux-firmware
pacstrap /mnt dhcpcd vim sudo bash-completion

genfstab -U /mnt >> /mnt/etc/fstab
echo 'echo 'yog' > /etc/hostname
echo '127.0.0.1    localhost' >> /etc/hosts
echo '::1          localhost' >> /etc/hosts
echo '127.0.1.1    yog.localdomain    yog' >> /etc/hosts

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

vim /etc/locale.gen
locale-gen
echo 'LANG=en_GB.UTF-8'  > /etc/locale.conf

passwd root

pacman -S intel-ucode
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
rm $0' > /mnt/arch_install2.sh

echo "systemctl start dhcpcd
systemctl enable dhcpcd
sleep 10
pacman -S neovim
ln -s /usr/bin/nvim /usr/bin/vi
ln -s /usr/bin/nvim /usr/bin/vim
useradd -m -G wheel -s /bin/bash yog
passwd yog
visudo
echo '[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch' >> /etc/pacman.conf
vim /etc/pacman.conf
pacman -Syyu
rm \$0" > /mnt/arch_install3.sh

arch-chroot /mnt
umount -R /mnt
echo 'ok! reboot!'
