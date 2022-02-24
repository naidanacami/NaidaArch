echo "-------------------------------------------------------------------------"
echo "--                         Cleaning Up / Misc                          --"
echo "-------------------------------------------------------------------------"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers





echo -ne "
-------------------------------------------------------------------------
--          Configuring LTS Kernel as a secondary boot option          --
-------------------------------------------------------------------------
"
sudo cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-lts.conf
sudo sed -i 's|Arch Linux|Arch Linux LTS Kernel|g' /boot/loader/entries/arch-lts.conf
sudo sed -i 's|vmlinuz-linux|vmlinuz-linux-lts|g' /boot/loader/entries/arch-lts.conf
sudo sed -i 's|initramfs-linux.img|initramfs-linux-lts.img|g' /boot/loader/entries/arch-lts.conf


echo -ne "
-------------------------------------------------------------------------
--                 Disabling buggy cursor inheritance                  --
-------------------------------------------------------------------------
"
# When you boot with multiple monitors the cursor can look huge. This fixes it.
sudo cat <<EOF > /usr/share/icons/default/index.theme
[Icon Theme]
#Inherits=Theme
EOF


echo -ne "
-------------------------------------------------------------------------
--                          Enabling services                          --
-------------------------------------------------------------------------
"
systemctl enable smb.service
systemctl enable nmb.service
systemctl enable avahi-daemon.service

echo
echo "Enabling bluetooth daemon and setting it to auto-start"
sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo
echo "Enabling Network Time Protocol so clock will be set via the network"
sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service

echo
echo "Disabling DHCP and enabling Network Manager daemon"

sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
systemctl enable NetworkManager-dispatcher.service


# change directory back
cd $pwd

echo "Done!"