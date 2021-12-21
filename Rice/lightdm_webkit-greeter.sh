#!/usr/bin/env bash
sudo pacman -S --noconfirm --needed lightdm lightdm-webkit2-greeter
yay -S --noconfirm --needed lightdm-webkit-theme-aether
sudo systemctl enable lightdm

sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.old
sed -i 'greeter-session=c\HOOKS=(base udev autodetect keymap modconf block encrypt lvm2 filesystems keyboard fsck)' 

cat <<EOF > ./lightdm.conf
[LightDM]
run-direcotry=/run/lightdm

[Seat:*]
greeter-session=lightdm-webkit2-greeter
session-wrapper-/etc/lightdm/Xsession

[XDMCPServer]

[VNCServer]
EOF
sudo mv ./lightdm.conf /etc/lightdm/lightdm.conf

sudo mv /etc/lightdm/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf.old
cat <<EOF > ./lightdm-webkit2-greeter.conf
[greeter]
debug_mode          = false
detect_theme_errors = true
screensaver_timeout = 300
secure_mode         = true
time_format         = LT
time_language       = auto
webkit_theme        = antergos

[branding]
background_images = /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/wallpapers/
logo              = /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/arch-logo.png
user_image        = /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/default-user/png
EOF
sudo mv ./lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf