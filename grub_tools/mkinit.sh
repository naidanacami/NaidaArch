pacman -S --noconfirm --needed grub efibootmgr dosfstools mtools os-prober lvm2
#!/bin/bash
# Read config file, if it exists

# # Edit mkinitcpio.conf for LUKS
sed -i 's/#.*HOOKS=(/placeholder/' /etc/mkinitcpio.conf																						# Replaces all commented hooks with a placeholder so the next command won't uncomment all of them
sed -i '/HOOKS=(/c\HOOKS=(base udev autodetect keymap modconf block encrypt lvm2 filesystems keyboard fsck)' /etc/mkinitcpio.conf			# Edit hooks
sed -i 's/placeholder/#    HOOKS=(/' /etc/mkinitcpio.conf																				# Replace placeholder with originals

cat /etc/mkinitcpio.conf | grep HOOKS=
echo "now do mkinitcpio -p linux"

