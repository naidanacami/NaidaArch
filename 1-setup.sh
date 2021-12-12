#!/usr/bin/env bash
# -------------------------------------------------
#    ▄   ██   ▄█ ██▄   ██   ██   █▄▄▄▄ ▄█▄     ▄  █ 
#     █  █ █  ██ █  █  █ █  █ █  █  ▄▀ █▀ ▀▄  █   █ 
# ██   █ █▄▄█ ██ █   █ █▄▄█ █▄▄█ █▀▀▌  █   ▀  ██▀▀█ 
# █ █  █ █  █ ▐█ █  █  █  █ █  █ █  █  █▄  ▄▀ █   █ 
# █  █ █    █  ▐ ███▀     █    █   █   ▀███▀     █  
# █   ██   █             █    █   ▀             ▀   
#         ▀             ▀    ▀        
# -------------------------------------------------
# https://www.coolgenerator.com/ascii-text-generator
# The edge

nc=$(grep -c ^processor /proc/cpuinfo)
echo "-------------------------------------------------------------------------"
echo "--               Changing the makeflags for "$nc" core(s)              --"
echo "-------------------------------------------------------------------------"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
	sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
	echo "Changing the compression settings for "$nc" cores."
	sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi


echo "-------------------------------------------------------------------------"
echo "--                    Installing kernel and headers                    --"
echo "-------------------------------------------------------------------------"
pacman -S --noconfirm --needed linux linux-lts linux-headers linux-lts-headers

echo "-------------------------------------------------------------------------"
echo "--               Setup Language to US and set locale                   --"
echo "-------------------------------------------------------------------------"
timezone=$(curl -4 http://ip-api.com/line?fields=timezone)
locale=en_US.UTF-8

# Set locale
sed -i s/^#$locale/$locale/ /etc/locale.gen
locale-gen
echo LANG=$locale  > /etc/locale.conf
localectl --no-ask-password set-locale LANG=$locale LC_TIME=$locale

# Set time
timedatectl --no-ask-password set-ntp 1
timedatectl --no-ask-password set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set keymaps
localectl --no-ask-password set-keymap us
#echo "KEYMAP=US" > /etc/vconsole.conf
    
# Set timezone when NetworkManager connects to a network
file=/etc/NetworkManager/dispatcher.d/09-timezone.sh
cat <<EOF > $file
#!/bin/sh
case "\$2" in
    up)
    	timezone=\$(curl --fail http://ip-api.com/line?fields=timezone)
        timedatectl --no-ask-password set-timezone \$timezone
	#ln -sf /usr/share/zoneinfo/\$timezone /etc/localtime
    ;;
esac
EOF
chmod +x $file


echo "-------------------------------------------------------------------------"
echo "--                 Installing Processor Microcode                      --"
echo "-------------------------------------------------------------------------"
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		echo "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		echo "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	


echo "-------------------------------------------------------------------------"
echo "--                   Installing Grapics Drivers                        --"
echo "-------------------------------------------------------------------------"
if lspci | grep -E "NVIDIA|GeForce"; then
	echo "Installing NVIDIA Drivers."
    	pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    	echo "Installing ATI/AMD Drivers."
	pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    	echo "Installing Intel Integrated Drivers."
    	pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

hypervisor=$(systemd-detect-virt)
case $hypervisor in
kvm )		echo "Installing KVM guest tools."
		pacman -S qemu-guest-agent --noconfirm --needed
		systemctl enable qemu-guest-agent
		;;
vmware )   	echo "Installing VMWare guest tools."
	    	pacman -S open-vm-tools --noconfirm --needed
	    	systemctl enable vmtoolsd
	    	systemctl enable vmware-vmblock-fuse
	    	;;
oracle )    	echo "Installing VirtualBox guest tools."
	    	pacman -S virtualbox-guest-utils --noconfirm --needed
		systemctl enable vboxservice
	    	;;
