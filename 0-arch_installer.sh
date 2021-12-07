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
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


echo -ne "
-------------------------------------------------
   ▄   ██   ▄█ ██▄   ██   ██   █▄▄▄▄ ▄█▄     ▄  █ 
    █  █ █  ██ █  █  █ █  █ █  █  ▄▀ █▀ ▀▄  █   █ 
██   █ █▄▄█ ██ █   █ █▄▄█ █▄▄█ █▀▀▌  █   ▀  ██▀▀█ 
█ █  █ █  █ ▐█ █  █  █  █ █  █ █  █  █▄  ▄▀ █   █ 
█  █ █    █  ▐ ███▀     █    █   █   ▀███▀     █  
█   ██   █             █    █   ▀             ▀   
        ▀             ▀    ▀                     
-------------------------------------------------
--             Automated installer             --
-------------------------------------------------
"


echo -ne "
-------------------------------------------------------------------------
--                       Installing Prerequisites                      -- 
-------------------------------------------------------------------------
"
pacman -Sy --noconfirm
pacman -S --noconfirm --needed gptfdisk cryptsetup grub


# Misc Setup
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timedatectl set-ntp true
pacman -S --noconfirm terminus-font
setfont ter-v22b


echo -ne "
-------------------------------------------------------------------------
--                     select your disk to format                      --
-------------------------------------------------------------------------
"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read disk
disk="${disk,,}"
echo "Please enter desired root (/) directory size (in GiB)"
read rootsize

while true; do
    read -s -p "Please enter LUKS password: " luks_password
    echo
    read -s -p "Please enter LUKS password (again): " luks_password_recheck
    echo
if [ "$luks_password" = "$luks_password_recheck" ] && [ "$luks_password" != "" ]; then
    break
fi
echo "Please try again"
done

if [[ "${disk}" != *"/dev/"* ]]; then
    disk="/dev/${disk}"
fi
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
read -p "are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in
    y|Y|yes|Yes|YES)
        echo "-------------------------------------------------------------------------"
        echo -e "\nFormatting ${disk}..."
        echo "-------------------------------------------------------------------------"
        # disk prep
        sgdisk -Z ${disk} # zap all on disk
        sgdisk -a 2048 -o ${disk} # new gpt disk 2048 alignment

        # create partitions
        sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${disk} # partition 1 (BIOS Boot Partition)
        sgdisk -n 2::+550M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${disk} # partition 2 (UEFI Boot Partition)
        sgdisk -n 3::+${rootsize}G --typecode=3:8300 --change-name=3:'ROOT' ${disk} # partition 3 (Root)
        sgdisk -n 4::-0 --typecode=4:8300 --change-name=4:'HOME' ${disk} # partition 4 (Home), default start, remaining
        if [[ ! -d "/sys/firmware/efi" ]]; then
            sgdisk -A 1:set:2 ${disk}
        fi

        # make filesystems
        if [[ ${disk} =~ "nvme" ]]; then
            mkfs.vfat -F32 -n "EFIBOOT" ${disk}p2                                               # EFIBOOT

        # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}p3 -                # ROOT
        # open luks container and ROOT will be place holder 
            echo -n "${luks_password}" | cryptsetup open ${disk}p3 CRYPTROOT -
        # now format that container
            mkfs.ext4 -L ROOT /dev/mapper/CRYPTROOT
            
        # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}p4 -                # HOME
        # open luks container and ROOT will be place holder 
            echo -n "${luks_password}" | cryptsetup open ${disk}p4 CRYPTHOME -
        # now format that container
            mkfs.ext4 -L HOME /dev/mapper/CRYPTHOME

        else
            mkfs.vfat -F32 -n "EFIBOOT" ${disk}2                                               # EFIBOOT

        # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}3 -                # ROOT
        # open luks container and ROOT will be place holder 
            echo -n "${luks_password}" | cryptsetup open ${disk}3 ROOT -
        # now format that container
            mkfs.ext4 -L ROOT /dev/mapper/ROOT

        # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}4 -                # HOME
        # open luks container and ROOT will be place holder 
            echo -n "${luks_password}" | cryptsetup open ${disk}4 HOME -
        # now format that container
            mkfs.ext4 -L HOME /dev/mapper/HOME

        fi
        echo "Mounting Filesystems..."
        mount /dev/mapper/ROOT /mnt                 # Moutning Root
        mkdir /mnt/home
        mount /dev/mapper/HOME /mnt/home            # Mounting Home
        mkdir /mnt/boot
        mkdir /mnt/boot/efi
        mount -t vfat -L EFIBOOT /mnt/boot
    
        if ! grep -qs '/mnt' /proc/mounts; then
            echo "Drive is not mounted can not continue"
            echo "Rebooting in 3 Seconds ..." && sleep 1
            echo "Rebooting in 2 Seconds ..." && sleep 1
            echo "Rebooting in 1 Second ..." && sleep 1
            reboot now
        fi
    ;;
    *)
        echo "Figure out your drive situation, and try again."
        exit 1
    ;;
esac


ISO=$(curl -4 ifconfig.co/country-iso)
echo "-------------------------------------------------------------------------"
echo "--            Setting up $ISO mirrors for faster downloads             --"
echo "-------------------------------------------------------------------------"
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "reflector is running, please wait..."
reflector -a 48 -c $ISO -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

# Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm


echo "-------------------------------------------------------------------------"
echo "--                     Base Install on Main Drive                      --"
echo "-------------------------------------------------------------------------"
pacstrap /mnt linux base sudo networkmanager iwd --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
#echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/NaidaArch
cp /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.backup
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist	    
echo "-------------------------------------------------------------------------"
echo "--                      GRUB Bootloader Install                        --"
echo "-------------------------------------------------------------------------"
if [[ ! -d "/sys/firmware/efi" ]]; then
   echo "Detected BIOS"
   grub-install --boot-directory=/mnt/boot ${disk}
fi
if [[ -d "/sys/firmware/efi" ]]; then
   echo "Detected EFI"
   grub-install --target=x86_64-efi --efi-directory=/mnt/boot --root-directory=/mnt
fi
#GRUB has been flaky...moving to chroot...BE SURE TO INSTALL GRUB IF YOU MOVE BACK
#