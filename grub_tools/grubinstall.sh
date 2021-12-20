#!/usr/bin/env bash
# python3 /root/NaidaArch/Replace_Line.py -d "/etc/mkinitcpio.conf" -r "HOOKS=" -i "HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)" -c \# -b True
# mv /etc/mkinitcpio.conf /etc/mkinitcpio.conf.old
# mv ./mkmkinitcpio.conf /etc/mkinitcpio.conf
sed -i 's/#.*HOOKS=(/placeholder/' /etc/mkinitcpio.conf																						# Replaces all commented hooks with a placeholder so the next command won't uncomment all of them
sed -i '/HOOKS=(/c\HOOKS=(base udev autodetect keymap modconf block encrypt lvm2 filesystems keyboard fsck)' /etc/mkinitcpio.conf			# Edit hooks
sed -i 's/placeholder/#    HOOKS=(/' /etc/mkinitcpio.conf		
sleep 5
mkinitcpio -p linux
mkinitcpio -P

# Install Grub																										# Install grub
if [[ ! -d "/sys/firmware/efi" ]]; then
   echo "Detected BIOS"
#    grub-install --target=i386-pc ${disk}
	echo "-------------------------------------------------------------------------"
	echo "--                BIOS system not currently supported!                 --"
	echo "--                            End of script                            --"
	echo "-------------------------------------------------------------------------"
	exit 0
fi
if [[ -d "/sys/firmware/efi" ]]; then
   echo "Detected EFI"
   grub-install --target=x86_64-efi --efi-directory=/boot
fi

# This assumes that partition 2 is the LVM partition. It should be if the disk is zapped and properly parted.
# edits /etc/default/grub																							# edits cfg
lvmuuid=$(blkid -s UUID -o value /dev/sda2)
DefaultGrub="GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=${lvmuuid}:cryptLVM root=/dev/vg1/root\""	
python3 /root/NaidaArch/Replace_Line.py -r GRUB_CMDLINE_LINUX= -d /etc/default/grub -i "${DefaultGrub}"
grub-mkconfig -o /boot/grub/grub.cfg
#GRUB has been flaky...moving to chroot...