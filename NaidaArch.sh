#!/bin/bash

read -t 60 -p 'Welcome! Please wait 60 seconds for lingering tasks (time set, reflector, graphical interface...) to complete. Press enter to skip.'

status=$?
bash make_config.sh
cmd="bash 0-arch_installer.sh"
$cmd
status=$? && [ $status -eq 0 ] || exit

arch-chroot /mnt /bin/bash /root/NaidaArch/1-setup.sh
source /mnt/root/NaidaArch/install.conf #read config file

read -p "Pause 3" pause
arch-chroot /mnt /usr/bin/runuser -u $username -- /bin/bash /home/$username/NaidaArch/2-user.sh
arch-chroot /mnt /bin/bash /root/NaidaArch/3-post_setup.sh
umount -f -a

echo -ne "
    ▄   ██   ▄█ ██▄   ██   ██   █▄▄▄▄ ▄█▄     ▄  █ 
     █  █ █  ██ █  █  █ █  █ █  █  ▄▀ █▀ ▀▄  █   █ 
 ██   █ █▄▄█ ██ █   █ █▄▄█ █▄▄█ █▀▀▌  █   ▀  ██▀▀█ 
 █ █  █ █  █ ▐█ █  █  █  █ █  █ █  █  █▄  ▄▀ █   █ 
 █  █ █    █  ▐ ███▀     █    █   █   ▀███▀     █  
 █   ██   █             █    █   ▀             ▀   
         ▀             ▀    ▀                      

              Successfully installed!              
"

echo "-------------------------------------------------------------------------"
echo "--          Done - Please Eject Install Media and Reboot               --"
echo "-------------------------------------------------------------------------"