microsoft ) 	echo "Installing Hyper-V guest tools."
		pacman -S hyperv --noconfirm --needed
	    	systemctl enable hv_fcopy_daemon
	    	systemctl enable hv_kvp_daemon
	    	systemctl enable hv_vss_daemon
	    	;;
esac


echo "-------------------------------------------------------------------------"
echo "--                      GRUB Bootloader Install                        --"
echo "-------------------------------------------------------------------------"
# Edit mkinitcpio.conf for LUKS
sed -i '/HOOKS=(/c\HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems keygoard fsck)' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Install Grub
pacman -S  --nopass --needed grub efibootmgr
if [[ ! -d "/sys/firmware/efi" ]]; then
   echo "Detected BIOS"
   grub-install --boot-directory=/mnt/boot ${disk}
fi
if [[ -d "/sys/firmware/efi" ]]; then
   echo "Detected EFI"
   grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
fi

#! This assumes that partition 3 is the LVM partition. It should be if the disk is zapped and properly parted.
# edits /etc/default/grub
configFileName=${HOME}/NaidaArch/install.conf
lvmuuid=$(blkid | grep sd__ | sed -n 's/.* UUID=//p' | awk '{print $1}' | sed 's/"//g')
#	grep sd__: only grabs line with sd__
#	sed -n 's/.* UUID=//p': Removes everything before and including " UUID=" 
#	awk '{print $1}': Gets the uuid and leaves everything else out
#	sed 's/"//g': removes all "
sed -i "/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX\"cryptdevice=UUID=${lvmuuid}:${crypt_device} root=/dev/${volume_group_name}/root\"" /etc/default/grub	


#GRUB has been flaky...moving to chroot...BE SURE TO INSTALL GRUB IF YOU MOVE BACK
echo "paused"
read pause

echo "-------------------------------------------------------------------------"
echo "--                       Installing Packages                           --"
echo "-------------------------------------------------------------------------"

sudo pacman -S --noconfirm --needed - < /pkg-files/pacman-pkgs.txt


echo "-------------------------------------------------------------------------"
echo "--                            Setup User                               --"
echo "-------------------------------------------------------------------------"
# Read config file, if it exists
configFileName=${HOME}/NaidaArch/install.conf
if [ -e "$configFileName" ]; then
	echo "Using configuration file $configFileName."
	. $configFileName
fi

# Get username
if [ -e "$configFileName" ] && [ ! -z "$username" ]; then
	echo "Creating user - $username."
else
	read -p "Please enter username:" username
	echo "username=$username" >> $configFileName
fi

# Add user
egrep -i "libvirt" /etc/group;
if [ $? -eq 0 ]; then
	useradd -m -G wheel,libvirt -s /bin/bash $username
else
	useradd -m -G wheel -s /bin/bash $username
fi

# Set user password
if [ -e "$configFileName" ] && [ ! -z "$password" ] && [ "$password" != "*!*CHANGEME*!*...and-dont-store-in-plantext..." ]; then
	echo "Got a password for $username."
	echo "$username:$password" | chpasswd
	echo "Masking password in config file."
	sed -i.bak 's/^\(password=\).*/\1*!*CHANGEME*!*...and-dont-store-in-plantext.../' $configFileName
else
	passwd $username
	if [ "$password" != "*!*CHANGEME*!*...and-dont-store-in-plantext..." ]; then
		echo "password=*!*CHANGEME*!*...and-dont-store-in-plantext..." >> $configFileName
	fi
fi

# Set hostname
if [ -e "$configFileName" ] && [ ! -z "$hostname" ]; then
	echo "hostname: $hostname"
else
	read -p "Please name your machine:" hostname
	echo "hostname=$hostname" >> $configFileName
fi
echo $hostname > /etc/hostname

# Set hosts file.
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Copy this script to new user home directory
cp -R /root/NaidaArch /home/$username/
chown -R $username: /home/$username/NaidaArch

# Add sudo no password rights
# sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers				# nopass
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers				# pass

echo "ready for 'arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/NaidaArch/2-user.sh'"
