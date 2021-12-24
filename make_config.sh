#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Read config file, error if it exists
#configFileName=${HOME}/NaidaArch/install.conf
configFileName=$SCRIPT_DIR/install.conf
if [ -e "$configFileName" ]; then
	echo "Configuration file install.conf already exists...  Cannot continue."
    exit
fi



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
    # lsblk
    # echo ""
    # echo "Above drive breakdown is from THIS MACHINE you are running this make config "
    # echo "script on and MIGHT NOT BE THE SAME AS THE MACHINE YOU INTEND TO INSTALL TO "
    # echo "Be Careful!"
    # echo ""
    # echo "Please enter disk to format: (example /dev/sda)"
    # read disk
    # disk="${disk,,}"
    # if [[ "${disk}" != *"/dev/"* ]]; then
    #     disk="/dev/${disk}"
    # fi
    # echo "disk=$disk" >> $configFileName




# Get username
if [ -e "$configFileName" ] && [ ! -z "$username" ]; then
	echo "Creating user - $username."
else
	read -p "Please enter username: " username
	echo "username=\"$username\"" >> $configFileName
fi




#    if [ "$password" == "*!*CHANGEME*!*...and-dont-store-in-plantext..." ]; then
        while true; do
            read -p "Password for $username: " password
            read -p "Password for $username (again): " password2
	    if [ "$password" = "$password2" ] && [ "$password" != "" ]; then
	    	break
	    fi
	    echo "Please try again"
	done
#	sed -i.bak "s/^\(password=\).*/\1$password/" $configFileName
    echo "password=\"$password\"" >> $configFileName




# Set hostname
if [ -e "$configFileName" ] && [ ! -z "$hostname" ]; then
	echo "hostname: $hostname"
else
	read -p "Please name your machine: " hostname
	echo "hostname=\"$hostname\"" >> $configFileName
fi
#echo $hostname > /etc/hostname





echo "-------------------------------------------------------------------------"
echo "--              install.conf for $username generated"
echo "-------------------------------------------------------------------------"


# echo 'volume_group_name="cryptLVM"' >> $configFileName
# echo 'crypt_device="LUKS_VG1"' >> $configFileName
echo 'volume_group_name="vg1"' >> $configFileName
echo 'crypt_device="cryptLVM"' >> $configFileName