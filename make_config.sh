#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


### CHECKS IF CONFIG NEEDS TO BE MADE
configFileName=$SCRIPT_DIR/install.conf

# Does the file exist at all?
if [ -e "$configFileName" ]; then           # File exists
    while true; do
        # Do all the necessary vars exist?
        . $configFileName 
        if [ -z "$username" ] || [ -z "$password" ] || [ -z "$hostname" ] || [ -z "$volume_group_name" ] || [ -z "$crypt_device" ]; then 
            rm -f $configFileName
            break
        fi

        # They do all exist
	    read -p "Configuration file install.conf already exists. Would you like to recreate it? [Y/n] " yn
        case $yn in
            [Yy]* ) rm -f $configFileName; break;;
            * ) echo "Not generating config file"; exit;;
        esac
    done
fi



### MAKING CONFIG
echo -ne "
    ▄   ██   ▄█ ██▄   ██   ██   █▄▄▄▄ ▄█▄     ▄  █ 
     █  █ █  ██ █  █  █ █  █ █  █  ▄▀ █▀ ▀▄  █   █ 
 ██   █ █▄▄█ ██ █   █ █▄▄█ █▄▄█ █▀▀▌  █   ▀  ██▀▀█ 
 █ █  █ █  █ ▐█ █  █  █  █ █  █ █  █  █▄  ▄▀ █   █ 
 █  █ █    █  ▐ ███▀     █    █   █   ▀███▀     █  
 █   ██   █             █    █   ▀             ▀   
         ▀             ▀    ▀                      

"

echo -e "-------------------------------------------------------------------------"
echo -e " This script will make a sample config file (install.conf) you can edit  "
echo -e " NOTE: if you cancel without completing this config gen, you wil have to "
echo -e "                     delete /NaidaArch/install.conf                      "
echo -e "-------------------------------------------------------------------------"
echo ""


# Get username
read -p "Please enter username: " username
echo "username=\"$username\"" >> $configFileName

# Get passwd
while true; do
    read -p "Password for $username: " password
    read -p "Verify password for $username : " password2
    if [ "$password" = "$password2" ] && [ "$password" != "" ]; then
        break
    fi
echo "Please try again"
done
echo "password=\"$password\"" >> $configFileName

# # Get root passwd
# while true; do
#     read -p "Root password: " root_password
#     read -p "Verify root password: : " root_password2
#     if [ "$root_password" = "$root_password2" ] && [ "$root_password" != "" ]; then
#         break
#     fi
# echo "Please try again"
# done
# echo "root_password=\"$root_password\"" >> $configFileName

# Set hostname
read -p "Please name your machine: " hostname
echo "hostname=\"$hostname\"" >> $configFileName





echo "-------------------------------------------------------------------------"
echo "--              install.conf for $username generated"
echo "-------------------------------------------------------------------------"


# echo 'volume_group_name="cryptLVM"' >> $configFileName
# echo 'crypt_device="LUKS_VG1"' >> $configFileName
echo 'volume_group_name="vg1"' >> $configFileName
echo 'crypt_device="cryptLVM"' >> $configFileName