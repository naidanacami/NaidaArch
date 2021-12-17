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
pacman -S --noconfirm --needed gptfdisk cryptsetup grub lvm2


# Misc Setup
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timedatectl set-ntp true
# pacman -S --noconfirm terminus-font
# setfont ter-v22b


echo -ne "
-------------------------------------------------------------------------
--                     select your disk to format                      --
-------------------------------------------------------------------------
"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read disk
disk="${disk,,}"
echo "Please enter desired root (/) directory size (in GiB): (example 50)"
read rootsize

while true; do
    read -p "Please enter LUKS password: " luks_password
    read -p "Please enter LUKS password (again): " luks_password_recheck
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

        configFileName=/root/NaidaArch/install.conf
    	. $configFileName
        # create partitions
        sgdisk -n 1::+10M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${disk} # partition 1 (BIOS Boot Partition)
        sgdisk -n 2::+550M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${disk} # partition 2 (UEFI Boot Partition)
        sgdisk -n 3::-0 --typecode=3:8e00 --change-name=3:"LVM_${hostname}" ${disk} # partition 3 (lvm)
        #! sgdisk -n 4::-0 --typecode=4:8300 --change-name=4:'HOME' ${disk} # partition 4 (Home), default start, remaining
        if [[ ! -d "/sys/firmware/efi" ]]; then
            sgdisk -A 1:set:2 ${disk}
        fi

        echo "disk=\"$disk\"" >> $configFileName
        
        if [[ ${disk} =~ "nvme" ]]; then
            mkfs.vfat -F32 -n "EFIBOOT" ${disk}p2                                                       # EFIBOOT

            # LUKS for LVMROOT
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}p3 -                        # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup open ${disk}p3 ${crypt_device} -                    # open luks container
            #LVM for LVMROOT
            pvcreate /dev/mapper/${crypt_device}                                                        # To create a PV
            vgcreate ${volume_group_name} /dev/mapper/${crypt_device}
            lvcreate -L ${rootsize}G ${volume_group_name} -n root                                       # Create root
            lvcreate -l 100%FREE ${volume_group_name} -n home                                           # Create home
            # now format that container
            mkfs.ext4 /dev/${volume_group_name}/root                                                    # Format root ext4
            mkfs.ext4 /dev/${volume_group_name}/home                                                    # Format home ext4

        else
            mkfs.vfat -F32 -n "EFIBOOT" ${disk}2                                                        # EFIBOOT

            # LUKS for LVMROOT
            echo -n "${luks_password}" | cryptsetup -y -v luksFormat ${disk}3 -                         # enter luks password to cryptsetup and format root partition
            echo -n "${luks_password}" | cryptsetup open ${disk}3 ${crypt_device} -                     # open luks container
            #LVM for LVMROOT
            pvcreate /dev/mapper/${crypt_device}                                                        # To create a PV
            vgcreate ${volume_group_name} /dev/mapper/${crypt_device}
            lvcreate -L ${rootsize}G ${volume_group_name} -n root                                       # Create root
            lvcreate -l 100%FREE ${volume_group_name} -n home                                           # Create home
            # now format that container
            mkfs.ext4 /dev/${volume_group_name}/root                                                    # Format root ext4
            mkfs.ext4 /dev/${volume_group_name}/home                                                    # Format home ext4

        fi
        echo "Mounting Filesystems..."
        mount /dev/${volume_group_name}/root /mnt                     # Moutning Root
        mkdir /mnt/home
        mount /dev/${volume_group_name}/home /mnt/home                # Mounting Home
        mkdir /mnt/boot
        # mkdir /mnt/boot/efi
        mount -t vfat -L EFIBOOT /mnt/boot                            # Mounting efi
    
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


# echo "-------------------------------------------------------------------------"
# echo "--                      GRUB Bootloader Install                        --"
# echo "-------------------------------------------------------------------------"
# if [[ ! -d "/sys/firmware/efi" ]]; then
#    echo "Detected BIOS"
#    grub-install --boot-directory=/mnt/boot ${disk}
# fi
# if [[ -d "/sys/firmware/efi" ]]; then
#    echo "Detected EFI"
#    grub-install --target=x86_64-efi --efi-directory=/mnt/boot --root-directory=/mnt
# fi
# #GRUB has been flaky...moving to chroot...BE SURE TO INSTALL GRUB IF YOU MOVE BACK



echo "-------------------------------------------------------------------------"
echo "--                     Base Install on Main Drive                      --"
echo "-------------------------------------------------------------------------"
pacstrap /mnt linux linux-firmware base sudo networkmanager iwd --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
#echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/NaidaArch
cp /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.backup
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist	    
