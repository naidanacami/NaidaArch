#!/bin/bash
# This assumes that partition 2 is the LVM partition. It should be if the disk is zapped and properly parted.
# edits /etc/default/grub
lvmuuid=$(blkid -s UUID -o value /dev/sda2)

DefaultGrub="GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=${lvmuuid}:cryptLVM root=/dev/vg1/root\""	
# sed -i "/GRUB_CMDLINE_LINUX=/c\\${DefaultGrub}" /etc/default/grub
python3 /root/NaidaArch/Replace_Line.py -r GRUB_CMDLINE_LINUX= -d /etc/default/grub -i "${DefaultGrub}"

#GRUB has been flaky...moving to chroot...BE SURE TO INSTALL GRUB IF YOU MOVE BACK

cat /etc/default/grub | grep GRUB_CMDLINE
echo "now do grub-mkconfig -o /boot/grub/grub.cfg"